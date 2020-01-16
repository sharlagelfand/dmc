#' Find the closest DMC embroidery floss for a given color
#'
#' @param color A hex code to identify the color, e.g. "#EE8726"
#' @param n Number of DMC floss colors to return. Defaults to 1.
#' @param visualize Whether to visualize \code{color} versus the closest DMC floss color(s). Defaults to TRUE.
#'
#' @export
#'
#' @examples
#' dmc("#EE8726")
dmc <- function(color, n = 1, visualize = TRUE) {
  .dmc(color = color, n = n, visualize = visualize, method = "dmc")
}


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
  .dmc(color = dmc, n = 0, visualize = visualize, method = "undmc")
}

.dmc <- function(color, n, visualize, method) {
  if (method == "dmc") {
    check_n(n)
    check_color(color)
  } else if (method == "undmc") {
    check_dmc(color)
  }

  if (method == "dmc") {
    color_rgb <- grDevices::col2rgb(color)
    color_rgb <- c(color_rgb)

    floss_dists <- dmc::floss %>%
      dplyr::mutate(dist = purrr::pmap_dbl(list(.data$red, .data$green, .data$blue), floss_dist, rgb = color_rgb))

    floss_match <- floss_dists %>%
      dplyr::arrange(.data$dist) %>%
      dplyr::select(-.data$dist) %>%
      dplyr::slice(1:n)
  } else if (method == "undmc") {
    floss_match <- dmc::floss %>%
      dplyr::filter(
        .data$dmc %in% color
      )
    color <- floss_match[["hex"]]
  }

  if (visualize) {
    viz <- dmc_viz(color, floss_match, n = n, method = method)
  } else {
    viz <- NULL
  }

  res <- list(
    floss = floss_match,
    viz = viz
  )
  class(res) <- "dmc"

  print.dmc(res)
}
