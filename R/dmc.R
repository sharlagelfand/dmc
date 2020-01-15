#' Find the closest DMC embroidery floss for a given color
#'
#' @param color A way to identify the color, either via a colour hex code or the RGB values.
#' @param n Number of DMC floss colors to return. Defaults to 1.
#' @param visualize Whether to visualize \code{color} versus the closest DMC floss colour(s). Defaults to TRUE.
#'
#' @return
#' @export
#'
#' @examples
dmc <- function(color, n = 1, visualize = TRUE) {
  hex <- grepl("#", color)
  if (hex) {
    hex_color <- color
    color <- col2rgb(color)
    color <- c(color)
  }

  floss_dists <- floss %>%
    dplyr::mutate(dist = purrr::pmap_dbl(list(red, green, blue), floss_dist, rgb = color))

  closest_floss <- floss_dists %>%
    dplyr::arrange(dist) %>%
    dplyr::select(-dist) %>%
    head(n)

  if (visualize) {
    w <- h <- 150
    blank_img <- magick::image_blank(width = (n + 1)*w*1.1, height = h + 25, color = "white")
    color_img <- magick::image_blank(width = w, height = h, color = hex_color)
    closest_floss_img <- closest_floss %>%
      dplyr::mutate(img = purrr::map(hex, ~ magick::image_blank(width = w, height = h, color = .x)))

    colors <- magick::image_composite(blank_img, color_img)
    colors <- magick::image_annotate(colors, hex_color, size = 12, color = "black", location = paste0("+0+", h))
    for (i in 1:nrow(closest_floss_img)) {
      floss_i <- closest_floss_img[i,]
      colors <- magick::image_composite(colors, floss_i[["img"]][[1]], offset = paste0("+", 1.1*w*i, "+0"))
      colors <- magick::image_annotate(colors, paste0(floss_i[["dmc"]], " (", floss_i[["name"]], ")"), size = 12, color = "black", location = paste0("+", 1.1*w*i, "+", h))
    }
    colors
  }

  #closest_floss

}

floss_dist <- function(red, green, blue, rgb) {
  floss_rgb <- c(red, green, blue)
  sum((rgb - floss_rgb)^2)
}
