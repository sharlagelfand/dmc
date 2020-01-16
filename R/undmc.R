#' Return the hex code and RGB values of a given DMC embroidery floss
#'
#' @param dmc DMC floss identifier. Usually the floss number (e.g. 210), or the name if it does not commonly have a number (e.g. "Ecru").
#' @param visualize Whether to visualize the DMC floss color. Defaults to TRUE.
#'
#' @export
#'
#' @examples
#' undmc("Ecru")
#' undmc(310)
#' undmc(c(210, 211))
undmc <- function(dmc, visualize = TRUE) {
  floss <- dplyr::filter(
    floss,
    .data$dmc %in% !!dmc
  )

  if (visualize){
  viz <- dmc_viz(floss[["hex"]], floss, n = 0, method = "undmc")
  }
  else {
    viz <- NULL
  }

  res <- list(floss = floss,
              viz = viz)
  class(res) <- "dmc"

  print.dmc(res)
}
