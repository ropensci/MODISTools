#' Download all available bands
#'
#' Lists all available bands for a MODIS Land Products Subset product.
#'
#' @param product a valid MODIS product name
#' @return A data frame of all available bands for a MODIS Land
#' Products Subsets products
#' @keywords MODIS Land Products Subsets, products, meta-data
#' @export
#' @examples
#'
#' \donttest{
#' # list all available MODIS Land Products Subsets products
#' bands <- mt_bands(product = "MOD11A2")
#' print(bands)
#'
#'}

mt_bands <- memoise::memoise(function(product){

  # load all products
  products <- MODISTools::mt_products()$product

  # error trap
  if (missing(product) | !(product %in% products)){
    stop("please specify a product, or check your product name...")
  }

  # define url
  url <- paste(.Options$mt_server, product, "bands", sep = "/")

  # try to download the data
  bands <- try(jsonlite::fromJSON(url))

  # trap errors on download, return a general error statement
  if (inherits(bands, "try-error")){
    stop("Your requested timed out or the server is unreachable")
  }

  # return a data frame with all bands
  return(bands$bands)
})
