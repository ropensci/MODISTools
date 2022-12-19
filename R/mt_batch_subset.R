#' Batch download MODIS Land Products subsets
#'
#' Lists all available dates for a MODIS Land Products Subset product
#' at a particular location.
#'
#' @param df a CSV file or data frame holding locations and their sitenames to
#' batch process with column names site_name, lat, lon holding the respective
#' sitenames, latitude and longitude. When providing a CSV make sure that the
#' data are comma separated.
#' @param product a valid MODIS product name
#' @param band band to download
#' @param start start date
#' @param end end date
#' @param km_lr km left-right to sample
#' @param km_ab km above-below to sample
#' @param out_dir location where to store all data
#' @param internal should the data be returned as an internal data structure
#' \code{TRUE} or \code{FALSE} (default = \code{TRUE})
#' @return A data frame combining meta-data and actual data values, data from
#' different sites is concatenated into one large dataframe. Subsets can be
#' created by searching on sitename.
#' @seealso \code{\link[MODISTools]{mt_sites}}
#' \code{\link[MODISTools]{mt_dates}} \code{\link[MODISTools]{mt_bands}}
#' \code{\link[MODISTools]{mt_products}}
#' \code{\link[MODISTools]{mt_subset}}
#' @export
#' @examples
#'
#' \dontrun{
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
#'                         end = "2004-03-31")
#'
#' # the same can be done using a CSV file with
#' # a data structure similar to the dataframe above
#'
#' write.table(df, file.path(tempdir(),"my_sites.csv"),
#'  quote = FALSE,
#'  row.names = FALSE,
#'  col.names = TRUE,
#'  sep = ",")
#'
#' # test batch download form CSV
#' subsets <- mt_batch_subset(df = file.path(tempdir(),"my_sites.csv"),
#'                         product = "MOD11A2",
#'                         band = "LST_Day_1km",
#'                         internal = TRUE,
#'                         start = "2004-01-01",
#'                         end = "2004-03-31"
#'                         )
#'
#' head(subsets)
#'}

mt_batch_subset <- function(
  df,
  product,
  band,
  start = "2000-01-01",
  end = format(Sys.time(),"%Y-%m-%d"),
  km_lr = 0,
  km_ab = 0,
  out_dir = tempdir(),
  internal = TRUE
  ){

  # error trap
  if (missing(df)){
    stop("please specify a batch file...")
  }

  # check data frame
  if (!is.data.frame(df)){
    if(file.exists(df)){
      df <- utils::read.table(df,
                              header = TRUE,
                              sep = ",",
                              stringsAsFactors = FALSE)
    } else {
      stop("specified batch file does not exist")
    }
  }

  # load products
  products <- MODISTools::mt_products()$product

  # error trap products
  if (missing(product) | !(product %in% products) ){
    stop("please specify a product, or check your product name...")
  }

  # load bands for product
  bands <- mt_bands(product)

  # error trap band
  if (missing(band) | !(band %in% bands$band) ){
    stop("please specify a band, or check your product band combination ...")
  }

  # If all tests pass construct the data frame over which we will
  # loop to process all the data
  df$product <- product
  df$band <- band
  df$start <- start
  df$end <- end
  df$km_lr <- km_lr
  df$km_ab <- km_ab
  df$out_dir <- path.expand(out_dir)
  df$internal <- internal

  # convert names tolower case
  # trapping naming issues of coordinates
  # and sites
  names(df) <- tolower(names(df))

  # paralllel loop (if requested)
  output <- apply(df, 1, function(x){
    MODISTools::mt_subset(
      site_name = as.character(x['site_name']),
      product = as.character(x['product']),
      band = as.character(x['band']),
      lat = as.numeric(x['lat']),
      lon = as.numeric(x['lon']),
      km_lr = as.numeric(x['km_lr']),
      km_ab = as.numeric(x['km_ab']),
      start = as.character(x['start']),
      end = as.character(x['end']),
      out_dir = x['out_dir'],
      internal = x['internal'],
      progress = FALSE)
  })

  # return data
  if(internal){
    # row bind the nested list output
    output <- do.call("rbind", output)

    return(output)
  } else {
    invisible()
  }
}

