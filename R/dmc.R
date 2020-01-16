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
  check_color(color)
  check_n(n)

  color_rgb <- grDevices::col2rgb(color)
  color_rgb <- c(color_rgb)

  floss_dists <- floss %>%
    dplyr::mutate(dist = purrr::pmap_dbl(list(.data$red, .data$green, .data$blue), floss_dist, rgb = color_rgb))

  closest_floss <- floss_dists %>%
    dplyr::arrange(.data$dist) %>%
    dplyr::select(-.data$dist) %>%
    dplyr::slice(1:n)

  if (visualize) {
    viz <- dmc_viz(color, closest_floss, n, method = "dmc")
  } else {
    viz <- NULL
  }

  res <- list(
    floss = closest_floss,
    viz = viz
  )
  class(res) <- "dmc"

  print.dmc(res)
}

floss_dist <- function(red, green, blue, rgb) {
  floss_rgb <- c(red, green, blue)
  sum((rgb - floss_rgb)^2)
}

check_color <- function(color) {
  if(missing(color)) {
    stop("`color` is missing, with no default.",
         call. = FALSE)
  } else if (!is.vector(color) | length(color) != 1 | !("character" %in% class(color))) {
    stop("`color` must be a length 1 character vector.",
      call. = FALSE
    )
  } else if (!grepl("^#", color) | nchar(color) != 7) {
    stop('`color` must be a hex code, e.g. with format "#FFFFFF".',
      call. = FALSE
    )
  }
}

check_n <- function(n) {
  if (length(n) != 1) {
    stop("`n` must be a length 1 positive integer vector.",
         call. = FALSE
    )
  } else if (!is.numeric(n) ||
             !(n %% 1 == 0) ||
             n <= 0 ||
             n == Inf) {
    stop("`n` must be a positive integer.",
         call. = FALSE
    )
  } else {
    n
  }
}
