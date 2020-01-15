#' Return the hex code and RGB values of a given DMC embroidery floss
#'
#' @param dmc DMC floss identifier (usually the number)
#'
#' @return
#' @export
#'
#' @examples
#' undmc("Ecru")
#' undmc(310)
undmc <- function(dmc) {
  matching_dmc <- dplyr::filter(
    floss,
    dmc == !!dmc
  )

  dplyr::select(matching_dmc, hex, red, green, blue)
}
