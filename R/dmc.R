#' Find the closest DMC embroidery floss for a given colour
#'
#' @param colour A hex code to identify the colour, e.g. "#EE8726"
#' @param n Number of DMC floss colours to return. Defaults to 1.
#' @param visualize Whether to visualize \code{colour} versus the closest DMC floss colour(s). Defaults to TRUE.
#' @param method Method for comparing colours. Defaults to "euclidean".
#'
#' @export
#'
#' @examples
#' dmc("#EE8726")
dmc <- function(colour, n = 1, visualize = TRUE, method = c("euclidean", "cie94")) {
  method <- match.arg(method)
  .dmc(colour = colour, n = n, visualize = visualize, dmc_method = "dmc", method = method)
}


#' Return the hex code and RGB values of a given DMC embroidery floss
#'
#' @param dmc DMC floss identifier. Usually the floss number (e.g. 210), or the name if it does not commonly have a number (e.g. "Ecru").
#' @param visualize Whether to visualize the DMC floss colour. Defaults to TRUE.
#'
#' @export
#'
#' @examples
#' undmc("Ecru")
#' undmc(310)
#' undmc(c(210, 211))
undmc <- function(dmc, visualize = TRUE) {
  .dmc(colour = dmc, n = 0, visualize = visualize, dmc_method = "undmc")
}

.dmc <- function(colour, n, visualize, dmc_method, method = NULL) {
  if (dmc_method == "dmc") {
    check_n(n)
    check_colour(colour)
  } else if (dmc_method == "undmc") {
    check_dmc(colour)
  }

  if (dmc_method == "dmc") {
    colour_rgb <- farver::decode_colour(colour)

    floss_dists <- dmc::floss %>%
      dplyr::mutate(
        rgb = purrr::pmap(list(.data$red, .data$green, .data$blue), c),
        dist = purrr::map_dbl(.data$rgb, function(x) {
          colour_matrix <- matrix(x, ncol = 3)
          farver::compare_colour(from = colour_matrix, to = colour_rgb, from_space = "rgb", method = method)
        })
      ) %>%
      dplyr::select(-.data$rgb)

    floss_match <- floss_dists %>%
      dplyr::arrange(.data$dist) %>%
      dplyr::select(-.data$dist) %>%
      dplyr::slice(1:n)
  } else if (dmc_method == "undmc") {
    floss_match <- dmc::floss %>%
      dplyr::filter(
        .data$dmc %in% colour
      )
    colour <- floss_match[["hex"]]
  }

  if (visualize) {
    viz <- dmc_viz(colour, floss_match, n = n, dmc_method = dmc_method)
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

dmc_viz <- function(colour, closest_floss, n, dmc_method = c("dmc", "undmc")) {
  w <- h <- 150
  font <- 14

  blank_img <- magick::image_blank(width = (n + 1) * w * 1.1, height = h + 50, color = "white")

  if (dmc_method == "dmc") {
    colour_img <- magick::image_blank(width = w, height = h, color = colour)
    colour_img <- magick::image_border(colour_img, color = "black", geometry = "1x1")

    colours <- magick::image_composite(blank_img, colour_img)
    colours <- magick::image_annotate(colours, colour, size = font, color = "black", location = paste0("+0+", h * 1.05))
  } else if (dmc_method == "undmc") {
    colours <- blank_img
  }

  closest_floss_img <- closest_floss %>%
    dplyr::mutate(img = purrr::map(.data$hex, ~ magick::image_blank(width = w, height = h, color = .x) %>% magick::image_border(color = "black", geometry = "1x1")))

  for (i in 1:nrow(closest_floss_img)) {
    floss_i <- closest_floss_img[i, ]

    colours <- magick::image_composite(colours, floss_i[["img"]][[1]], offset = paste0("+", ifelse(dmc_method == "dmc", 1.1 * w * i, 0), "+0"))
    colours <- magick::image_annotate(colours, wrap_name(paste0(floss_i[["dmc"]], " (", floss_i[["name"]], ")")), size = font, color = "black", location = paste0("+", ifelse(dmc_method == "dmc", 1.1 * w * i, 0), "+", h * 1.05))
  }

  colours
}
