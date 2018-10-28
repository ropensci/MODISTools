#' Download all available fixed sites
#'
#' Lists all available MODIS Land Products Subset pre-processed sites
#'
#' @return A data frame of all available MODIS Land Products Subsets
#' pre-processed sites
#' @keywords MODIS Land Products Subsets, products, meta-data
#' @export
#' @examples
#'
#' \donttest{
#' # list all available MODIS Land Products Subsets products
#' sites <- mt_sites()
#' print(head(sites))
#'}

mt_sites <- function(){

  # define server settings (main server should become global
  # as in not specified in every function)
  url <- paste0(.Options$mt_server,
                .Options$mt_api_versions,
                "/sites")

  # try to download the data
  sites <- try(jsonlite::fromJSON(url))

  # trap errors on download, return a general error statement
  if (inherits(sites, "try-error")){
    stop("Your requested timed out or the server is unreachable")
  }

  # return a data frame with all products and their details
  return(sites$sites)
}
