test_that("floss_dist computes squared euclidean distance.", {
  red <- 1
  green <- 2
  blue <- 3
  rgb <- c(10, 20, 30)
  output <- (rgb[[1]] - red)^2 + (rgb[[2]] - green)^2 + (rgb[[3]] - blue)^2
  expect_equal(floss_dist(red, green, blue, rgb), output)
})

test_that("check_n throws error if n is not a length 1 positive integer", {
  expect_error(check_n(0), "positive integer")
  expect_error(check_n(c(1, 2)), "length 1")
})

test_that("check_dmc throws error if dmc is not in floss$dmc", {
  expect_error(check_dmc("Blanc"))
})

test_that("check_color throws error if color is not a length 1 character vector that starts with # and has 7 characters total", {
  c1 <- "#FFFFFF"
  c2 <- "#000000"
  colors <- c(c1, c1)
  expect_error(check_color(), "no default")
  expect_error(check_color(colors), "length 1 character vector")
  expect_error(check_color(dplyr::tibble(c1)), "length 1 character vector")
  expect_error(check_color(1), "length 1 character vector")
  expect_error(check_color("FFFFFF#"), "hex code")
  expect_error(check_color("FFFFFFF"), "hex code")
  expect_error(check_color("FF"), "hex code")
})
