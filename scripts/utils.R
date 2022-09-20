# package loading ----

suppressMessages(library(dplyr))
library(magrittr)
suppressMessages(library(ggplot2))
library(cowplot)
suppressMessages(library(rstan))
suppressMessages(library(sf))
library(tidybayes)
library(rstan)

# functions ----

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

individual_freq <- function(x) {
  hist(log(x), plot = FALSE, n = 100) %>%
    {
      data.frame(x = .$breaks[-1], samples = log(.$counts))
    }
}

#' (dt <- sample(1:10, 12, replace = TRUE) %>% .[order(.)])
#' (cf <- cumulative_freq(dt))
cumulative_freq <- function(x) {
  l_n <- cumsum(rev(table(x)))
  l_area <- rev(as.numeric(names(table(x))))

  data.frame(area = l_area, number = l_n)
}

#' inv_cumulative_freq(cf)
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
  is_assignment <- sapply(
    is_assignment,
    function(x) ifelse(is.na(x), FALSE, TRUE)
  )
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
