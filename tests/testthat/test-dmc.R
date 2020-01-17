# dmc

test_that("dmc returns an object of class dmc_df with elements dmc and viz", {
  x <- dmc("#000000")
  expect_is(x, "dmc_df")
  expect_equal(names(x), c("dmc", "viz"))
})

# undmc
test_that("undmc returns an object of class dmc_df with elements dmc and viz", {
  x <- undmc("Ecru")
  expect_is(x, "dmc_df")
  expect_equal(names(x), c("dmc", "viz"))
})

test_that("undmc$viz is of class magick-image if visualize = TRUE and is NULL if it is false", {
  expect_s3_class(undmc(310, visualize = TRUE)[["viz"]], "magick-image")
  expect_null(undmc(310, visualize = FALSE)[["viz"]])
})

test_that("wrap_name wraps the floss name if it is more than 23 characters", {
  name <- "Antique Mauve - Medium Dark"
  expect_true(nchar(name) > 23)
  expect_true(stringr::str_detect(wrap_name(name), "\n"))
})
