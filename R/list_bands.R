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
#' bands <- list_bands(product = "MOD11A2")
#' print(bands)
#'
#'}

list_bands <- function(product = NULL){

  # load all products
  products <- list_products()$product

  # error trap
  if (is.null(product) | !(product %in% products)){
    stop("please specify a product, or check your product name...")
  }

  # define server settings (main server should become global
  # as in not specified in every function)
  server <- "https://modis.ornl.gov/rst/"
  url <- paste0(server,"api/v1/",product,"/bands")

  # try to download the data
  bands <- try(jsonlite::fromJSON(url))

  # trap errors on download, return a general error statement
  if (inherits(bands, "try-error")){
    stop("Your requested timed out or the server is unreachable")
  }

  # return a data frame with all bands
  return(bands$bands)
}
