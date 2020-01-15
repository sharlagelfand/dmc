# Floss colours found via https://github.com/adrianj/CrossStitchCreator

floss <- readr::read_csv("data-raw/dmc_floss.csv")
floss[["hex"]] <- paste0("#", floss[["hex"]])

usethis::use_data(floss, overwrite = TRUE)
