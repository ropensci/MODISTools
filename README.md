
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Build
Status](https://travis-ci.org/khufkens/MODISTools.svg)](https://travis-ci.org/khufkens/MODISTools)
[![codecov](https://codecov.io/gh/khufkens/MODISTools/branch/master/graph/badge.svg)](https://codecov.io/gh/khufkens/MODISTools)

# MODISTools

Programmatic interface to the [‘MODIS Land Products Subsets’ web
services](https://modis.ornl.gov/data/modis_webservice.html). Allows for
easy downloads of ‘MODIS’ time series directly to your R workspace or
your computer.

## Installation

### development release

To install the development releases of the package run the following
commands:

``` r
if(!require(devtools)){install.package("devtools")}
devtools::install_github("khufkens/MODISTools")
library("MODISTools")
```

Vignettes are not rendered by default, if you want to include additional
documentation please use:

``` r
if(!require(devtools)){install.package("devtools")}
devtools::install_github("khufkens/MODISTools", build_vignettes = TRUE)
library("MODISTools")
```

## Use

### Downloading MODIS time series

To extract a time series of modis data for a given location and its
direct environment use the get\_subset() function.

<details>

<summary>detailed parameter description (click to
expand)</summary>

<p>

| Parameter  | Description                                                                                                                     |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------- |
| product    | a MODIS product                                                                                                                 |
| band       | a MODIS product band (if NULL all bands are downloaded)                                                                         |
| lat        | latitude of the site                                                                                                            |
| lon        | longitude of the site                                                                                                           |
| start      | start year of the time series (data start in 1980)                                                                              |
| end        | end year of the time series (current year - 2 years, use force = TRUE to override)                                              |
| internal   | logical, TRUE or FALSE, if true data is imported into R workspace otherwise it is downloaded into the current working directory |
| out\_dir   | path where to store the data when not used internally, defaults to tempdir()                                                    |
| km\_lr     | force “out of temporal range” downloads (integer)                                                                               |
| km\_ab     | suppress the verbose output (integer)                                                                                           |
| site\_name | a site identifier                                                                                                               |
| site\_id   | a site\_id for predefined locations (not required)                                                                              |

</p>

</details>

``` r
# load the library
library(MODISTools)

# download data
subset <- get_subset(product = "MOD11A2",
                    lat = 40,
                    lon = -110,
                    band = "LST_Day_1km",
                    start = "2004-01-01",
                    end = "2004-02-01",
                    km_lr = 1,
                    km_ab = 1,
                    site_name = "testsite",
                    internal = TRUE)
head(subset)
#> $header
#> $header$xllcorner
#> [1] "-9370962.97"
#> 
#> $header$yllcorner
#> [1] "4446875.49"
#> 
#> $header$cellsize
#> [1] "926.62543305583381"
#> 
#> $header$nrows
#> [1] 3
#> 
#> $header$ncols
#> [1] 3
#> 
#> $header$band
#> [1] "LST_Day_1km"
#> 
#> $header$units
#> [1] "Kelvin"
#> 
#> $header$scale
#> [1] "0.02"
#> 
#> $header$latitude
#> [1] 40
#> 
#> $header$longitude
#> [1] -110
#> 
#> $header$site
#> [1] "testsite"
#> 
#> $header$product
#> [1] "MOD11A2"
#> 
#> $header$start
#> [1] "2004-01-01"
#> 
#> $header$end
#> [1] "2004-02-01"
#> 
#> $header$complete
#> [1] TRUE
#> 
#> 
#> $data
#>    modis_date calendar_date        band   tile     proc_date pixel  data
#> 1    A2004001    2004-01-01 LST_Day_1km h09v05 2015212185706     1 13135
#> 2    A2004009    2004-01-09 LST_Day_1km h09v05 2015212201022     1 13120
#> 3    A2004017    2004-01-17 LST_Day_1km h09v05 2015212213103     1 13350
#> 4    A2004025    2004-01-25 LST_Day_1km h09v05 2015213005429     1 13354
#> 5    A2004001    2004-01-01 LST_Day_1km h09v05 2015212185706     2 13123
#> 6    A2004009    2004-01-09 LST_Day_1km h09v05 2015212201022     2 13100
#> 7    A2004017    2004-01-17 LST_Day_1km h09v05 2015212213103     2 13324
#> 8    A2004025    2004-01-25 LST_Day_1km h09v05 2015213005429     2 13331
#> 9    A2004001    2004-01-01 LST_Day_1km h09v05 2015212185706     3 13098
#> 10   A2004009    2004-01-09 LST_Day_1km h09v05 2015212201022     3 13069
#> 11   A2004017    2004-01-17 LST_Day_1km h09v05 2015212213103     3 13288
#> 12   A2004025    2004-01-25 LST_Day_1km h09v05 2015213005429     3 13317
#> 13   A2004001    2004-01-01 LST_Day_1km h09v05 2015212185706     4 13127
#> 14   A2004009    2004-01-09 LST_Day_1km h09v05 2015212201022     4 13073
#> 15   A2004017    2004-01-17 LST_Day_1km h09v05 2015212213103     4 13336
#> 16   A2004025    2004-01-25 LST_Day_1km h09v05 2015213005429     4 13352
#> 17   A2004001    2004-01-01 LST_Day_1km h09v05 2015212185706     5 13098
#> 18   A2004009    2004-01-09 LST_Day_1km h09v05 2015212201022     5 13062
#> 19   A2004017    2004-01-17 LST_Day_1km h09v05 2015212213103     5 13297
#> 20   A2004025    2004-01-25 LST_Day_1km h09v05 2015213005429     5 13323
#> 21   A2004001    2004-01-01 LST_Day_1km h09v05 2015212185706     6 13082
#> 22   A2004009    2004-01-09 LST_Day_1km h09v05 2015212201022     6 13045
#> 23   A2004017    2004-01-17 LST_Day_1km h09v05 2015212213103     6 13271
#> 24   A2004025    2004-01-25 LST_Day_1km h09v05 2015213005429     6 13287
#> 25   A2004001    2004-01-01 LST_Day_1km h09v05 2015212185706     7 13113
#> 26   A2004009    2004-01-09 LST_Day_1km h09v05 2015212201022     7 13082
#> 27   A2004017    2004-01-17 LST_Day_1km h09v05 2015212213103     7 13309
#> 28   A2004025    2004-01-25 LST_Day_1km h09v05 2015213005429     7 13340
#> 29   A2004001    2004-01-01 LST_Day_1km h09v05 2015212185706     8 13099
#> 30   A2004009    2004-01-09 LST_Day_1km h09v05 2015212201022     8 13015
#> 31   A2004017    2004-01-17 LST_Day_1km h09v05 2015212213103     8 13290
#> 32   A2004025    2004-01-25 LST_Day_1km h09v05 2015213005429     8 13287
#> 33   A2004001    2004-01-01 LST_Day_1km h09v05 2015212185706     9 13081
#> 34   A2004009    2004-01-09 LST_Day_1km h09v05 2015212201022     9 13005
#> 35   A2004017    2004-01-17 LST_Day_1km h09v05 2015212213103     9 13272
#> 36   A2004025    2004-01-25 LST_Day_1km h09v05 2015213005429     9 13271
```

The output format is a nested list with the true data provided as a
*tidy* data frame, as shown above. When witten to a csv, when the
parameter ‘internal’ is set to FALSE, the same information is retained.
Data can be read back into the same format with the included
read\_subset() function (see below).

Note that when a a region is defined using km\_lr and km\_ab multiple
pixels might be returned. These are index using the ‘pixel’ column in
the data frame containing the time series data. The remote sensing
values are listed in the ‘data’ column. When no band is specified all
bands of a given product are returned, be mindful of the fact that
different bands might require different multipliers to represent their
true values.

To list all available products, bands for particular products and
temporal coverage see function descriptions below.

### Batch downloading MODIS time series

``` r
# create data frame with a site_name, lat and lon column
# holding the respective names of sites and their location
df <- data.frame("site_name" = paste("test",1:2))
df$lat <- 40
df$lon <- -110
  
# test batch download
subsets <- batch_subset(df = df,
                     product = "MOD11A2",
                     band = "LST_Day_1km",
                     internal = TRUE,
                     start = "2004-01-01",
                     end = "2004-03-31",
                     out_dir = "~")

print(str(subsets))
#> List of 2
#>  $ test 1:List of 2
#>   ..$ header:List of 15
#>   .. ..$ xllcorner: chr "-9370036.39"
#>   .. ..$ yllcorner: chr "4447802.08"
#>   .. ..$ cellsize : chr "926.62543305583381"
#>   .. ..$ nrows    : int 1
#>   .. ..$ ncols    : int 1
#>   .. ..$ band     : chr "LST_Day_1km"
#>   .. ..$ units    : chr "Kelvin"
#>   .. ..$ scale    : chr "0.02"
#>   .. ..$ latitude : num 40
#>   .. ..$ longitude: num -110
#>   .. ..$ site     : chr "test 1"
#>   .. ..$ product  : chr "MOD11A2"
#>   .. ..$ start    : chr "2004-01-01"
#>   .. ..$ end      : chr "2004-03-31"
#>   .. ..$ complete : logi TRUE
#>   ..$ data  :'data.frame':   12 obs. of  7 variables:
#>   .. ..$ modis_date   : chr [1:12] "A2004001" "A2004009" "A2004017" "A2004025" ...
#>   .. ..$ calendar_date: chr [1:12] "2004-01-01" "2004-01-09" "2004-01-17" "2004-01-25" ...
#>   .. ..$ band         : chr [1:12] "LST_Day_1km" "LST_Day_1km" "LST_Day_1km" "LST_Day_1km" ...
#>   .. ..$ tile         : chr [1:12] "h09v05" "h09v05" "h09v05" "h09v05" ...
#>   .. ..$ proc_date    : chr [1:12] "2015212185706" "2015212201022" "2015212213103" "2015213005429" ...
#>   .. ..$ pixel        : chr [1:12] "1" "1" "1" "1" ...
#>   .. ..$ data         : int [1:12] 13098 13062 13297 13323 13315 13227 13739 13783 14748 15105 ...
#>   ..- attr(*, "class")= chr "MODISTools"
#>  $ test 2:List of 2
#>   ..$ header:List of 15
#>   .. ..$ xllcorner: chr "-9370036.39"
#>   .. ..$ yllcorner: chr "4447802.08"
#>   .. ..$ cellsize : chr "926.62543305583381"
#>   .. ..$ nrows    : int 1
#>   .. ..$ ncols    : int 1
#>   .. ..$ band     : chr "LST_Day_1km"
#>   .. ..$ units    : chr "Kelvin"
#>   .. ..$ scale    : chr "0.02"
#>   .. ..$ latitude : num 40
#>   .. ..$ longitude: num -110
#>   .. ..$ site     : chr "test 2"
#>   .. ..$ product  : chr "MOD11A2"
#>   .. ..$ start    : chr "2004-01-01"
#>   .. ..$ end      : chr "2004-03-31"
#>   .. ..$ complete : logi TRUE
#>   ..$ data  :'data.frame':   12 obs. of  7 variables:
#>   .. ..$ modis_date   : chr [1:12] "A2004001" "A2004009" "A2004017" "A2004025" ...
#>   .. ..$ calendar_date: chr [1:12] "2004-01-01" "2004-01-09" "2004-01-17" "2004-01-25" ...
#>   .. ..$ band         : chr [1:12] "LST_Day_1km" "LST_Day_1km" "LST_Day_1km" "LST_Day_1km" ...
#>   .. ..$ tile         : chr [1:12] "h09v05" "h09v05" "h09v05" "h09v05" ...
#>   .. ..$ proc_date    : chr [1:12] "2015212185706" "2015212201022" "2015212213103" "2015213005429" ...
#>   .. ..$ pixel        : chr [1:12] "1" "1" "1" "1" ...
#>   .. ..$ data         : int [1:12] 13098 13062 13297 13323 13315 13227 13739 13783 14748 15105 ...
#>   ..- attr(*, "class")= chr "MODISTools"
#> NULL
```

### Listing products

To list all available products use the list\_products() function.

``` r
products <- list_products()
head(products)
#>    product
#> 1 MCD15A2H
#> 2 MCD15A3H
#> 3  MOD09A1
#> 4  MOD11A2
#> 5  MOD13Q1
#> 6 MOD15A2H
#>                                                                               description
#> 1        MODIS/Terra+Aqua Leaf Area Index/FPAR (LAI/FPAR)  8-Day L4 Global 500 m SIN Grid
#> 2         MODIS/Terra+Aqua Leaf Area Index/FPAR (LAI/FPAR) 4-Day L4 Global 500 m SIN Grid
#> 3                    MODIS/Terra Surface Reflectance (SREF) 8-Day L3 Global 500m SIN Grid
#> 4 MODIS/Terra Land Surface Temperature and Emissivity (LST) 8-Day L3 Global 1 km SIN Grid
#> 5                MODIS/Terra Vegetation Indices (NDVI/EVI) 16-Day L3 Global 250m SIN Grid
#> 6              MODIS/Terra Leaf Area Index/FPAR (LAI/FPAR) 8-Day L4 Global 500 m SIN Grid
#>   frequency resolution_meters
#> 1     8-Day               500
#> 2     4-Day               500
#> 3     8-Day               500
#> 4     8-Day              1000
#> 5    16-Day               250
#> 6     8-Day               500
```

### Listing bands

To list all available bands for a given product use the list\_bands()
function.

``` r
bands <- list_bands(product = "MOD11A2")
head(bands)
#> [1] "Clear_sky_days"   "Clear_sky_nights" "Day_view_angl"   
#> [4] "Day_view_time"    "Emis_31"          "Emis_32"
```

### listing dates

To list all available dates (temporal coverage) for a given product and
location use the list\_dates() function.

``` r
dates <- list_dates(product = "MOD11A2", lat = 42, lon = -110)
head(dates)
#>   modis_date calendar_date
#> 1   A2000049    2000-02-18
#> 2   A2000057    2000-02-26
#> 3   A2000065    2000-03-05
#> 4   A2000073    2000-03-13
#> 5   A2000081    2000-03-21
#> 6   A2000089    2000-03-29
```

### Reading and writing data from / to file

Data can be written to file using the write\_subset() function which
uses the following file format:

    [site_name]_[product]_[start]_[end].csv

The data can be read back into the original nested structed using
read\_subset().

``` r
# write the above file to disk
write_subset(df = subset,
             out_dir = tempdir())

# read the data back in
subset_disk <- read_subset(paste0(tempdir(),
                  "/testsite_MOD11A2_2004-01-01_2004-02-01.csv"))

# compare original to read from disk
identical(subset, subset_disk)
#> [1] TRUE
```
