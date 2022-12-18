#' Convert tidy MODISTools data to terra SpatRaster
#'
#' Convert tidy MODISTools data to a terra SpatRaster for easy
#' spatial processing and plotting.
#'
#' @param df a valid MODISTools data frame with a single band (filter for a
#' particular band using the dplyr \code{filter()} function or base \code{subset()}
#' @param reproject reproject output to lat / long (default = \code{FALSE})
#' @return A terra SpatRaster populated with the tidy dataframe values
#' @seealso \code{\link[MODISTools]{mt_subset}}
#' \code{\link[MODISTools]{mt_batch_subset}}
#' @export
#' @examples
#'
#' \donttest{
#' # list all available MODIS Land Products Subsets products
#' # download data
#' LC <- mt_subset(product = "MCD12Q1",
#'  lat = 48.383662,
#'  lon = 2.610250,
#'  band = "LC_Type1",
#'  start = "2005-01-01",
#'  end = "2005-12-30",
#'  km_lr = 2,
#'  km_ab = 2,
#'  site_name = "testsite",
#'  internal = TRUE,
#'  progress = FALSE)
#'
#' head(LC)
#'
#' # convert to raster
#' LC_r <- mt_to_terra(df = LC)
#'}
#' @importFrom terra rast

mt_to_terra <- function(
  df,
  reproject = FALSE
  ){

  # trap empty function
  if(missing(df)){
    stop("No data provided")
  }

  # check if data frame
  if(!is.data.frame(df)){
    stop("Data is not a data frame")
  }

  # check if MODISTools data frame
  # (introduce class?)
  if(!any(names(df) %in% "modis_date")){
    stop("Data is not a MODISTools data frame")
  }

  # check if there are multiple bands stop
  # ask for a subset with a single band
  if(length(unique(df$band)) != 1){
    stop("Multiple bands in data frame, filter for a single band first!")
  }

  # find unique dates for which data should exist
  dates <- unique(df$calendar_date)

  # convert scale to 1 if not available
  # should not change the numeric value of a band
  df$scale[df$scale == "Not Available"] <- 1

  # loop over all dates, format rasters and return
  r <- do.call("c",
               lapply(dates, function(date){

                 # stuff values into raster
                 m <- matrix(as.numeric(df$value[df$calendar_date == date]) *
                               as.numeric(df$scale[df$calendar_date == date]),
                             df$nrows[1],
                             df$ncols[1],
                             byrow = TRUE
                             )

                 # convert to raster and return
                 return(terra::rast(m))
               })
  )

  # get bounding box
  bb <- MODISTools::mt_bbox(
    xllcorner = df$xllcorner[1],
    yllcorner = df$yllcorner[1],
    cellsize = df$cellsize[1],
    nrows = df$nrows[1],
    ncols = df$ncols[1],
    transform = FALSE
    )

  # convert to Spatial object (easier to get extent)
  bb <- sf::as_Spatial(bb)

  # assign extent + projection bb to raster
  terra::ext(r) <- terra::ext(bb)
  terra::crs(r) <- bb@proj4string@projargs
  names(r) <- as.character(dates)

  # reproject to lat long when desired
  if(reproject){
    r <- terra::project(
      r,
      crs = 4326
      )
  }

  # return the data
  return(r)
}
