test_that("new_dmc_df returns a list of class dmc_df, with elements dmc and viz.", {
  x <- new_dmc_df()
  expect_s3_class(x, "dmc_df")
  expect_equal(names(x), c("dmc", "viz"))
})

test_that("print.dmc_df only returns the df if there is no viz", {
  col <- "#000000"
  x <- dmc(col, visualize = FALSE)
  expect_s3_class(print(x), "tbl_df")
  expect_equal(capture_output(print(x)), "# A tibble: 1 x 6\n  dmc   name  hex       red green  blue\n  <chr> <chr> <chr>   <dbl> <dbl> <dbl>\n1 310   Black #000000     0     0     0")
})

test_that("print.dmc_df returns df and viz if there is one (and knitr is not in progress).", {
  col <- "#000000"
  x <- dmc(col)
  expect_equal(capture_output(print(x)), "# A tibble: 1 x 6\n  dmc   name  hex       red green  blue\n  <chr> <chr> <chr>   <dbl> <dbl> <dbl>\n1 310   Black #000000     0     0     0")
})
