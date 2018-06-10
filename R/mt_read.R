#' Read a MODISTools data file
#'
#' Read a MODISTools data file into a nested structure of class MODISTools.
#'
#' @param filename a MODISTools data file
#' @return A nested data structure including site meta-data, the full
#' header and the data as a `data.frame()`.
#' @keywords time series, IO
#' @export
#' @examples
#'
#' \donttest{
#' # download data
#' get_subset(product = "MOD11A2",
#'            lat = 40,
#'            lon = -110,
#'            band = "LST_Day_1km",
#'            start = "2004-01-01",
#'            end = "2004-03-31",
#'            internal = FALSE)
#'
#' # read file
#' df <- read_subset(paste0(tempdir(),
#'                "/sitename_MOD11A2_2004-01-01_2004-03-31.csv"))
#' print(df)
#' }

mt_read <- function(filename){

  # read and format header, read past the header (should the length)
  # change in the future with a few lines this then does not break
  # the script
  header = try(readLines(filename, n = 30), silent = TRUE)
  header = header[grepl("#", header)]
  header = strsplit(header, ":")

  # read in descriptor fields
  descriptor = unlist(lapply(header, function(x){
    x[1]
  }))

  # remove leading #
  descriptor = gsub("# ","", descriptor)

  # read in data values
  values = unlist(lapply(header, function(x){
    x <- unlist(x)
    if(length(x)<=1){
      return(NA)
    }
    if(length(x) == 2){
      x[2]
    } else {
      paste(x[2:length(x)], collapse = ":")
    }
  }))

  # remove leading space
  values = gsub(" ","",values)

  # assign names to values
  names(values) = descriptor

  # overwrite original header with final copy
  header = lapply(values, function(x){x})

  # read the time series data
  data = utils::read.table(filename,
                           header = TRUE,
                           sep = ",",
                           stringsAsFactors = FALSE)

  # convert data to match mt_subset() routine (consistency)
  data$proc_date <- as.character(data$proc_date)
  data$pixel <- as.character(data$pixel)
  header$ncols <- as.integer(header$ncols)
  header$nrows <- as.integer(header$nrows)
  header$latitude <- as.double(header$latitude)
  header$longitude <- as.double(header$longitude)
  header$complete <- as.logical(header$complete)

  # format final output as a nested list of class phenocamr
  output = list(
    "header" = header,
    "data" = data)

  # set proper phenocamr class
  class(output) = "MODISTools"

  return(output)
}
