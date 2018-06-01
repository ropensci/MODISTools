
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Build
Status](https://travis-ci.org/khufkens/MODISTools.svg)](https://travis-ci.org/khufkens/MODISTools)
[![codecov](https://codecov.io/gh/khufkens/MODISTools/branch/master/graph/badge.svg)](https://codecov.io/gh/khufkens/MODISTools)

# MODISTools

Programmatic interface to the [‘MODIS Land Products Subsets’ web
services](https://modis.ornl.gov/data/modis_webservice.html). Allows for
easy downloads of [‘MODIS’](http://modis.gsfc.nasa.gov/) time series
directly to your R workspace or your computer. When using the package
please cite the manuscript as referenced below.

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
print(str(subset))
#> List of 2
#>  $ header:List of 15
#>   ..$ xllcorner: chr "-9370962.97"
#>   ..$ yllcorner: chr "4446875.49"
#>   ..$ cellsize : chr "926.62543305583381"
#>   ..$ nrows    : int 3
#>   ..$ ncols    : int 3
#>   ..$ band     : chr "LST_Day_1km"
#>   ..$ units    : chr "Kelvin"
#>   ..$ scale    : chr "0.02"
#>   ..$ latitude : num 40
#>   ..$ longitude: num -110
#>   ..$ site     : chr "testsite"
#>   ..$ product  : chr "MOD11A2"
#>   ..$ start    : chr "2004-01-01"
#>   ..$ end      : chr "2004-02-01"
#>   ..$ complete : logi TRUE
#>  $ data  :'data.frame':  36 obs. of  7 variables:
#>   ..$ modis_date   : chr [1:36] "A2004001" "A2004009" "A2004017" "A2004025" ...
#>   ..$ calendar_date: chr [1:36] "2004-01-01" "2004-01-09" "2004-01-17" "2004-01-25" ...
#>   ..$ band         : chr [1:36] "LST_Day_1km" "LST_Day_1km" "LST_Day_1km" "LST_Day_1km" ...
#>   ..$ tile         : chr [1:36] "h09v05" "h09v05" "h09v05" "h09v05" ...
#>   ..$ proc_date    : chr [1:36] "2015212185706" "2015212201022" "2015212213103" "2015213005429" ...
#>   ..$ pixel        : chr [1:36] "1" "1" "1" "1" ...
#>   ..$ data         : int [1:36] 13135 13120 13350 13354 13123 13100 13324 13331 13098 13069 ...
#>  - attr(*, "class")= chr "MODISTools"
#> NULL
```

The output format is a nested list with the true data provided as a
*tidy* data frame, as shown above. When witten to a csv, when the
parameter ‘internal’ is set to FALSE, the same information is retained.
Data can be read back into the same format with the included
read\_subset() function (see below).

Note that when a a region is defined using km\_lr and km\_ab multiple
pixels might be returned. These are indexed using the ‘pixel’ column in
the data frame containing the time series data. The remote sensing
values are listed in the ‘data’ column. When no band is specified all
bands of a given product are returned, be mindful of the fact that
different bands might require different multipliers to represent their
true values.

To list all available products, bands for particular products and
temporal coverage see function descriptions below.

### Batch downloading MODIS time series

Below an example is provided on how to batch download data for a data
frame of given site names and locations (lat / lon).

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
                     end = "2004-02-01",
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
#>   .. ..$ end      : chr "2004-02-01"
#>   .. ..$ complete : logi TRUE
#>   ..$ data  :'data.frame':   4 obs. of  7 variables:
#>   .. ..$ modis_date   : chr [1:4] "A2004001" "A2004009" "A2004017" "A2004025"
#>   .. ..$ calendar_date: chr [1:4] "2004-01-01" "2004-01-09" "2004-01-17" "2004-01-25"
#>   .. ..$ band         : chr [1:4] "LST_Day_1km" "LST_Day_1km" "LST_Day_1km" "LST_Day_1km"
#>   .. ..$ tile         : chr [1:4] "h09v05" "h09v05" "h09v05" "h09v05"
#>   .. ..$ proc_date    : chr [1:4] "2015212185706" "2015212201022" "2015212213103" "2015213005429"
#>   .. ..$ pixel        : chr [1:4] "1" "1" "1" "1"
#>   .. ..$ data         : int [1:4] 13098 13062 13297 13323
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
#>   .. ..$ end      : chr "2004-02-01"
#>   .. ..$ complete : logi TRUE
#>   ..$ data  :'data.frame':   4 obs. of  7 variables:
#>   .. ..$ modis_date   : chr [1:4] "A2004001" "A2004009" "A2004017" "A2004025"
#>   .. ..$ calendar_date: chr [1:4] "2004-01-01" "2004-01-09" "2004-01-17" "2004-01-25"
#>   .. ..$ band         : chr [1:4] "LST_Day_1km" "LST_Day_1km" "LST_Day_1km" "LST_Day_1km"
#>   .. ..$ tile         : chr [1:4] "h09v05" "h09v05" "h09v05" "h09v05"
#>   .. ..$ proc_date    : chr [1:4] "2015212185706" "2015212201022" "2015212213103" "2015213005429"
#>   .. ..$ pixel        : chr [1:4] "1" "1" "1" "1"
#>   .. ..$ data         : int [1:4] 13098 13062 13297 13323
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

## References

Tuck et al. (2014). [MODISTools - downloading and processing MODIS
remotely sensed data in R Ecology &
Evolution](https://onlinelibrary.wiley.com/doi/full/10.1002/ece3.1273),
4(24), 4658 - 4668.

## Acknowledgements

Original development was supported by the UK Natural Environment
Research Council (NERC; grants NE/K500811/1 and NE/J011193/1), and the
Hans Rausing Scholarship. Refactoring was supported through the Belgian
Science Policy office COBECORE project (BELSPO; grant
BR/175/A3/COBECORE).
