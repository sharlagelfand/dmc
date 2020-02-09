# dmc

test_that("dmc returns an object of class dmc_df (+ tibble classes) with visualization attribute of class magick-image", {
  x <- dmc("#000000")
  expect_s3_class(x, c("dmc_df", "tbl_df", "tbl", "data.frame"))
  expect_s3_class(attr(x, "visualization"), "magick-image")
})

# undmc
test_that("undmc returns an object of class dmc_df (+ tibble classes) with visualization attribute", {
  x <- undmc("Ecru")
  expect_s3_class(x, c("dmc_df", "tbl_df", "tbl", "data.frame"))
  expect_s3_class(attr(x, "visualization"), "magick-image")
})

test_that("undmc returns in the same order as supplied", {
  x <- c("Ecru", "B5200")
  res <- undmc(x)
  expect_equal(res[["dmc"]], x)
  x <- rev(x)
  res <- undmc(x)
  expect_equal(res[["dmc"]], x)
}
)

test_that("the visualization attribute is of class magick-image if visualize = TRUE and doesn't exist if it's false", {
  expect_s3_class(attr(undmc(310, visualize = TRUE), "visualization"), "magick-image")
  expect_null(attr(undmc(310, visualize =  FALSE), "visualization"))
})

test_that("wrap_name wraps the floss name if it is more than 23 characters", {
  name <- "Antique Mauve - Medium Dark"
  expect_true(nchar(name) > 23)
  expect_true(stringr::str_detect(wrap_name(name), "\n"))
})
