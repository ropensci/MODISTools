#' Download all available products
#'
#' Lists all available MODIS Land Products Subset products.
#'
#' @return A data frame of all available MODIS Land Products Subsets products
#' @seealso \code{\link[MODISTools]{mt_bands}}
#' \code{\link[MODISTools]{mt_sites}} \code{\link[MODISTools]{mt_dates}}
#' @export
#' @importFrom memoise memoise
#' @examples
#'
#' \donttest{
#' # list all available MODIS Land Products Subsets products
#' products <- mt_products()
#' head(products)
#'}
#'

mt_products <- memoise::memoise(function(){

  # define url
  url <- paste(mt_server(), "products", sep = "/")

  # try to download the data
  products <- try(jsonlite::fromJSON(url))

  # trap errors on download, return a general error statement
  if (inherits(products, "try-error")){
    stop("Your requested timed out or the server is unreachable")
  }

  # split out data
  products <- products$products

  # convert labels to more sensible names
  products$frequency <- gsub("-", " ", products$frequency)
  products$frequency <- gsub("Day", "day", products$frequency)
  products$frequency <- gsub("Daily", "1 day", products$frequency)
  products$frequency <- gsub("Yearly", "1 year", products$frequency)

  # return a data frame with all products and their details
  return(products)
})
