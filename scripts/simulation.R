# ---- pareto_demo ----
# setwd("scripts")
suppressMessages(library(dplyr))
library(magrittr)
library(ggplot2)
library(cowplot)
suppressMessages(library(rstan))
suppressMessages(library(sf))
# setwd("scripts")

set.seed(234)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

dpareto <- function(x, a = 0.9, b = 1) a * b^a / x^(a + 1)
ppareto <- function(x, a = 0.9, b = 1) (x > b) * (1 - (b / x)^a)
qpareto <- function(u, a = 0.9, b = 1) b / (1 - u)^(1 / a)
rpareto <- function(n, a = 0.9, b = 1, max = Inf) {
  res <- qpareto(runif(n), a, b)
  res <- res[res < max]

  while (length(res) < n) {
    res <- c(res, qpareto(runif(n - length(res)), a, b))
  }
  res
}
# (dt <- sample(1:10, 12, replace = TRUE) %>% .[order(.)])
# (cf <- cumulative_freq(dt))
cumulative_freq <- function(x) {
  l_n    <- cumsum(rev(table(x)))
  l_area <- rev(as.numeric(names(table(x))))

  data.frame(area = l_area, number = l_n)
}

# inv_cumulative_freq(cf)
inv_cumulative_freq <- function(cf) {
  cf <- cf[order(cf$number), ]
  rep(cf$area, c(cf$number[1], diff(cf$number)))
}


#' Read a config.py file in R
#'
#' @param file a file path
#' @export
#' @examples \dontrun{
#' # See jsta/rjsta @ Github
#' dir(config()$a)
#' }
config <- function(file = "config.py") {
  res <- suppressWarnings(readLines(file))

  # remove non equal sign lines
  is_assignment <- as.logical(sapply(res, function(x) grep("=", x) >= 1))
  is_assignment <- sapply(is_assignment,
    function(x) ifelse(is.na(x), FALSE, TRUE))
  res <- res[is_assignment]

  res <- strsplit(res, " ")
  keys <- unlist(lapply(res, function(x) x[[1]][[1]]))
  values <- unlist(lapply(res, function(x) x[[3]][[1]]))
  # keys <- unlist(lapply(res, function(x) strsplit(x, "=")[[1]][[1]]))
  # values <- unlist(lapply(res, function(x) strsplit(x, "=")[[1]][[2]]))

  res <- setNames(data.frame(t(values)), keys)

  norm_file_path <- function(x) {
    gsub('\\"', "", gsub("\\\\\\\\", "\\\\", x))
  }

  data.frame(t(apply(res, 2, norm_file_path)))
}

# read-in hydrolakes data
data_path_hydrolakes <- config("../config.py")$data_path_hydrolakes
data_path_hydrolakes <- file.path(data_path_hydrolakes,
  "HydroLAKES_polys_v10_shp", "HydroLAKES_polys_v10.shp")
area_hydrolakes <- st_read(data_path_hydrolakes,
  query = "SELECT Lake_area FROM \"HydroLAKES_polys_v10\"", quiet = TRUE) %>%
  st_drop_geometry()
area_hydrolakes <- area_hydrolakes$Lake_area

# simulate random pareto draws
# unlink("../data/y.rds")
if (!file.exists("../data/y.rds")) {
  y <- rpareto(153000, max = 81935.7) # cap at the area of Lake Superior
  saveRDS(y, "../data/y.rds")
}
#
y <- readRDS("../data/y.rds")

pareto_plot_prep <- function(x) {
  individual_binning <- hist(log(x), plot = FALSE, n = 100) %>%  {
    data.frame(x = .$breaks[-1], samples = log(.$counts))
  }
  cumulative_binning <- cumulative_freq(x)

  list(individual_binning = individual_binning,
    cumulative_binning = cumulative_binning)
}

pareto_plot <- function(individual_binning, cumulative_binning) {
  gg_individual <- ggplot(data = individual_binning) +
    geom_line(aes(x, samples, color = name)) +
    theme_minimal() +
    theme(legend.position = "none")

  gg_cumulative <- ggplot(data = cumulative_binning) +
    geom_line(aes(area, number, color = name)) +
    theme_minimal() + scale_x_log10() + scale_y_log10() +
    ylab("samples with value > x") + xlab("x") +
    labs(color = "")

  plot_grid(gg_individual, gg_cumulative,
    nrow = 1, rel_widths = c(0.68, 1))
}

individual_binning <- rbind(
  mutate(pareto_plot_prep(y)$individual_binning, name = "simulated"),
  mutate(pareto_plot_prep(area_hydrolakes)$individual_binning,
    name = "hydrolakes")
)
cumulative_binning <- rbind(
  mutate(pareto_plot_prep(y)$cumulative_binning, name = "simulated"),
  mutate(pareto_plot_prep(area_hydrolakes)$cumulative_binning,
    name = "hydrolakes"))

pareto_demo <- pareto_plot(individual_binning, cumulative_binning)

ggsave("../manuscript/figures/pareto_demo-1.pdf", pareto_demo,
  width = 5.93, height = 2.33)

# remove lakes below censor threshold ####
# hist(log(y))
y_censored <- y[log(y) > 1]

# ---- recover_area ----

# back out total "area" from individual binning
total_area <- hist(log(y), plot = FALSE, n = 10000) %>%
  {
    data.frame(x = .$breaks[-1], samples = log(.$counts))
  } %>%
  filter(samples > -Inf)

total_area <- sum(exp(total_area$x) * exp(total_area$samples))
# print(total_area)

# ---- predict_area ----
# back out total "area" from cumulative frequency
total_empirical <- sum(inv_cumulative_freq(cumulative_freq(y)))

# estimate pareto slope using log-log method
cf         <- cumulative_freq(y_censored)
cf$density <- log(cf$number) - max(log(cf$number))
cf$type    <- "empirical"
fit_lm     <- lm(density ~ log(area), data = cf)

# extrapolate censored lake counts
cf_extra <- data.frame(area = exp(seq(
  from = min(log(y)),
  to   = min(log(y_censored)),
  by   = abs(mean(diff(log(cf$area)))))))

preds <- data.frame(predict(fit_lm, cf_extra, interval = "confidence"))
preds <- setNames(preds, c("density", "lower", "upper"))
cf_extra <- cbind(cf_extra, preds)
cf_extra$type    <- "predicted"
cf_extra$number  <- exp(cf_extra$density + max(log(cf$number)))
cf_extra$number_lower  <- exp(cf_extra$lower + max(log(cf$number)))
cf_extra$number_upper  <- exp(cf_extra$upper + max(log(cf$number)))

res         <- dplyr::bind_rows(cf_extra, cf)

predict_area <- ggplot(data = res) +
  geom_line(aes(x = area, y = density, linetype = type)) +
  scale_x_log10() + theme(legend.title = element_blank())
ggsave("../manuscript/figures/predict_area-1.pdf", predict_area,
  width = 4.28, height = 2.33)

# back-out an estimate of total area
total_predicted <- sum(inv_cumulative_freq(res))

# ---- frequentist_uncertainty ----
stack_preds <- c(res$density[1:nrow(cf_extra)],
  res$lower[1:nrow(cf_extra)],
  res$upper[1:nrow(cf_extra)])
stack_preds <- data.frame(preds = stack_preds,
  area  = rep(res$area[1:nrow(cf_extra)], times = 3),
  type  = rep(c("50", "2.5", "97.5"),
    each = nrow(cf_extra)))
# res$number_lower[(nrow(cf_extra) + 1):nrow(res)] <-
#   res$number_upper[(nrow(cf_extra) + 1):nrow(res)] <-
#   res$number[(nrow(cf_extra) + 1):nrow(res)]

frequentist_uncertainty <- ggplot() +
  geom_line(data = stack_preds, aes(x = area, y = preds, color = type)) +
  scale_x_log10() + xlab("density") + labs(color = "Confidence \n Interval")
ggsave("../manuscript/figures/frequentist_uncertainty-1.pdf",
  frequentist_uncertainty, width = 5.93, height = 2.33)

# ---- bayesian_model ----
# https://github.com/stan-dev/example-models/blob/master/bugs_examples/vol3/fire/fire.stan

# fit pareto to get alpha estimates
pareto_model <-
  "
data {
  int<lower=0> N;
  real x[N];
}
parameters {
  real<lower=0> alpha;
  real<lower=0> theta;
}
model {
  real lpa[N];

  theta ~ gamma(.001, .001);
  alpha ~ gamma(.001, .001);

  for (i in 1:N) {
    lpa[i] = pareto_lpdf(x[i] | theta, alpha);
  }

  target += sum(lpa);
}
"

if (!file.exists("../data/pareto_bayes.rds")) {
  fit <- stan(model_code = pareto_model,
    data = list(N = length(y_censored), x = y_censored),
    iter = 8000)

  # print(fit)
  # plot(fit, pars = "alpha")
  saveRDS(fit, "../data/pareto_bayes.rds")
}
fit <- readRDS("../data/pareto_bayes.rds")

if (!file.exists("../data/alphas.rds")) {
  alphas <- tidybayes::spread_samples(fit, alpha)$alpha
  saveRDS(alphas, "../data/alphas.rds")
}
alphas <- readRDS("../data/alphas.rds")

conf_int <- quantile(alphas, probs = c(0.025, 0.5, .975))
bayesian_model <- ggplot() +
  geom_histogram(data = data.frame(alpha = alphas), aes(x = alpha)) +
  geom_vline(aes(xintercept = conf_int[c(1, 3)]), color = "red") +
  geom_vline(aes(xintercept = conf_int[2])) +
  geom_vline(aes(xintercept = 0.9), linetype = 2)
ggsave("../manuscript/figures/bayesian_model-1.pdf", bayesian_model,
  width = 4.43, height = 2.33)

# ---- bayesian_area ----

if (!file.exists("../data/area_bayes.rds")) {
  # find estimated density of censored lakes given alpha
  # back-out an estimate of total area
  area_bayes <- sapply(alphas, function(a) {
    cf_extra_bayes <- select(cf_extra, area)
    cf_extra_bayes$density <- (log(cf_extra_bayes$area) * (a * -1)) +
      log(min(y_censored)) - 0.1
    cf_extra_bayes$type    <- "predicted_bayes"
    cf_extra_bayes$number  <- exp(cf_extra_bayes$density + max(log(cf$number)))
    res <- dplyr::bind_rows(cf_extra_bayes, cf)

    sum(inv_cumulative_freq(res))
    # total_empirical

  })

  saveRDS(area_bayes, "../data/area_bayes.rds")
}
area_bayes <- readRDS("../data/area_bayes.rds")

conf_int <- quantile(area_bayes, probs = c(0.025, 0.5, .975))
bayesian_area <- ggplot() +
  geom_histogram(data = data.frame(area = area_bayes), aes(x = area)) +
  geom_vline(aes(xintercept = conf_int[c(1, 3)]), color = "red") +
  geom_vline(aes(xintercept = conf_int[2])) +
  geom_vline(aes(xintercept = total_empirical), linetype = 2)
ggsave("../manuscript/figures/bayesian_area-1.pdf", bayesian_area,
  width = 4.36, height = 2.33)

# ggplot(data = res) +
#   geom_line(aes(x = area, y = density, linetype = type)) +
#   scale_x_log10() + theme(legend.title = element_blank())