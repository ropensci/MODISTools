# load default server names

.onLoad <- function(libname, pkgname) {
  # set server options
  options(list(
    mt_server = "https://modis.ornl.gov/rst/api/",
    mt_api_version = "v1"
    )
  )
}
