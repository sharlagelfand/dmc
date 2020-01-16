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

# Print method very heavily inspired/lifted from magick:::`print.magick-image`()

print.dmc <- function(x) {
  img <- x[["viz"]]
  df <- x[["floss"]]
  if (is.null(img)) {
    print(df)
  } else {
    is_knit_image <- isTRUE(getOption("knitr.in.progress"))
    if (isTRUE(getOption("jupyter.in_kernel"))) {
      print(df)
      magick:::jupyter_print_image(img)
    }
    else if (!is_knit_image && !magick:::magick_image_dead(img) && length(img)) {
      previewer <- getOption("magick.viewer")
      if (is.function(previewer)) {
        print(df)
        previewer(img)
      }
    }
    if (is_knit_image) {
      print(df)
      magick:::`knit_print.magick-image`(img)
    } else {
      invisible(x)
    }
  }
}
wrap_name <- function(x) {
  if (nchar(x) > 23) {
    stringr::str_replace(x, "- ", "-\n")
  } else {
    x
  }
}

dmc_viz <- function(color, closest_floss, n, method = c("dmc", "undmc")) {
  w <- h <- 150
  font <- 14

  blank_img <- magick::image_blank(width = (n + 1) * w * 1.1, height = h + 50, color = "white")

  if (method == "dmc") {
    color_img <- magick::image_blank(width = w, height = h, color = color)
    color_img <- magick::image_border(color_img, color = "black", geometry = "1x1")

    colors <- magick::image_composite(blank_img, color_img)
    colors <- magick::image_annotate(colors, color, size = font, color = "black", location = paste0("+0+", h * 1.05))
  } else if (method == "undmc") {
    colors <- blank_img
  }

  closest_floss_img <- closest_floss %>%
    dplyr::mutate(img = purrr::map(.data$hex, ~ magick::image_blank(width = w, height = h, color = .x) %>% magick::image_border(color = "black", geometry = "1x1")))

  for (i in 1:nrow(closest_floss_img)) {
    floss_i <- closest_floss_img[i, ]

    colors <- magick::image_composite(colors, floss_i[["img"]][[1]], offset = paste0("+", ifelse(method == "dmc", 1.1 * w * i, 0), "+0"))
    colors <- magick::image_annotate(colors, wrap_name(paste0(floss_i[["dmc"]], " (", floss_i[["name"]], ")")), size = font, color = "black", location = paste0("+", ifelse(method == "dmc", 1.1 * w * i, 0), "+", h * 1.05))
  }

  colors
}

