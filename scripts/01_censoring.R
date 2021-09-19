# setwd("scripts")
source("utils.R")

y <- readRDS("../data/y.rds")

# remove lakes below censor threshold ####
# hist(log(y))
y_censored <- y[log(y) > 1]
saveRDS(y_censored, "../data/y_censored.rds")

# recover_area ----

# back out total "area" from individual binning
total_area <- hist(log(y), plot = FALSE, n = 10000) %>%
  {
    data.frame(x = .$breaks[-1], samples = log(.$counts))
  } %>%
  filter(samples > -Inf)

total_area <- sum(exp(total_area$x) * exp(total_area$samples))
# print(total_area)

# predict_area ----
# back out total "area" from cumulative frequency
total_empirical <- sum(inv_cumulative_freq(cumulative_freq(y)))

# estimate pareto slope using log-log method
cf         <- cumulative_freq(y_censored)
cf$density <- rev(log(max(cf$number) - cf$number + 1))
# range(cf$density)
cf$type    <- "empirical"
# ggplot(data = cf) +
#   geom_line(aes(x = area, y = density, linetype = type)) +
#   scale_x_log10() + theme(legend.title = element_blank())


# extrapolate censored lake counts
fit_lm     <- lm(density ~ log(area), data = cf)
cf_extra <- data.frame(area = exp(seq(
  from = min(log(y)),
  to   = min(log(y_censored)),
  by   = abs(mean(diff(log(cf$area)))))))

preds <- data.frame(predict(fit_lm, cf_extra, interval = "confidence"))
preds <- setNames(preds, c("density", "lower", "upper"))
cf_extra <- cbind(cf_extra, preds)
cf_extra$type    <- "predicted"
cf_extra$number <- exp(cf_extra$density) + log(max(cf$number))
cf_extra$number_lower  <- exp(cf_extra$lower + max(log(cf$number)))
cf_extra$number_upper  <- exp(cf_extra$upper + max(log(cf$number)))

res <- dplyr::bind_rows(cf_extra, cf) %>%
  mutate(name = "simulated", lab = paste0(name, "-", type), area = log(area))

saveRDS(res, "../data/res.rds")
saveRDS(cf_extra, "../data/cf_extra.rds")

# dplyr::filter(individual_binning, name == "hydrolakes")

# head(individual_binning)
# range(individual_binning)

# test2 <- dplyr::bind_rows(
#   res,
#   mutate(pareto_plot_prep(area_hydrolakes)$individual_binning,
#     name = "hydrolakes", type = "empirical") %>%
#     mutate(lab = paste0(name, "-", type)) %>%
#     rename(area = x, density = samples)
# )

predict_area <-
  res %>%
  #   test2() %>%
  ggplot() +
  geom_line(aes(x = area, y = density, color = lab)) +
  theme(legend.title = element_blank())

mutate(pareto_plot_prep(area_hydrolakes)$cumulative_binning,
  name = "hydrolakes") %>%
  # rename(x = area, samples = density) %>%
  nrow()


predict_number <- ggplot(data = res) +
  geom_line(aes(area, number, linetype = type)) +
  theme_minimal() + scale_x_log10() + scale_y_log10() +
  ylab("n > area") + xlab("area")

predict_censor <- plot_grid(predict_area, predict_number)

ggsave("../manuscript/figures/predict_censor-1.pdf", predict_censor,
  width = 4.28, height = 2.33)

# back-out an estimate of total area
total_predicted <- sum(inv_cumulative_freq(res))