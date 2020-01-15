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
  color_rgb <- grDevices::col2rgb(color)
  color_rgb <- c(color_rgb)

  floss_dists <- floss %>%
    dplyr::mutate(dist = purrr::pmap_dbl(list(.data$red, .data$green, .data$blue), floss_dist, rgb = color_rgb))

  closest_floss <- floss_dists %>%
    dplyr::arrange(.data$dist) %>%
    dplyr::select(-.data$dist) %>%
    dplyr::slice(1:n)

  if (visualize) {
    viz <- dmc_viz(color, closest_floss, n)
  } else {
    viz <- NULL
  }

  res <- list(closest_floss = closest_floss,
              viz = viz)
  class(res) <- "dmc"

  print.dmc(res)
}

floss_dist <- function(red, green, blue, rgb) {
  floss_rgb <- c(red, green, blue)
  sum((rgb - floss_rgb)^2)
}

dmc_viz <- function(color, closest_floss, n) {
  w <- h <- 150
  font <- 14

  blank_img <- magick::image_blank(width = (n + 1) * w * 1.1, height = h + 25, color = "white")

  color_img <- magick::image_blank(width = w, height = h, color = color)
  color_img <- magick::image_border(color_img, color = "black", geometry = "1x1")

  colors <- magick::image_composite(blank_img, color_img)
  colors <- magick::image_annotate(colors, color, size = font, color = "black", location = paste0("+0+", h*1.05))

  closest_floss_img <- closest_floss %>%
    dplyr::mutate(img = purrr::map(.data$hex, ~ magick::image_blank(width = w, height = h, color = .x) %>% magick::image_border(color = "black", geometry = "1x1")))

  for (i in 1:nrow(closest_floss_img)) {
    floss_i <- closest_floss_img[i, ]

    colors <- magick::image_composite(colors, floss_i[["img"]][[1]], offset = paste0("+", 1.1 * w * i, "+0"))
    colors <- magick::image_annotate(colors, paste0(floss_i[["dmc"]], " (", floss_i[["name"]], ")"), size = font, color = "black", location = paste0("+", 1.1 * w * i, "+", h*1.05))
  }

  colors
}

# Print method very heavily inspired/lifted from magick:::`print.magick-image`()

print.dmc <- function(x) {
  img <- x[["viz"]]
  df <- x[["closest_floss"]]
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
  }
  else invisible(df)
  }
}
