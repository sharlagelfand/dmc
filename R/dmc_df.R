new_dmc_df <- function(dmc = tibble::tibble(), viz = NULL) {
  stopifnot(tibble::is_tibble(dmc))
  stopifnot(is.null(viz) | inherits(viz, "magick-image"))

  tibble::new_tibble(
    dmc,
    nrow = nrow(dmc),
    class = "dmc_df",
    visualization = viz
  )
}

#' @export
print.dmc_df <- function(x, ...) {
  NextMethod(x)

  img <- attr(x, "visualization")
  if (!is.null(img)) {
    is_knit_image <- isTRUE(getOption("knitr.in.progress"))
    if (is_knit_image) {
      magick:::`knit_print.magick-image`(img)
    } else if (!is_knit_image) {
      print(img, info = FALSE)
    }
  }
}
