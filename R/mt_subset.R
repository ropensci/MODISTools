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
#' subset <- mt_subset(product = "MOD11A2",
#'                         lat = 40,
#'                         lon = -110,
#'                         band = "LST_Day_1km",
#'                         start = "2004-01-01",
#'                         end = "2004-03-31")
#'  print(str(subset))
#'}

mt_subset <- function(product = NULL,
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
  products <- MODISTools::mt_products()$product

  # error trap
  if (is.null(product) | !(product %in% products) ){
    stop("please specify a product, or check your product name...")
  }

  # error trap
  if (is.null(site_id) & (is.null(lat) | is.null(lon)) ){
    stop("please specify coordinates, or a valid site ID...")
  }

  # check if site_id is valid
  if(!is.null(site_id)){

    # load all sites
    sites <- MODISTools::mt_sites()

    # check if the site id is valid
    if (!length(site_id %in% sites$siteid)){
      stop("please specify a valid site id...")
    }
  }

  # define server settings (main server should become global
  # as in not specified in every function)
  server <- "https://modis.ornl.gov/rst/api/"
  version <-"v1"

  # switch url in case of siteid
  if (is.null(site_id)){
    url <- paste0(server,version,"/",product,"/subset")
  } else {
    url <- paste0(server,version,"/",product,"/",site_id,"/subset")
  }

  # get date range convert format
  dates <- MODISTools::mt_dates(product = product,
                      lat = lat,
                      lon = lon,
                      site_id = site_id)

  # convert to date object for easier handling
  dates$calendar_date <- as.Date(dates$calendar_date)

  # subset the dates
  dates <- dates[which( dates$calendar_date <= as.Date(end) &
           dates$calendar_date >= as.Date(start)),]

  # check if something remains
  if (nrow(dates) == 0){
    stop("No data points exist for the selected date range...")
  }

  # list breaks, for downloads in chunks
  breaks <- seq(1, nrow(dates), 10)

  subset_data <- lapply(breaks, function(b){

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
    json_chunk <- httr::GET(url = url,
                         query = query,
                         httr::write_memory())

    # trap errors on download, return a general error statement
    # with the most common causes
    if (httr::http_error(json_chunk)){
      warning("Your requested timed out or the server is unreachable")
      return(NULL)
    }

    # check the content of the response
    if (httr::http_type(json_chunk) != "application/json") {
      warning("API did not return json", call. = FALSE)
      return(NULL)
    }

    # grab content
    chunk <- jsonlite::fromJSON(httr::content(json_chunk, "text",
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
  header$cellsize <- as.character(header$cellsize)

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
  colnames(pixels) <- seq_len(ncol(pixels))

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
  class(subset_data) <- "MODISTools"

  # return a nested list with all data
  # to workspace or to file
  if (internal){
    return(subset_data)
  } else {
    mt_write(subset_data,
                 out_dir = out_dir)
  }
}

corner_to_coord <- function (x) {
  as.numeric(x) * 1e-5
}

mt_tidy <- function(x) {
  tibble::as_tibble(x$header) %>%
    dplyr::mutate(data = list(x$data))
}

corner_to_square <- function(x = 0, y = 0, res = c(0.05, 0.05)) {
  if (length(x) > 1) {
    return(purrr::map2(x, y, .corner_to_square))
  }
  list(.corner_to_square(x, y, res))
}

.corner_to_square <- function(x = 0, y = 0, res = c(0.05, 0.05)) {
  trans <- c(
    0, 0,
    0, 1,
    1, 1,
    1, 0,
    0, 0
  )
  matrix(res * trans + c(x, y), 5, 2, byrow = TRUE)
}

to_poly <- function(x) {
  x %>%
    sf::st_linestring() %>%
    sf::st_cast("POLYGON")
}

corner_to_sfc <- function(x, y) {
  corner_to_square(x, y) %>%
    purrr::map(to_poly) %>%
    sf::st_sfc(crs = 4326)
}

