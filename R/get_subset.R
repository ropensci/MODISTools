#' Download MODIS Land Products subsets
#'
#' Lists all available dates for a MODIS Land Products Subset product
#' at a particular location.
#'
#' @param product a valid MODIS product name
#' @param band band to download (default = \code{NULL}, all bands)
#' @param lat latitude in decimal degrees
#' @param lon longitude in decimal degrees
#' @param start start date
#' @param end end date
#' @param km_lr km left-right to sample
#' @param km_ab km above-below to sample
#' @param site_id site id (overides lat / lon)
#' @param site_name arbitrary site name used in writing data to file
#' (default = sitename)
#' @param out_dir path where to store the data if writing to disk
#' (default = tempdir())
#' @param internal should the data be returned as an internal data structure
#' \code{TRUE} or \code{FALSE} (default = \code{TRUE})
#' @return A nested list containing the downloaded data and a descriptive
#' header with meta-data.
#' @keywords MODIS Land Products Subsets, products, meta-data
#' @export
#' @examples
#'
#' \donttest{
#' # list all available MODIS Land Products Subsets products
#' # download data
#' subset <- get_subset(product = "MOD11A2",
#'                         lat = 40,
#'                         lon = -110,
#'                         band = "LST_Day_1km",
#'                         start = "2004-01-01",
#'                         end = "2004-03-31")
#'  print(str(subset))
#'}

get_subset <- function(product = NULL,
                       band = NULL,
                       lat = NULL,
                       lon = NULL,
                       start = "2000-01-01",
                       end = format(Sys.time(),"%Y-%m-%d"),
                       km_lr = 0,
                       km_ab = 0,
                       site_id = NULL,
                       site_name = "sitename",
                       out_dir = tempdir(),
                       internal = TRUE){

  # load all products
  products <- MODISTools::list_products()$product

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
  dates <- MODISTools::list_dates(product = product,
                      lat = lat,
                      lon = lon)

  # convert to date object for easier handling
  dates$calendar_date <- as.Date(dates$calendar_date)

  # subset the dates
  dates <- dates[which( dates$calendar_date <= as.Date(end) &
           dates$calendar_date >= as.Date(start)),]

  # check if something remains
  if (nrow(dates)==0){
    stop("No data points exist for the selected date range...")
  }

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
    resp = httr::GET(url = url,
                         query = query,
                         httr::write_memory())

    # trap errors on download, return a general error statement
    # with the most common causes
    if (httr::http_error(resp)){
      warning("Your requested timed out or the server is unreachable")
      return(NULL)
    }

    # check the content of the response
    if (httr::http_type(resp) != "application/json") {
      warning("API did not return json", call. = FALSE)
      return(NULL)
    }

    # grab content
    chunk <- jsonlite::fromJSON(httr::content(resp, "text",
                                              encoding = "UTF-8"),
                                simplifyVector = TRUE)

    # return data
    return(chunk)
  })

  # split out a header including
  # additional ancillary data
  header <- subset_data[[1]][!(names(subset_data[[1]]) %in%
                                   c("header","subset"))]
  header$site <- ifelse(is.null(site_id),
                          site_name,
                          site_id)
  header$product <- product
  header$start <- start
  header$end <- end

  # This is a check on the complete nature of the retrieved data
  # the process will not stall on errors occur in the download
  # process but just return NULL, these are trapped here and
  # reported as complete TRUE/FALSE in the header or the returned
  # object. Using this flag one can decide to reprocess.
  header$complete <- !any(unlist(lapply(subset_data, is.null)))

  # reshape the data converting it to a tidy data frame
  # data will be reported row wise
  subset_data <- do.call("rbind",
                         lapply(subset_data,
                                function(x)x$subset))
  pixels <- do.call("rbind",
                    subset_data$data)
  colnames(pixels) <- 1:ncol(pixels)

  # remove old nested list data and substitute with columns
  subset_data <- cbind(subset_data[,!(names(subset_data) %in% "data")],
                            pixels)

  # create tidy data frame
  subset_data <- tidyr::gather(subset_data,
         key = "pixel",
         value = "data",
         grep("[0-9]",names(subset_data)))

  # re-structure by addint a header
  subset_data <- list("header" = header,
                      "data" = subset_data)
  # attach class
  class(subset_data) = "MODISTools"

  # return a nested list with all data
  # to workspace or to file
  if (internal){
    return(subset_data)
  } else {
    write_subset(subset_data,
                 out_dir = out_dir)
  }
}
