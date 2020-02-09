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
  expect_s3_class(attr(x, "visualization"), "magick-image")
  expect_equal(capture_output(print(x)), "# A tibble: 1 x 6\n  dmc   name  hex       red green  blue\n  <chr> <chr> <chr>   <dbl> <dbl> <dbl>\n1 310   Black #000000     0     0     0")
})

test_that("if knitr is in progress, print.dmc_df returns the df AND the visualization via knitr::include_graphics which converts to ![]() in the md", {
  skip_on_cran()
  rmd_lines <- c("```{r}\n", "library(dmc)\n", "dmc('#000000')\n", "```")
  tmp_file <- tempfile()
  tmp_file_rmd <- paste0(tmp_file, ".rmd")
  tmp_file_md <- paste0(tmp_file, ".md")
  cat(rmd_lines, file = tmp_file_rmd)
  knitr::knit(tmp_file_rmd, output = tmp_file_md)
  output <- readLines(tmp_file_md)
  expect_equal(output, c("", "```r", " library(dmc)", " dmc('#000000')",
                         "```", "", "```", "## # A tibble: 1 x 6", "##   dmc   name  hex       red green  blue",  "##   <chr> <chr> <chr>   <dbl> <dbl> <dbl>", "## 1 310   Black #000000     0     0     0", "```", "","![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-1-1.png)"))
  file.remove(tmp_file_rmd)
  file.remove(tmp_file_md)
})
