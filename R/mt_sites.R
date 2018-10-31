#' Download all available fixed sites
#'
#' Lists all available MODIS Land Products Subset pre-processed sites
#'
#' @return A data frame of all available MODIS Land Products Subsets
#' pre-processed sites
#' @keywords MODIS Land Products Subsets, products, meta-data
#' @seealso \code{\link[MODISTools]{mt_products}}
#' \code{\link[MODISTools]{mt_bands}} \code{\link[MODISTools]{mt_dates}}
#' @export
#' @examples
#'
#' \donttest{
#' # list all available MODIS Land Products Subsets products
#' sites <- mt_sites()
#' print(head(sites))
#'}

mt_sites <- memoise::memoise(function(){

  # define server settings
  url <- paste(mt_server(), "sites", sep = "/")

  # try to download the data
  sites <- try(jsonlite::fromJSON(url))

  # trap errors on download, return a general error statement
  if (inherits(sites, "try-error")){
    stop("Your requested timed out or the server is unreachable")
  }

  # return a data frame with all products and their details
  return(sites$sites)
})
