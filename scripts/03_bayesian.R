source("scripts/utils.R")
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

y_censored <- readRDS("data/y_censored.rds")
cf_extra <- readRDS("data/cf_extra.rds")
cf <- readRDS("data/cf.rds")

# ---- bayesian_model ----
# nolint start
# https://github.com/stan-dev/example-models/blob/master/bugs_examples/vol3/fire/fire.stan
# nolint end

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

  theta ~ gamma(1, 3);
  alpha ~ gamma(1, 3);

  for (i in 1:N) {
    lpa[i] = pareto_lpdf(x[i] | theta, alpha);
  }

  target += sum(lpa);
}
"

# nolint start
# unlink("../data/pareto_bayes.rds"); unlink("../data/alphas.rds"); unlink("../data/area_bayes.rds")
# nolint end


if (!file.exists("data/pareto_bayes.rds")) {
  init_f <- function() {
    list(alpha = runif(1, 0.66, 1.334)) # from Downing et al. 2006
  }

  fit <- stan(
    file = "pareto_model.stan",
    data = list(N = length(y_censored), x = y_censored),
    iter = 15000,
    chains = 4,
    control = list(adapt_delta = 0.9),
    init = init_f
  )

  # print(fit)
  # plot(fit, pars = "alpha")
  saveRDS(fit, "data/pareto_bayes.rds")
}
fit <- readRDS("data/pareto_bayes.rds")

if (!file.exists("data/alphas.rds")) {
  alphas <- tidybayes::spread_draws(fit, alpha)$alpha
  saveRDS(alphas, "data/alphas.rds")
}
alphas <- readRDS("data/alphas.rds")

conf_int <- quantile(alphas, probs = c(0.025, 0.5, .975))
alphas_sim <- rlnorm(
  n = 100000,
  meanlog = log(conf_int[2]),
  sdlog = conf_int[2] - conf_int[1]
)
conf_int <- quantile(alphas_sim, probs = c(0.025, 0.5, .975))

bayesian_model <- ggplot() +
  geom_histogram(
    data = data.frame(alpha = alphas_sim),
    aes(x = alpha), binwidth = (conf_int[2] - conf_int[1]) / 10
  ) +
  geom_vline(aes(xintercept = conf_int[c(1, 3)]), color = "red") +
  geom_vline(aes(xintercept = conf_int[2])) +
  geom_vline(aes(xintercept = 0.9), linetype = 2) +
  xlim(
    conf_int[2] - ((conf_int[2] - conf_int[1]) * 2.5),
    conf_int[2] + ((conf_int[3] - conf_int[2]) * 2.5)
  )
bayesian_model
ggsave("manuscript/figures/bayesian_model-1.pdf", bayesian_model,
  width = 4.43, height = 2.33
)

# ---- bayesian_area ----

# TODO: the below calculations are probably incorrect

# back out total "area" from cumulative frequency
y_raw <- readRDS("data/y.rds")$y_raw
total_empirical <- sum(inv_cumulative_freq(cumulative_freq(y_raw)))
# print(total_empirical)

if (!file.exists("data/area_bayes.rds")) {
  # find estimated density of censored lakes given alpha
  # back-out an estimate of total area
  area_bayes <- sapply(sample(alphas_sim, 700), function(a) {
    # a <- alphas[1]
    cf_extra_bayes <- select(cf_extra, area)
    cf_extra_bayes$density <- (log(cf_extra_bayes$area) * (a * -1)) +
      log(min(y_censored)) - 0.085
    cf_extra_bayes$type <- "predicted_bayes"
    cf_extra_bayes$number <- exp(cf_extra_bayes$density + max(log(cf$number)))
    res <- dplyr::bind_rows(cf_extra_bayes, cf)

    sum(inv_cumulative_freq(res))
    # total_empirical
  })

  saveRDS(area_bayes, "data/area_bayes.rds")
}
area_bayes <- readRDS("data/area_bayes.rds")

conf_int <- quantile(area_bayes, probs = c(0.025, 0.5, .975))
bayesian_area <- ggplot() +
  geom_histogram(data = data.frame(area = area_bayes), aes(x = area)) +
  geom_vline(aes(xintercept = conf_int[c(1, 3)]), color = "red") +
  geom_vline(aes(xintercept = conf_int[2])) +
  geom_vline(aes(xintercept = total_empirical), linetype = 2) +
  xlim(
    conf_int[2] - ((conf_int[2] - conf_int[1]) * 2),
    conf_int[3] + ((conf_int[3] - conf_int[2]))
  )
ggsave("manuscript/figures/bayesian_area-1.pdf", bayesian_area,
  width = 4.36, height = 2.33
)

# ggplot(data = res) +
#   geom_line(aes(x = area, y = density, linetype = type)) +
#   scale_x_log10() + theme(legend.title = element_blank())
