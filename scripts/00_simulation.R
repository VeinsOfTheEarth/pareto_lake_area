# pareto_demo ----
# setwd("scripts")
source("scripts/utils.R")

set.seed(234)

# simulate random pareto draws
# unlink("../data/y.rds")
if (!file.exists("data/y.rds")) {
  y_raw <- rpareto(153000, max = 81935.7) # cap at the area of Lake Superior
  y_individual <- mutate(individual_freq(y_raw), name = "simulated")
  y_cumulative <- mutate(cumulative_freq(y_raw), name = "simulated")

  y <- list(
    y_raw = y_raw,
    y_individual = y_individual,
    y_cumulative = y_cumulative)
  saveRDS(y, "data/y.rds")
}
y <- readRDS("data/y.rds")

# read-in hydrolakes data
# unlink("../data/hydrolakes.rds")
if (!file.exists("data/hydrolakes.rds")) {
  data_path_hydrolakes <- config("config.py")$data_path_hydrolakes
  data_path_hydrolakes <- file.path(data_path_hydrolakes,
    "HydroLAKES_polys_v10_shp", "HydroLAKES_polys_v10.shp")
  area_hydrolakes <- st_read(data_path_hydrolakes,
    query = "SELECT Lake_area FROM \"HydroLAKES_polys_v10\"", quiet = TRUE) %>%
    st_drop_geometry()
  hydrolakes_raw <- area_hydrolakes$Lake_area
  hydrolakes_individual <- mutate(
    individual_freq(hydrolakes_raw), name = "hydrolakes")
  hydrolakes_cumulative <- mutate(
    cumulative_freq(hydrolakes_raw), name = "hydrolakes")

  hydrolakes <- list(
    hydrolakes_raw = hydrolakes_raw,
    hydrolakes_individual = hydrolakes_individual,
    hydrolakes_cumulative = hydrolakes_cumulative)
  saveRDS(hydrolakes, "data/hydrolakes.rds")
}
hydrolakes <- readRDS("data/hydrolakes.rds")

gg_individual <- rbind(y$y_individual, hydrolakes$hydrolakes_individual) %>%
  ggplot() +
  geom_line(aes(x, samples, color = name)) +
  ylab("log(n)") + xlab("log(area)") +
  theme_minimal() +
  theme(legend.position = "none")

gg_cumulative <- rbind(y$y_cumulative, hydrolakes$hydrolakes_cumulative) %>%
  ggplot() +
  geom_line(aes(area, number, color = name)) +
  theme_minimal() + scale_x_log10() + scale_y_log10() +
  ylab("n > area") + xlab("area") +
  labs(color = "")

pareto_demo <- plot_grid(gg_individual, gg_cumulative,
  nrow = 1, rel_widths = c(0.68, 1))

dir.create("manuscript/figures", showWarnings = FALSE)
ggsave("manuscript/figures/pareto_demo-1.pdf", pareto_demo,
  width = 5.93, height = 2.33)