source("scripts/utils.R")

res <- readRDS("data/res.rds")
cf_extra <- readRDS("data/cf_extra.rds")

# ---- frequentist_uncertainty ----
stack_preds <- c(res$density[seq_len(nrow(cf_extra))],
  res$lower[seq_len(nrow(cf_extra))],
  res$upper[seq_len(nrow(cf_extra))])
stack_preds <- data.frame(preds = stack_preds,
  area  = rep(res$area[seq_len(nrow(cf_extra))], times = 3),
  type  = rep(c("50", "2.5", "97.5"),
    each = nrow(cf_extra)))
# res$number_lower[(nrow(cf_extra) + 1):nrow(res)] <-
#   res$number_upper[(nrow(cf_extra) + 1):nrow(res)] <-
#   res$number[(nrow(cf_extra) + 1):nrow(res)]

frequentist_uncertainty <- ggplot() +
  geom_line(data = stack_preds, aes(x = area, y = preds, color = type)) +
  scale_x_log10() + xlab("density") + labs(color = "Confidence \n Interval")

ggsave("manuscript/figures/frequentist_uncertainty-1.pdf",
  frequentist_uncertainty, width = 5.93, height = 2.33)