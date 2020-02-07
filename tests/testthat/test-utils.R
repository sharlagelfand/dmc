test_that("check_n throws error if n is not a length 1 positive integer", {
  expect_error(check_n(0), "positive integer")
  expect_error(check_n(c(1, 2)), "length 1")
})

test_that("check_dmc throws error if dmc is not in floss$dmc", {
  expect_error(check_dmc("Blanc"))
})

test_that("check_colour throws error if colour is not a length 1 character vector that starts with # and has 7 characters total", {
  c1 <- "#FFFFFF"
  c2 <- "#000000"
  colours <- c(c1, c1)
  expect_error(check_colour(), "no default")
  expect_error(check_colour(colours), "length 1 character vector")
  expect_error(check_colour(dplyr::tibble(c1)), "length 1 character vector")
  expect_error(check_colour(1), "length 1 character vector")
  expect_error(check_colour("FFFFFF#"), "hex code")
  expect_error(check_colour("FFFFFFF"), "hex code")
  expect_error(check_colour("FF"), "hex code")
})
