#' Convert tidy data to raster
#'
#' Convert tidy MODISTools data to a raster (stack)
#'
#' @param df a valid MODISTools data frame
#' @return A raster stack populated with the tidy dataframe values
#' @keywords MODIS Land Products Subsets, products
#' @seealso \code{\link[MODISTools]{mt_subset}}
#' \code{\link[MODISTools]{mt_batch_subset}}
#' @export
#' @examples
#'
#' \donttest{
#' # list all available MODIS Land Products Subsets products
#' # download data
#' LC <- mt_subset(product = "MCD12Q1",
#' lat = 48.383662,
#' lon = 2.610250,
#' band = "LC_Type1",
#' start = "2005-01-01",
#' end = "2005-12-30",
#' km_lr = 2,
#' km_ab = 2,
#' site_name = "testsite",
#' internal = TRUE,
#' progress = FALSE)
#'
#' head(LC)
#'
#' # convert to raster
#' LC_r <- mt_to_raster(df = LC)
#'}

mt_to_raster <- function(df = subset){

  # find unique dates for which data should exist
  dates <- unique(df$calendar_date)

  # convert scale to 1 if not available
  # should not change the numeric value of a band
  df$scale[df$scale == "Not Available"] <- 1

  # loop over all dates, format rasters and return
  r <- do.call("stack",
               lapply(dates, function(date){

                 # stuff values into raster
                 m <- matrix(df$value[df$calendar_date == date] *
                               as.numeric(df$scale[df$calendar_date == date]),
                             df$nrows[1],
                             df$ncols[1],
                             byrow = TRUE)

                 # convert to raster and return
                 return(raster::raster(m))
               })
  )

  # get bounding box
  bb <- MODISTools::mt_bbox(
    xllcorner = df$xllcorner[1],
    yllcorner = df$yllcorner[1],
    cellsize = df$cellsize[1],
    nrows = df$nrows[1],
    ncols = df$ncols[1])

  # convert to Spatial object (easier to get extent)
  bb <- as(bb, 'Spatial')

  # assign extent + projection bb to raster
  raster::extent(r) <- raster::extent(bb)
  raster::projection(r) <- raster::projection(bb)
  names(r) <- as.character(dates)

  # return the data
  return(r)
}
