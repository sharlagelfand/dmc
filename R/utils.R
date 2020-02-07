check_color <- function(color) {
  if (missing(color)) {
    stop("`color` is missing, with no default.",
      call. = FALSE
    )
  } else if (!is.vector(color) | length(color) != 1 | !inherits(color, "character")) {
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
  }
}

check_dmc <- function(dmc) {
  if (!(dmc %in% dmc::floss[["dmc"]])) {
    stop('`dmc` is not a valid DMC floss identifier.\nSee floss[["dmc"]] for the full list of DMC colors.',
      call. = FALSE
    )
  }
}
