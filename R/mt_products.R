#' Download all available products
#'
#' Lists all available MODIS Land Products Subset products.
#'
#' @return A data frame of all available MODIS Land Products Subsets products
#' @keywords MODIS Land Products Subsets, products, meta-data
#' @export
#' @examples
#'
#' \donttest{
#' # list all available MODIS Land Products Subsets products
#' products <- mt_products()
#' print(products)
#'}

mt_products <- function(){

  # define server settings (main server should become global
  # as in not specified in every function)
  url <- paste0(.Options$mt_server,
                .Options$mt_api_version,
                "/products")

  # try to download the data
  products <- try(jsonlite::fromJSON(url))

  # trap errors on download, return a general error statement
  if (inherits(products, "try-error")){
    stop("Your requested timed out or the server is unreachable")
  }

  # return a data frame with all products and their details
  return(products$products)
}
