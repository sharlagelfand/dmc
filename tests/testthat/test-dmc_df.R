test_that("new_dmc_df returns an object of class dmc_df (+ tibble classes), with attribute visualization of class magick-image(if supplied, NULL if not)", {
  x <- new_dmc_df()
  expect_s3_class(x, c("dmc_df", "tbl_df", "tbl", "data.frame"))
  expect_null(attr(x, "visualization"))
  y <- new_dmc_df(viz = magick::image_blank(1, 1))
  expect_s3_class(y, "dmc_df")
  expect_s3_class(attr(y, "visualization"), "magick-image")
})

test_that("print.dmc_df only returns the df if there is no viz", {
  col <- "#000000"
  x <- dmc(col, visualize = FALSE)
  expect_equal(capture_output(print(x)), "# A tibble: 1 x 6\n  dmc   name  hex       red green  blue\n  <chr> <chr> <chr>   <dbl> <dbl> <dbl>\n1 310   Black #000000     0     0     0")
})

test_that("print.dmc_df returns df and viz if there is one (and knitr is not in progress).", {
  col <- "#000000"
  x <- dmc(col)
  expect_equal(capture_output(print(x)), "# A tibble: 1 x 6\n  dmc   name  hex       red green  blue\n  <chr> <chr> <chr>   <dbl> <dbl> <dbl>\n1 310   Black #000000     0     0     0")
})

# TODO: add test for visualization properly rendering in Rmd
