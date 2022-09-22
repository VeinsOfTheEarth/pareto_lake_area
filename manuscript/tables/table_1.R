source("scripts/utils.R")
library(flextable)

y_raw <- readRDS("data/y.rds")$y_raw
total_empirical <- sum(inv_cumulative_freq(cumulative_freq(y_raw)))

res <- readRDS("data/res.rds")
total_predicted <- data.frame(
  q50 = sum(inv_cumulative_freq(res)),
  q5 = sum(inv_cumulative_freq(
    mutate(
      mutate(res, number_lower = coalesce(number_lower, number)),
      number = number_lower)
  )),
  q95 = sum(inv_cumulative_freq(
    mutate(
      mutate(res, number_upper = coalesce(number_upper, number)),
      number = number_upper)
  ))
)

area_bayes <- readRDS("data/area_bayes.rds")
conf_int <- quantile(area_bayes, probs = c(0.025, 0.5, .975))

format_mil <- function(x) {
  round(x / 1000000, 3)
}
# format_mil(res[2,]$Q5)

format_diff <- function(x) {
  round(x, 0)
}
# format_diff(conf_int[3] - conf_int[1])

tibble::tribble(
  ~name,        ~Q50, ~Q5, ~Q95, ~Q95minusQ5,
  "True",        format_mil(total_empirical), NA, NA, NA,
  "Frequentist", format_mil(total_predicted$q50), format_mil(total_predicted$q5), format_mil(total_predicted$q95), format_diff(total_predicted$q95 - total_predicted$q5),
  "Bayesian",    format_mil(conf_int[2]), format_mil(conf_int[1]), format_mil(conf_int[3]), format_diff(conf_int[3] - conf_int[1])
) %>%
  flextable() %>%
  colformat_num(na_str = "-")
