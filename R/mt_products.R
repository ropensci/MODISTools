#' Download all available products
#'
#' Lists all available MODIS Land Products Subset products.
#'
#' @return A data frame of all available MODIS Land Products Subsets products
#' @keywords MODIS Land Products Subsets, products, meta-data
#' @export
#' @importFrom magrittr %>%
#' @examples
#'
#' \donttest{
#' # list all available MODIS Land Products Subsets products
#' products <- mt_products()
#' print(products)
#'}

mt_products <- memoise::memoise(function(){

  # define url
  url <- paste(.Options$mt_server, "products", sep = "/")

  # try to download the data
  products <- try(jsonlite::fromJSON(url))

  # trap errors on download, return a general error statement
  if (inherits(products, "try-error")){
    stop("Your requested timed out or the server is unreachable")
  }

  # convert frequency to seconds, and labels to more sensible
  # values
  products <- products$products %>%
    dplyr::mutate(frequency = gsub("-", " ", frequency)) %>%
    dplyr::mutate(frequency = gsub("Day", "day", frequency)) %>%
    dplyr::mutate(frequency = gsub("Daily", "1 day", frequency)) %>%
    dplyr::mutate(frequency = gsub("Yearly", "1 year", frequency)) %>%
    dplyr::mutate(frequency_sec = lubridate::duration(frequency))

  # return a data frame with all products and their details
  return(products)
})
