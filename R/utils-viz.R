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
