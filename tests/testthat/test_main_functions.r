# main unit tests

test_that("test list_products()",{

  # test listing all products
  products <- try(list_products())

  # see if any of the runs failed
  check = !inherits(products, "try-error")

  # check if no error occured
  expect_true(check)
})


test_that("test list_bands()",{

  # test listing all products
  bands <- try(list_bands(product = "MOD11A2"))
  bands_err <- try(list_bands(product = "MOD11A6"))

  # see if any of the runs failed
  check = !inherits(bands, "try-error") &
    inherits(bands_err, "try-error")

  # check if no error occured
  expect_true(check)
})


test_that("test list_dates()",{

  # test listing all products
  dates <- try(list_dates(product = "MOD11A2",
                          lat = 40,
                          lon = -110))

  dates_err <- try(list_dates(product = "MOD11A6",
                          lat = 40,
                          lon = -110))

  dates_coord_err <- try(list_dates(product = "MOD11A6",
                              lat = NULL,
                              lon = -110))

  # see if any of the runs failed
  check = !inherits(dates, "try-error") &
    inherits(dates_err, "try-error") &
    inherits(dates_coord_err, "try-error")

  # check if no error occured
  expect_true(check)
})

test_that("test get_subset()",{

  # download data
  subset = try(get_subset(product = "MOD11A2",
                    lat = 40,
                    lon = -110,
                    band = "LST_Day_1km",
                    start = "2004-01-01",
                    end = "2004-03-31"))

  # download data
  subset_disk = try(get_subset(product = "MOD11A2",
                          lat = 40,
                          lon = -110,
                          band = "LST_Day_1km",
                          start = "2004-01-01",
                          end = "2004-03-31",
                          internal = FALSE))

  # see if any of the runs failed
  check = !inherits(subset, "try-error") &
          !inherits(subset_disk, "try-error")

  # check if no error occured
  expect_true(check)
})

test_that("test batch_subset()",{

  # create data frame with a site_name, lat and lon column
  # holding the respective names of sites and their location
  df <- data.frame("site_name" = paste("test",1:2))
  df$lat <- 40
  df$lon <- -110

  write.table(df, paste0(tempdir(),"/batch.csv"),
              quote = FALSE,
              row.names = FALSE,
              col.names = TRUE,
              sep = ",")

  # test batch download
  subsets <- try(batch_subset(df = df,
                          product = "MOD11A2",
                          band = "LST_Day_1km",
                          internal = TRUE,
                          start = "2004-01-01",
                          end = "2004-03-31",
                          out_dir = "~"))

  # test batch download
  subsets_file <- try(batch_subset(df = paste0(tempdir(),"/batch.csv"),
                                  product = "MOD11A2",
                                  band = "LST_Day_1km",
                                  internal = TRUE,
                                  start = "2004-01-01",
                                  end = "2004-03-31",
                                  out_dir = "~"))

  # test batch download
  subsets_no_file <- try(batch_subset(df = "fail.csv",
                          product = "MOD11A2",
                          band = "LST_Day_1km",
                          internal = TRUE,
                          start = "2004-01-01",
                          end = "2004-03-31",
                          out_dir = "~"))

  print(subsets_no_file)

  # see if any of the runs failed
  check = !inherits(subsets, "try-error") &
          !inherits(subsets_file, "try-error") &
          inherits(subsets_no_file, "try-error")

  # check if no error occured
  expect_true(check)
})
