[![Build Status](https://travis-ci.org/khufkens/MODISTools.svg)](https://travis-ci.org/khufkens/MODISTools) [![codecov](https://codecov.io/gh/khufkens/MODISTools/branch/master/graph/badge.svg)](https://codecov.io/gh/khufkens/MODISTools) 

# MODISTools

```diff
- THIS PROJECT IS STARTING SO NOTHING HERE YET, CHECK IN LATER!
```


Programmatic interface to the ['MODIS Land Products Subsets' web services](https://modis.ornl.gov/data/modis_webservice.html). Allows for easy downloads of 'MODIS' time series directly to your R workspace or your computer.

## Installation

### development release

To install the development releases of the package run the following commands:

```r
if(!require(devtools)){install.package("devtools")}
devtools::install_github("khufkens/MODISTools")
library("MODISTools")
```

Vignettes are not rendered by default, if you want to include additional documentation please use:

```r
if(!require(devtools)){install.package("devtools")}
devtools::install_github("khufkens/MODISTools", build_vignettes = TRUE)
library("MODISTools")
```

## Use


