#' Convert sinusoidal coordinates to lat / lon
#'
#' A full description of the sinusoidal projection is provided on the
#' lpdaac page:
#' https://lpdaac.usgs.gov/dataset_discovery/modis
#' and wikipedia:
#' https://en.wikipedia.org/wiki/Sinusoidal_projection
#'
#' @param x sinusoidal x coordinate (vector)
#' @param y sinusoidal y coordinate (vector)
#' @seealso \code{\link[MODISTools]{mt_bbox}}
#' @keywords MODIS Land Products Subsets, products, meta-data
#' @export
#' @examples
#'
#' \donttest{
#' # Download some test data
#' subset <- mt_subset(product = "MOD11A2",
#'                         lat = 40,
#'                         lon = -110,
#'                         band = "LST_Day_1km",
#'                         start = "2004-01-01",
#'                         end = "2004-03-31",
#'                         progress = FALSE)
#'
#' # convert sinusoidal to lat / lon
#' lat_lon <- sin_to_ll(subset$xllcorner, subset$yllcorner)
#'
#' # bind with the original dataframe
#' subset <- cbind(subset, lat_lon)
#' head(subset)
#'}

sin_to_ll <- function(x, y){

  # check parameters
  if(missing(x) | missing(y)){
    stop("please provide a coordinate pair in sinusoidal projection...")
  }

  # convert to sf object
  coords <- sf::st_as_sf(x = data.frame(as.numeric(x),
                                        as.numeric(y),
                                        stringsAsFactors = FALSE),
                     coords = c("as.numeric.x.", "as.numeric.y."),
                     crs = "+proj=sinu +a=6371007.181 +b=6371007.181 +units=m")

  # reproject coordinates
  coords <- sf::st_transform(coords, "+init=epsg:4326")

  # unravel the sf dataframe into a normal one
  coords <- as.data.frame(do.call("rbind", lapply(coords$geometry, unlist)))
  colnames(coords) <- c("longitude_ll", "latitude_ll")

  # return the labelled dataframe
  return(coords)
}

#' Converts lower-left sinusoidal coordinates to lat-lon sf bounding box
#'
#' @param xllcorner lower left x coordinate as provided by
#' \code{\link[MODISTools]{mt_subset}}
#' @param yllcorner lower left y coordinate as provided by
#' \code{\link[MODISTools]{mt_subset}}
#' @param cellsize cell size provided by \code{\link[MODISTools]{mt_subset}}
#' @param nrows cell size provided by \code{\link[MODISTools]{mt_subset}}
#' @param ncols cell size provided by \code{\link[MODISTools]{mt_subset}}
#' @param transform transform the bounding box from sin to lat long coordinates,
#' \code{TRUE} or \code{FALSE} (default = \code{TRUE})
#' @seealso \code{\link[MODISTools]{sin_to_ll}},
#' \code{\link[MODISTools]{mt_subset}}
#' @keywords MODIS Land Products Subsets, products, meta-data
#' @export
#' @examples
#'
#' \donttest{
#' # Download some test data
#' subset <- mt_subset(product = "MOD11A2",
#'                         lat = 40,
#'                         lon = -110,
#'                         band = "LST_Day_1km",
#'                         start = "2004-01-01",
#'                         end = "2004-03-31",
#'                         progress = FALSE)
#'
#' # convert sinusoidal to lat / lon
#' lat_lon <- sin_to_ll(subset$xllcorner, subset$yllcorner)
#'
#' # bind with the original dataframe
#' subset <- cbind(subset, lat_lon)
#'
#' # convert to bounding box
#' bb <- apply(subset, 1, function(x){
#'   mt_bbox(xllcorner = x['xllcorner'],
#'           yllcorner = x['yllcorner'],
#'           cellsize = x['cellsize'],
#'           nrows = x['nrows'],
#'           ncols = x['ncols'])
#' })
#'
#' head(bb)
#'}

mt_bbox <- function(
  xllcorner,
  yllcorner,
  cellsize,
  nrows,
  ncols,
  transform = TRUE
  ){

  # check parameters
  if(missing(cellsize) | missing(yllcorner) |
     missing(xllcorner) | missing(nrows) |
     missing(ncols)){
    stop("missing parameter, all parameters are required")
  }

  # transform matrix
  trans <- c(
    0, 0,
    0, 1,
    1, 1,
    1, 0,
    0, 0
  )

  # create coordinate matrix
  m <- c(as.numeric(cellsize) * as.numeric(ncols),
         as.numeric(cellsize) * as.numeric(nrows)) * trans +
    c(as.numeric(xllcorner), as.numeric(yllcorner))
  m <- matrix(m, 5, 2, byrow = TRUE)

  # convert to a sf polygon, with the proper
  # projection etc.
  p <- sf::st_linestring(m)
  p <- sf::st_cast(p, "POLYGON")
  p <- sf::st_sfc(p, crs = "+proj=sinu +a=6371007.181 +b=6371007.181 +units=m")

  # a full description of the sinusoidal projection is provided on the
  # lpdaac page:
  # https://lpdaac.usgs.gov/dataset_discovery/modis
  # and wikipedia:
  # https://en.wikipedia.org/wiki/Sinusoidal_projection

  # return untransformed (sinusoidal) data upon request
  if(!transform){
    return(p)
  }

  # transform the polygon to lat-lon
  p <- sf::st_transform(p, crs = 4326)

  # return the polygons
  return(p)
}
