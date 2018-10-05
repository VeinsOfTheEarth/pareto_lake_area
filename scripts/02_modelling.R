# setwd("scripts")
source("99_utils.R")
source("01_prepdata.R")

# ---- load_packages ----
library(broom)

# ---- iris_lm ----
fit <- lm(Sepal.Length ~ Petal.Length, data = iris)
broom::tidy(fit)
