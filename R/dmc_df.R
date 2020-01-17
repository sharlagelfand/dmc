new_dmc_df <- function(dmc = tibble::tibble(), viz = NULL) {
  stopifnot(tibble::is_tibble(dmc))
  stopifnot(is.null(viz) | inherits(viz, "magick-image"))

  structure(
    list(
      dmc = dmc,
      viz = viz
    ),
    class = "dmc_df"
  )
}

#' @export
print.dmc_df <- function(x, ...) {
  df <- x[["dmc"]]
  img <- x[["viz"]]
  if (is.null(img)) {
    print(df)
  } else {
    is_knit_image <- isTRUE(getOption("knitr.in.progress"))
    if (is_knit_image) {
      print(df)
      magick:::`knit_print.magick-image`(img)
    } else if (!is_knit_image) {
      print(df)
      print(img, info = FALSE)
    } else {
      invisible(x)
    }
  }
}
