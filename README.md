
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dmc

<!-- badges: start -->

<!-- badges: end -->

This package is a work in progress\!

The goal of dmc is to allow you to find the closest DMC embroidery floss
color(s) for a given color, as well as access color (hex, RGB)
information about DMC colors.

## Installation

You can install the development version of dmc from github with:

``` r
# install.packages(devtools)
devtools::install_github("sharlagelfand/dmc")
```

## Example

Say I’m interested in finding the closest DMC floss color for the
background color of the [`dplyr` package’s hex
logo](https://github.com/tidyverse/dplyr/blob/master/man/figures/logo.png)
😈.

I can look up the hex code for this color via a site like [HTML Color
Codes](https://html-color-codes.info/colors-from-image/). The hex code
is “\#EE8726”.

Then, I can use `dmc()` to find the closest DMC floss for this color:

``` r
library(dmc)

dplyr_background <- "#EE8726"

dmc(dplyr_background)
#> # A tibble: 1 x 6
#>   dmc   name          hex       red green  blue
#>   <chr> <chr>         <chr>   <dbl> <dbl> <dbl>
#> 1 970   Pumpkin Light #F78B13   247   139    19
```

![](man/figures/README-dmc-dplyr-1.png)<!-- -->

I can choose to show more than one matching color:

``` r
dmc(dplyr_background, n = 3)
#> # A tibble: 3 x 6
#>   dmc   name             hex       red green  blue
#>   <chr> <chr>            <chr>   <dbl> <dbl> <dbl>
#> 1 970   Pumpkin Light    #F78B13   247   139    19
#> 2 922   Copper Light     #E27323   226   115    35
#> 3 721   Orange Spice Med #F27842   242   120    66
```

![](man/figures/README-dmc-dplyr-3-1.png)<!-- -->

And to turn off the visualization of the colors:

``` r
dmc(dplyr_background, visualize = FALSE)
#> # A tibble: 1 x 6
#>   dmc   name          hex       red green  blue
#>   <chr> <chr>         <chr>   <dbl> <dbl> <dbl>
#> 1 970   Pumpkin Light #F78B13   247   139    19
```

If I want to go the *other* way and just find the hex/RGB information
for a given DMC floss, I can use `undmc()`.

``` r
undmc("Ecru")
#> # A tibble: 1 x 6
#>   dmc   name  hex       red green  blue
#>   <chr> <chr> <chr>   <dbl> <dbl> <dbl>
#> 1 Ecru  Ecru  #F0EADA   240   234   218
undmc(310)
#> # A tibble: 1 x 6
#>   dmc   name  hex       red green  blue
#>   <chr> <chr> <chr>   <dbl> <dbl> <dbl>
#> 1 310   Black #﻿000000     0     0     0
```

This mostly just takes the DMC floss number, except in cases where there
isn’t one (e.g., Ecru).

A full list of floss colors in the package is available via `floss`:

``` r
floss
#> # A tibble: 454 x 6
#>    dmc   name                  hex       red green  blue
#>    <chr> <chr>                 <chr>   <dbl> <dbl> <dbl>
#>  1 150   Dusty Rose Ult Vy Dk  #AB0249   171     2    73
#>  2 151   Dusty Rose Vry Lt     #F0CED4   240   206   212
#>  3 152   Shell Pink Med Light  #E2A099   226   160   153
#>  4 153   Violet Very Light     #E6CCD9   230   204   217
#>  5 154   Grape Very Dark       #572433    87    36    51
#>  6 155   Blue Violet Med Dark  #9891B6   152   145   182
#>  7 156   Blue Violet Med Lt    #A3AED1   163   174   209
#>  8 157   Cornflower Blue Vy Lt #BBC3D9   187   195   217
#>  9 158   Cornflower Blu M V D  #4C526E    76    82   110
#> 10 159   Blue Gray Light       #C7CAD7   199   202   215
#> # … with 444 more rows
```

where the values in `floss[["dmc"]]` are all that can be passed to
`undmc()`.
