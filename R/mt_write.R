#' Write a MODISTools data structure to file
#'
#' Writes a nested data structure of class MODISTools to file.
#'
#' @param df a nested data structure of class MODISTools
#' @param out_dir output directory where to store data
#' @return writes MODISTools data structure to file, retains proper header info.
#' @keywords time series, IO
#' @export
#' @examples
#'
#' \donttest{
#' # download data
#' subset <- get_subset(product = "MOD11A2",
#'                         lat = 40,
#'                         lon = -110,
#'                         band = "LST_Day_1km",
#'                         start = "2004-01-01",
#'                         end = "2004-02-01")
#' # write the above file to disk
#' write_subset(df = subset,
#'              out_dir = tempdir())
#'
#' # read the data back in
#' subset_disk <- read_subset(paste0(tempdir(),
#'                "/sitename_MOD11A2_2004-01-01_2004-02-01.csv"))
#'
#' # compare original to read from disk
#' identical(subset, subset_disk)
#' }

mt_write <- function(df = NULL,
                           out_dir = tempdir()){

  if(class(df)!="MODISTools" | is.null(df)){
    stop("not a MODISTools dataset or no dataset provided")
  }

  # format filename
  filename = sprintf("%s/%s_%s_%s_%s.csv",
                     path.expand(out_dir),
                     df$header$site,
                     df$header$product,
                     df$header$start,
                     df$header$end)

  # collapse named vector into a matrix
  header = apply(cbind(names(df$header),
                       df$header),
                 1,
                 function(x)sprintf("# %s",
                                    paste(x,collapse=": ")))

  # fix collated empty lines and add trailing #
  header = gsub(": NA", "", header)

  # writing the final data frame to file, retaining the original header
  utils::write.table(
    header,
    filename,
    quote = FALSE,
    row.names = FALSE,
    col.names = FALSE,
    sep = ""
  )
  suppressWarnings(utils::write.table(
    df$data,
    filename,
    quote = FALSE,
    row.names = FALSE,
    col.names = TRUE,
    sep = ",",
    append = TRUE
  ))
}
