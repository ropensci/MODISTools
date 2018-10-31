# main unit tests

test_that("test mt_products()",{
  expect_is(mt_products(), "data.frame")
})

test_that("test mt_sites()",{
  expect_is(mt_sites(), "data.frame")
})

test_that("test mt_bands()",{
  expect_is(mt_bands(product = "MOD11A2"), "data.frame")
  expect_error(mt_bands(product = "MOD11A6"))
})

test_that("test mt_dates()",{
  expect_is(mt_dates(product = "MOD11A2",
                          lat = 40,
                          lon = -110),
            "data.frame")

  expect_error(mt_dates(product = "MOD11A6",
                          lat = 40,
                          lon = -110))

  expect_error(mt_dates(product = "MOD11A6",
                              lat = NULL,
                              lon = -110))

  expect_is(mt_dates(product = "MOD11A2",
                                site_id = mt_sites()$siteid[1]),
            "data.frame")

  expect_error(mt_dates(product = "MOD11A2",
                     site_id = "test"))
})

test_that("test mt_subset()",{

  expect_is(mt_subset(product = "MOD11A2",
                    lat = 40,
                    lon = -110,
                    band = "LST_Day_1km",
                    start = "2004-01-01",
                    end = "2004-03-31"),
            "data.frame")

  expect_error(mt_subset(product = "MOD11A2",
                         lat = 40,
                         band = "LST_Day_1km",
                         start = "2004-01-01",
                         end = "2004-03-31"))

  expect_is(mt_subset(product = "MOD11A2",
                                 site_id = "us_tennessee_neon_ornl",
                                 band = "LST_Day_1km",
                                 start = "2004-01-01",
                                 end = "2004-03-31"),
            "data.frame")

  expect_silent(mt_subset(product = "MOD11A2",
                          lat = 40,
                          lon = -110,
                          band = "LST_Day_1km",
                          start = "2004-01-01",
                          end = "2004-03-31",
                          internal = FALSE,
                          progress = FALSE))
})

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

test_that("test mt_batch_subset()",{

  # test batch download
  expect_is(mt_batch_subset(df = df,
                          product = "MOD11A2",
                          band = "LST_Day_1km",
                          internal = TRUE,
                          start = "2004-01-01",
                          end = "2004-03-31"),
            "data.frame")

  # test batch download
  expect_is(mt_batch_subset(df = paste0(tempdir(),"/batch.csv"),
                                  product = "MOD11A2",
                                  band = "LST_Day_1km",
                                  internal = TRUE,
                                  start = "2004-01-01",
                                  end = "2004-03-31"),
            "data.frame")

  # test batch download
  expect_error(mt_batch_subset(df = "fail.csv",
                          product = "MOD11A2",
                          band = "LST_Day_1km",
                          internal = TRUE,
                          start = "2004-01-01",
                          end = "2004-03-31"))
})
