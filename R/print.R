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
    }
    else {
      invisible(df)
    }
  }
}
