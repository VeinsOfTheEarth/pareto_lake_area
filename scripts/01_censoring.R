# setwd("scripts")
source("scripts/utils.R")

y <- readRDS("data/y.rds")
y_raw <- y$y_raw
# hist(log(y_raw))

# remove lakes below censor threshold ----
y_censored_raw <- y_raw[log(y_raw) > 1]
y_censored_cumulative <- mutate(
  cumulative_freq(y_censored_raw), name = "censored")
y_censored_individual <- individual_freq(y_censored_raw)
saveRDS(y_censored_raw, "data/y_censored.rds")

#  compare hydrolakes and y_censored_cumulative
hydrolakes <- readRDS("data/hydrolakes.rds")
rbind(y_censored_cumulative, hydrolakes$hydrolakes_cumulative) %>%
  ggplot() +
  geom_line(aes(area, number, color = name)) +
  theme_minimal() + scale_x_log10() + scale_y_log10() +
  ylab("n > area") + xlab("area") +
  labs(color = "")

# tail(y_censored_cumulative)
# tail(y$y_cumulative)
# dplyr::filter(y$y_cumulative, area > 2.718311) %>% tail()

# range(y_censored_raw)
# hist(log(y_raw))
# hist(log(y_censored_raw))

#

# y <- c(y,
#   list(
#     y_censored_raw = y_censored_raw,
#     y_censored_cumulative = y_censored_cumulative))
# saveRDS(y, "data/y.rds")

# back out total "area" from individual binning ----
total_area <- hist(log(y_raw), plot = FALSE, n = 10000) %>%
  {
    data.frame(x = .$breaks[-1], samples = log(.$counts))
  } %>%
  filter(samples > -Inf)

total_area <- sum(exp(total_area$x) * exp(total_area$samples))
# print(total_area)

# back out total "area" from cumulative frequency ----
total_empirical <- sum(inv_cumulative_freq(cumulative_freq(y_raw)))
# print(total_empirical)

# estimate pareto slope using log-log method ----
cf         <- y_censored_cumulative
cf$density <- rev(log(max(cf$number) - cf$number + 1))
# range(cf$density)
cf$type    <- "empirical"
# ggplot(data = cf) +
#   geom_line(aes(x = area, y = density, linetype = type)) +
#   scale_x_log10() + theme(legend.title = element_blank())


# extrapolate censored lake counts
fit_lm     <- lm(density ~ log(area), data = cf)
cf_extra <- data.frame(area = exp(seq(
  from = min(log(y_raw)),
  to   = min(log(y_censored_raw)),
  by   = abs(mean(diff(log(cf$area)))))))

preds <- data.frame(predict(fit_lm, cf_extra, interval = "confidence"))
preds <- setNames(preds, c("density", "lower", "upper"))
cf_extra <- cbind(cf_extra, preds)
cf_extra$type    <- "predicted"
cf_extra$number <- exp(cf_extra$density) + log(max(cf$number))
cf_extra$number_lower  <- exp(cf_extra$lower + max(log(cf$number)))
cf_extra$number_upper  <- exp(cf_extra$upper + max(log(cf$number)))

res <- dplyr::bind_rows(cf_extra, cf) %>%
  mutate(name = "simulated", lab = paste0(name, "-", type), area = area)

saveRDS(res, "data/res.rds")
saveRDS(cf_extra, "data/cf_extra.rds")
saveRDS(cf, "data/cf.rds")

# compare hydrolakes and censored predictions
hydrolakes <- readRDS("data/hydrolakes.rds")
predict_censor <- rbind(
  dplyr::select(res, area, number, name, type),
  mutate(hydrolakes$hydrolakes_cumulative, type = "empirical")
) %>%
  ggplot() +
  geom_line(aes(area, number, color = name, linetype = type)) +
  theme_minimal() + scale_x_log10() + scale_y_log10() +
  ylab("n > area") + xlab("area") +
  labs(color = "")

ggsave("manuscript/figures/predict_censor-1.pdf", predict_censor,
  width = 4.28, height = 2.33)

# back-out an estimate of total area
total_predicted <- sum(inv_cumulative_freq(res))