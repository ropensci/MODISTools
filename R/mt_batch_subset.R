#' Batch download MODIS Land Products subsets
#'
#' Lists all available dates for a MODIS Land Products Subset product
#' at a particular location.
#'
#' @param df a file holding locations and their sitenames to batch process
#' @param product a valid MODIS product name
#' @param band band to download (default = \code{NULL}, all bands)
#' @param start start date
#' @param end end date
#' @param km_lr km left-right to sample
#' @param km_ab km above-below to sample
#' @param out_dir location where to store all data
#' @param ncores number of cores to use while downloading in parallel
#' (auto will select the all cpu cores - 1)
#' @param internal should the data be returned as an internal data structure
#' \code{TRUE} or \code{FALSE} (default = \code{TRUE})
#' @return A nested list containing the downloaded data and a descriptive
#' header with meta-data.
#' @keywords MODIS Land Products Subsets, products, meta-data
#' @export
#' @examples
#'
#' \donttest{
#' # create data frame with a site_name, lat and lon column
#' # holding the respective names of sites and their location
#' df <- data.frame("site_name" = paste("test",1:2))
#' df$lat <- 40
#' df$lon <- -110
#'
#' print(df)
#'
#' # test batch download
#' subsets <- mt_batch_subset(df = df,
#'                         product = "MOD11A2",
#'                         band = "LST_Day_1km",
#'                         internal = TRUE,
#'                         start = "2004-01-01",
#'                         end = "2004-03-31",
#'                         out_dir = "~")
#'
#' print(str(subsets))
#'
#'}

mt_batch_subset <- function(df = NULL,
                         product = NULL,
                         band = NULL,
                         start = "2000-01-01",
                         end = format(Sys.time(),"%Y-%m-%d"),
                         km_lr = 0,
                         km_ab = 0,
                         out_dir = tempdir(),
                         internal = TRUE,
                         ncores = "auto"){
  # error trap
  if (is.null(df)){
    stop("please specify a batch file...")
  }

  # load all products
  products <- MODISTools::mt_products()$product

  # error trap
  if (is.null(product) | !(product %in% products) ){
    stop("please specify a product, or check your product name...")
  }

  # check data frame
  if (!is.data.frame(df)){
    if(file.exists(df)){
      df = utils::read.table(df,
                      header = TRUE,
                      sep = ",",
                      stringsAsFactors = FALSE)
    } else {
     stop("specified batch file does not exist")
    }
  }

  # construct the data frame over which we will
  # loop to process all the data
  df$product <- product
  df$band <- ifelse(is.null(band),"",band)
  df$start <- start
  df$end <- end
  df$km_lr <- km_lr
  df$km_ab <- km_ab
  df$out_dir <- path.expand(out_dir)
  df$internal <- internal

  # Calculate the number of cores
  if (ncores == "auto"){
    ncores <- parallel::detectCores() - 1
  }

  # trap excessive cores for given data
  if(nrow(df) <= ncores){
    ncores <- nrow(df)
  }

  # Initiate cluster
  cl <- parallel::makeCluster(ncores)

  output <- parallel::parRapply(cl, df, function(x){
    MODISTools::get_subset(site_name = as.character(x['site_name']),
                           product = as.character(x['product']),
                           band = as.character(x['band']),
                           lat = as.numeric(x['lat']),
                           lon = as.numeric(x['lon']),
                           km_lr = as.numeric(x['km_lr']),
                           km_ab = as.numeric(x['km_ab']),
                           start = as.character(x['start']),
                           end = as.character(x['end']),
                           out_dir = x['out_dir'],
                           internal = x['internal'])
  })

  # stop cluster
  parallel::stopCluster(cl)

  # add site names to list
  names(output) <- df$site_name

  # return data
  return(output)
}

