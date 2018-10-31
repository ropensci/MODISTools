#' Download all available dates
#'
#' Lists all available dates for a MODIS Land Products Subset product
#' at a particular location.
#'
#' @param product a valid MODIS product name
#' @param lat latitude in decimal degrees
#' @param lon longitude in decimal degrees
#' @param site_id site id (overides lat / lon)
#' @return A data frame of all available dates for a MODIS Land
#' Products Subsets products at the given location.
#' @keywords MODIS Land Products Subsets, products, meta-data
#' @seealso \code{\link[MODISTools]{mt_products}}
#' \code{\link[MODISTools]{mt_sites}} \code{\link[MODISTools]{mt_bands}}
#' @export
#' @examples
#'
#' \donttest{
#' # list all available MODIS Land Products Subsets products
#' bands <- mt_dates(product = "MOD11A2", lat = 40, lon = -110)
#' head(bands)
#'}

mt_dates <- function(product,
                       lat,
                       lon,
                       site_id){

  # load all products
  products <- MODISTools::mt_products()$product

  # error trap
  if (missing(product) | !(product %in% products) ){
    stop("please specify a product, or check your product name...")
  }

  # error trap
  if (missing(site_id) & (missing(lat) | missing(lon)) ){
    stop("please specify coordinates...")
  }

  # check if site_id is valid
  if(!missing(site_id)){

      # load all sites
      sites <- MODISTools::mt_sites()

      # check if the site id is valid
      if (!(site_id %in% sites$siteid)){
        stop("please specify a valid site id...")
      }
  }

  # switch url in case of siteid
  if (missing(site_id)){
    url <- paste(mt_server(), product, "dates", sep = "/")

    # construct the query to be served to the server
    query <- list("latitude" = lat,
                  "longitude" = lon)

  } else {
    url <- paste(mt_server(), product, site_id, "dates", sep = "/")
    query <- NULL
  }

  # try to download the data
  json_dates <- httr::GET(url = url,
                          query = query,
                          httr::write_memory())

  # trap errors on download, return a general error statement
  # with the most common causes.
  if (httr::http_error(json_dates)){
    stop("Your requested timed out or the server is unreachable",
         call. = FALSE)
  }

  # check the content of the json_dates, stop if not json
  if (httr::http_type(json_dates) != "application/json") {
    stop("API did not return proper json data.", call. = FALSE)
  }

  # grab content
  dates <- jsonlite::fromJSON(httr::content(json_dates, "text",
                                            encoding = "UTF-8"),
                              simplifyVector = TRUE)$dates

  # return a data frame with all dates
  return(dates)
}
