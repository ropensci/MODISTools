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
  server <- "https://modis.ornl.gov/rst/"
  end_point <- "api/v1/sites"
  url <- paste0(server,end_point)

  # try to download the data
  sites <- try(jsonlite::fromJSON(url))

  # trap errors on download, return a general error statement
  if (inherits(sites, "try-error")){
    stop("Your requested timed out or the server is unreachable")
  }

  # return a data frame with all products and their details
  return(sites$sites)
}
