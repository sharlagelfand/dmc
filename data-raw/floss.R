# Creating data set of floss colors

library(dplyr)
library(stringr)
library(janitor)
library(purrr)
library(readr)

# Source: https://github.com/adrianj/CrossStitchCreator/
floss_adrianj <- read_csv("data-raw/floss_adrianj.csv") %>%
  clean_names() %>%
  select(-row)

# Cleaning floss data ----

## Hex code mangled by Excel ----
floss_adrianj %>%
  filter(nchar(rgb_code) != 6)

floss_adrianj <- floss_adrianj %>%
  mutate(
    rgb_code = case_when(
      floss_number == "221" ~ "883E43",
      floss_number == "910" ~ "187E56",
      floss_number == "699" ~ "056517",
      floss_number == "869" ~ "835E39",
      floss_number == "310" ~ "000000",
      floss_number == "434" ~ "985E33",
      TRUE ~ rgb_code
    ),
    rgb_code = paste0("#", rgb_code)
  )

## RBG doesn't match hex code ---
wrong_rgb_to_hex <- floss_adrianj %>%
  mutate(hex = rgb(red, green, blue, max = 255)) %>%
  filter(rgb_code != hex)

wrong_rgb_to_hex

# Trial and error of looking up floss + different hex codes to decide which looks right
wrong_rgb_to_hex_fixed <- wrong_rgb_to_hex %>%
  mutate(
    correct_hex = case_when(
      floss_number == "309" ~ "#BA4A4A",
      floss_number == "3609" ~ "#F4AED5",
      floss_number == "225" ~ "#FFDFD5",
      floss_number == "210" ~ "#C39FC3",
      floss_number == "3755" ~ "#93B4CE",
      floss_number == "3849" ~ "#52B3AE",
      floss_number == "3848" ~ "#419392",
      floss_number == "890" ~ "#174923",
      floss_number == "3830" ~ "#B95544"
    ),
    rgb = map(correct_hex, ~ c(col2rgb(.x))),
    red_new = map_dbl(rgb, 1),
    green_new = map_dbl(rgb, 2),
    blue_new = map_dbl(rgb, 3)
  ) %>%
  select(floss_number, correct_hex, red_new, green_new, blue_new)

floss_adrianj <- floss_adrianj %>%
  left_join(wrong_rgb_to_hex_fixed, by = "floss_number") %>%
  mutate(
    rgb_code = coalesce(correct_hex, rgb_code),
    red = coalesce(red_new, red),
    green = coalesce(green_new, green),
    blue = coalesce(blue_new, blue)
  ) %>%
  select(-correct_hex, -contains("_new"))

floss_adrianj %>%
  mutate(hex = rgb(red, green, blue, max = 255)) %>%
  filter(rgb_code != hex)

# Fix floss names ----

word_boundary <- function(word) {
  paste0("\\b", word, "\\b")
}

clean_floss_name <- function(name) {
  name %>%
    str_replace_all(word_boundary("Ult"), "Ultra") %>%
    str_replace_all(word_boundary("Vy"), "Very") %>%
    str_replace_all(word_boundary("Dk"), "Dark") %>%
    str_replace_all(word_boundary("Med"), "Medium") %>%
    str_replace_all(word_boundary("Lt"), "Light") %>%
    str_replace_all(word_boundary("Vry"), "Very") %>%
    str_replace_all(word_boundary("Md"), "Medium") %>%
    str_replace_all(word_boundary("M"), "Medium") %>%
    str_replace_all(word_boundary("V"), "Very") %>%
    str_replace_all(word_boundary("D"), "Dark") %>%
    str_replace_all(word_boundary("VD"), "Very Dark") %>%
    str_replace_all(word_boundary("VyDk"), "Very Dark") %>%
    str_replace_all(word_boundary("Grn"), "Green") %>%
    str_replace_all(word_boundary("Brn"), "Brown") %>%
    str_replace_all(word_boundary("U"), "Ultra") %>%
    str_replace_all("\\?", " ")
}

sep_description <- function(x, description) {
  str_replace(x, description, paste("-", description))
}

separate_color_description <- function(name) {
  case_when(
    str_detect(name, "Ultra Very Light") ~ sep_description(name, "Ultra Very Light"),
    str_detect(name, "Ultra Very Dark") ~ sep_description(name, "Ultra Very Dark"),
    str_detect(name, "Medium Very Light") ~ sep_description(name, "Medium Very Light"),
    str_detect(name, "Medium Very Dark") ~ sep_description(name, "Medium Very Dark"),
    str_detect(name, "Medium Light") ~ sep_description(name, "Medium Light"),
    str_detect(name, "Medium Dark") ~ sep_description(name, "Medium Dark"),
    str_detect(name, "Ultra Light") ~ sep_description(name, "Ultra Light"),
    str_detect(name, "Ultra Pale") ~ sep_description(name, "Ultra Pale"),
    str_detect(name, "Ultra Dark") ~ sep_description(name, "Ultra Dark"),
    str_detect(name, "Very Light") ~ sep_description(name, "Very Light"),
    str_detect(name, "Very Dark") ~ sep_description(name, "Very Dark"),
    str_detect(name, "Pale Light$") ~ sep_description(name, "Pale Light"),
    str_detect(name, "Light$") ~ sep_description(name, "Light"),
    str_detect(name, "Pale$") ~ sep_description(name, "Pale"),
    str_detect(name, "Medium$") ~ sep_description(name, "Medium"),
    str_detect(name, "Dark$") ~ sep_description(name, "Dark"),
    str_detect(name, "Bright$") ~ sep_description(name, "Bright"),
    str_detect(name, "Deep$") ~ sep_description(name, "Deep"),
    TRUE ~ name
  )
}

floss_adrianj <- floss_adrianj %>%
  mutate(
    description = str_squish(description),
    description = clean_floss_name(description),
    description = separate_color_description(description)
  )

# Some manual cleaning - some are just wrong!
floss_adrianj <- floss_adrianj %>%
  mutate(description = case_when(
    floss_number == "666" ~ "Red - Bright",
    floss_number == "3846" ~ "Turquoise - Light Bright",
    floss_number == "3845" ~ "Turquoise - Medium Bright",
    floss_number == "3844" ~ "Turquoise - Dark Bright",
    floss_number == "311" ~ "Navy Blue - Medium",
    floss_number == "943" ~ "Aquamarine - Medium",
    floss_number == "890" ~ "Pistachio Green - Ultra Dark",
    floss_number == "934" ~ "Avocado Green - Black",
    floss_number == "966" ~ "Baby Green - Medium",
    floss_number == "561" ~ "Jade - Very Dark",
    floss_number == "608" ~ "Orange - Bright",
    floss_number == "407" ~ "Desert Sand - Dark",
    floss_number == "3773" ~ "Desert Sand - Medium",
    TRUE ~ description),
    description = str_replace(description, "Blue Gray", "Gray Blue"),
    description = str_replace_all(description, "Sea Green", "Seagreen")
  )

floss <- floss_adrianj %>%
  select(dmc = floss_number,
         name = description,
         hex = rgb_code,
         red,
         green,
         blue)

usethis::use_data(floss, overwrite = TRUE)
