test_that("check_color throws error if color is not a length 1 character vector that starts with # and has 7 characters total", {
  c1 <- "#FFFFFF"
  c2 <- "#000000"
  colors <- c(c1, c1)
  expect_error(check_color(colors), "length 1 character vector")
  expect_error(check_color(dplyr::tibble(c1)), "length 1 character vector")
  expect_error(check_color(1), "length 1 character vector")
  expect_error(check_color("FFFFFF#"), "hex code")
  expect_error(check_color("FFFFFFF"), "hex code")
  expect_error(check_color("FF"), "hex code")
  expect_silent(check_color(c1))
})
