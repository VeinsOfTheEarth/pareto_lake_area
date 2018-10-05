# place any data preparation steps here

library(tidyr)

iris <- read.csv("data/iris.csv", stringsAsFactors = FALSE)
iris_tidy_path <- "data/iris_tidy.csv"
iris_tidy      <- tidyr::gather(iris, "variable", "value", -Species)
