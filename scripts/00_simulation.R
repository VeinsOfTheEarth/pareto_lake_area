# ---- pareto_demo ----
# setwd("scripts")
source("utils.R")

set.seed(234)

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
  y_raw <- rpareto(153000, max = 81935.7) # cap at the area of Lake Superior
  saveRDS(y, "../data/y.rds")
}
#
y <- readRDS("../data/y.rds")

pareto_plot_prep <- function(x) {
  # x <- y
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
    ylab("log(n)") + xlab("log(area)") +
    theme_minimal() +
    theme(legend.position = "none")

  gg_cumulative <- ggplot(data = cumulative_binning) +
    geom_line(aes(area, number, color = name)) +
    theme_minimal() + scale_x_log10() + scale_y_log10() +
    ylab("n > area") + xlab("area") +
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