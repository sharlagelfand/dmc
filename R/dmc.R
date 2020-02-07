#' Find the closest DMC embroidery floss for a given color
#'
#' @param color A hex code to identify the color, e.g. "#EE8726"
#' @param n Number of DMC floss colors to return. Defaults to 1.
#' @param visualize Whether to visualize \code{color} versus the closest DMC floss color(s). Defaults to TRUE.
#' @param method Method for comparing colors. Defaults to "euclidean".
#'
#' @export
#'
#' @examples
#' dmc("#EE8726")
dmc <- function(color, n = 1, visualize = TRUE, method = c("euclidean", "cie94")) {
  method <- match.arg(method)
  .dmc(color = color, n = n, visualize = visualize, dmc_method = "dmc", method = method)
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
  .dmc(color = dmc, n = 0, visualize = visualize, dmc_method = "undmc")
}

.dmc <- function(color, n, visualize, dmc_method, method = NULL) {
  if (dmc_method == "dmc") {
    check_n(n)
    check_color(color)
  } else if (dmc_method == "undmc") {
    check_dmc(color)
  }

  if (dmc_method == "dmc") {
    color_rgb <- farver::decode_colour(color)

    floss_dists <- dmc::floss %>%
      dplyr::mutate(
        rgb = purrr::pmap(list(.data$red, .data$green, .data$blue), c),
        dist = purrr::map_dbl(rgb, function(x) {
          colour_matrix <- matrix(x, ncol = 3)
          farver::compare_colour(from = colour_matrix, to = color_rgb, from_space = "rgb", method = method)
        })
      ) %>%
      dplyr::select(-rgb)

    floss_match <- floss_dists %>%
      dplyr::arrange(.data$dist) %>%
      dplyr::select(-.data$dist) %>%
      dplyr::slice(1:n)
  } else if (dmc_method == "undmc") {
    floss_match <- dmc::floss %>%
      dplyr::filter(
        .data$dmc %in% color
      )
    color <- floss_match[["hex"]]
  }

  if (visualize) {
    viz <- dmc_viz(color, floss_match, n = n, dmc_method = dmc_method)
  } else {
    viz <- NULL
  }

  new_dmc_df(floss_match, viz)
}

wrap_name <- function(x) {
  if (nchar(x) > 23) {
    stringr::str_replace(x, "- ", "-\n")
  } else {
    x
  }
}

dmc_viz <- function(color, closest_floss, n, dmc_method = c("dmc", "undmc")) {
  w <- h <- 150
  font <- 14

  blank_img <- magick::image_blank(width = (n + 1) * w * 1.1, height = h + 50, color = "white")

  if (dmc_method == "dmc") {
    color_img <- magick::image_blank(width = w, height = h, color = color)
    color_img <- magick::image_border(color_img, color = "black", geometry = "1x1")

    colors <- magick::image_composite(blank_img, color_img)
    colors <- magick::image_annotate(colors, color, size = font, color = "black", location = paste0("+0+", h * 1.05))
  } else if (dmc_method == "undmc") {
    colors <- blank_img
  }

  closest_floss_img <- closest_floss %>%
    dplyr::mutate(img = purrr::map(.data$hex, ~ magick::image_blank(width = w, height = h, color = .x) %>% magick::image_border(color = "black", geometry = "1x1")))

  for (i in 1:nrow(closest_floss_img)) {
    floss_i <- closest_floss_img[i, ]

    colors <- magick::image_composite(colors, floss_i[["img"]][[1]], offset = paste0("+", ifelse(dmc_method == "dmc", 1.1 * w * i, 0), "+0"))
    colors <- magick::image_annotate(colors, wrap_name(paste0(floss_i[["dmc"]], " (", floss_i[["name"]], ")")), size = font, color = "black", location = paste0("+", ifelse(dmc_method == "dmc", 1.1 * w * i, 0), "+", h * 1.05))
  }

  colors
}
