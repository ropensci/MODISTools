#' Download all available dates
#'
#' Lists all available dates for a MODIS Land Products Subset product
#' at a particular location.
#'
#' @param product a valid MODIS product name
#' @param band band to download (default = NULL, all bands)
#' @param lat latitude in decimal degrees
#' @param lon longitude in decimal degrees
#' @param start start date
#' @param end end date
#' @param km_lr km left-right to sample
#' @param km_ab km above-below to sample
#' @param site_id site id (overides lat / lon)
#' @return A nested list containing the downloaded data and a descriptive
#' header with meta-data.
#' @keywords MODIS Land Products Subsets, products, meta-data
#' @export
#' @examples
#'
#' \donttest{
#' # list all available MODIS Land Products Subsets products
#' bands <- list_dates(product = "MOD11A2", lat =)
#' print(bands)
#'
#'}

get_subset <- function(product = NULL,
                       band = NULL,
                       lat = NULL,
                       lon = NULL,
                       start = "2000-01-01",
                       end = format(Sys.time(),"%Y-%m-%d"),
                       km_lr = 0,
                       km_ab = 0,
                       site_id = NULL){

  # load all products
  products <- list_products()$product

  # error trap
  if (is.null(product) | !(product %in% products) ){
    stop("please specify a product, or check your product name...")
  }

  # error trap
  if (is.null(site_id) & (is.null(lat) | is.null(lon)) ){
    stop("please specify coordinates...")
  }

  # define server settings (main server should become global
  # as in not specified in every function)
  server <- "https://modis.ornl.gov/rst/"

  # switch url in case of siteid
  if (is.null(site_id)){
    url <- paste0(server,"api/v1/",product,"/subset")
  } else {
    url <- paste0(server,"api/v1/",product,"/",site_id,"/subset")
  }

  # get date range convert format
  dates <- list_dates(product = product,
                      lat = lat,
                      lon = lon)
  dates$calendar_date <- as.Date(dates$calendar_date)

  # subset the dates
  dates <- dates[which( dates$calendar_date <= as.Date(end) &
           dates$calendar_date >= as.Date(start)),]

  # list breaks
  breaks <- seq(1,nrow(dates),10)

  subset_data = lapply(breaks, function(b){

    # grab last date for subset
    if(b == breaks[length(breaks)]){
      end_date <-dates$modis_date[nrow(dates)]
    } else {
      end_date <- dates$modis_date[b+9]
    }

    # construct the query to be served to the server
    query <- list("latitude" = lat,
                  "longitude" = lon,
                  "band" = band,
                  "startDate" = dates$modis_date[b],
                  "endDate" = end_date,
                  "kmAboveBelow" = km_ab,
                  "kmLeftRight" = km_lr)

    # try to download the data
    resp = try(httr::GET(url = url,
                         query = query,
                         httr::write_memory()))

    # trap errors on download, return a general error statement
    # with the most common causes
    if (httr::http_error(resp) | inherits(resp, "try-error")){
      stop("Your requested timed out or the server is unreachable")
    }

    # check the content of the response
    if (httr::http_type(resp) != "application/json") {
      stop("API did not return json", call. = FALSE)
    }

    # grab content
    chunk <- jsonlite::fromJSON(httr::content(resp, "text",
                                              encoding = "UTF-8"),
                                simplifyVector = TRUE)

    # return data
    return(chunk)
  })

  # header
  header <- subset_data[[1]][1:10]

  # reshape the data
  subset_data <- do.call("rbind",
                         lapply(subset_data,
                                function(x)x$subset))

  # return a nested list with all data
  return(list("header" = header,
              "subset" = subset_data))
}
