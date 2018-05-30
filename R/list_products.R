#' Function to download all available products
#'
#' @return A data frame of all available MODIS Land Products Subsets products
#' @keywords MODIS Land Products Subsets, products, meta-data
#' @export
#' @examples
#'
#' \donttest{
#' # list all available MODIS Land Products Subsets products
#' products <- list_products()
#'
#' #' # For other practical examples consult the included
#' # vignette.
#'}

list_products <- function(){

  # define server settings (main server should become global
  # as in not specified in every function)
  server <- "https://modis.ornl.gov/rst/"
  end_point <- "api/v1/products"
  url <- paste0(server,end_point)

  # try to download the data
  products <- try(jsonlite::fromJSON(url))

  # trap errors on download, return a general error statement
  if (inherits(products, "try-error")){
    stop("Your requested timed out or the server is unreachable")
  }

  # return a data frame with all products and their details
  return(products)
}
