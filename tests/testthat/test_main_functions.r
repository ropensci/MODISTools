# test functions without parameters
# only can fail upon server error
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

# download tests
test_that("test mt_dates()",{

  # check dates
  expect_is(
    mt_dates(
      product = "MOD11A2",
      lat = 40,
      lon = -110
    ),
  "data.frame"
  )

  # error wrong product
  expect_error(
    mt_dates(
      product = "MOD11A6",
      lat = 40,
      lon = -110
    )
  )

  # error missing latitude
  expect_error(
    mt_dates(
      product = "MOD11A2",
      lon = -110
    )
  )

  expect_is(
    mt_dates(
      product = "MOD11A2",
      site_id = mt_sites()$siteid[1]
      ),
  "data.frame"
  )

  expect_error(
    mt_dates(
      product = "MOD11A2",
      site_id = "test"
    )
  )
})

test_that("test mt_subset()",{

  # good query
  expect_is(
    mt_subset(
      product = "MOD11A2",
      lat = 40,
      lon = -110,
      band = "LST_Day_1km",
      start = "2004-01-01",
      end = "2004-03-31",
      progress = FALSE
    ),
    "data.frame"
  )

  # missing coordinate
  expect_error(
    mt_subset(
      product = "MOD11A2",
      lat = 40,
      band = "LST_Day_1km",
      start = "2004-01-01",
      end = "2004-03-31"
    )
  )

  # no band provided
  expect_error(mt_subset(
    product = "MOD11A2",
    lat = 40,
    start = "2004-01-01",
    end = "2004-03-31"
  ))

  # no product provided
  expect_error(
    mt_subset(
      lat = 40,
      lon = -110,
      band = "LST_Day_1km",
      start = "2004-01-01",
      end = "2004-03-31"
    )
  )

  # good site query
  expect_is(
    mt_subset(
      product = "MOD11A2",
      site_id = "us_tennessee_neon_ornl",
      band = "LST_Day_1km",
      start = "2004-01-01",
      end = "2004-03-31"
    ),
    "data.frame"
  )

  # bad site query
  expect_error(
    mt_subset(
      product = "MOD11A2",
      site_id = "test",
      band = "LST_Day_1km",
      start = "2004-01-01",
      end = "2004-03-31"
    )
  )

  # write to disk test
  expect_silent(
    mt_subset(
      product = "MOD11A2",
      lat = 40,
      lon = -110,
      band = "LST_Day_1km",
      start = "2004-01-01",
      end = "2004-03-31",
      internal = FALSE,
      progress = FALSE
    )
  )
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
  expect_is(
    mt_batch_subset(
      df = df,
      product = "MOD11A2",
      band = "LST_Day_1km",
      internal = TRUE,
      start = "2004-01-01",
      end = "2004-03-31"
    ),
    "data.frame"
  )

  # good query, too many cores
  expect_is(
    mt_batch_subset(
      df = df,
      product = "MOD11A2",
      band = "LST_Day_1km",
      internal = TRUE,
      start = "2004-01-01",
      end = "2004-03-31",
      ncores = 4
    ),
    "data.frame"
  )

  # write data to disk
  expect_silent(
    mt_batch_subset(
      df = df,
      product = "MOD11A2",
      band = "LST_Day_1km",
      start = "2004-01-01",
      end = "2004-03-31",
      internal = FALSE
    )
  )

  # test batch download
  expect_is(
    mt_batch_subset(
      df = paste0(tempdir(), "/batch.csv"),
      product = "MOD11A2",
      band = "LST_Day_1km",
      internal = TRUE,
      start = "2004-01-01",
      end = "2004-03-31"
    ),
    "data.frame"
  )

  # error, misssing csv
  expect_error(
    mt_batch_subset(
      df = "fail.csv",
      product = "MOD11A2",
      band = "LST_Day_1km",
      internal = TRUE,
      start = "2004-01-01",
      end = "2004-03-31"
    )
  )

  # error missing data frame parameter
  expect_error(
    mt_batch_subset(
      product = "MOD11A2",
      band = "LST_Day_1km",
      internal = TRUE,
      start = "2004-01-01",
      end = "2004-03-31"
    )
  )

  # error bad band name
  expect_error(
    mt_batch_subset(
      df = paste0(tempdir(), "/batch.csv"),
      product = "MOD11A2",
      band = "LST_Day_2km",
      internal = TRUE,
      start = "2004-01-01",
      end = "2004-03-31"
    )
  )
})

# test coordinate conversions




test_that("test mt_batch_subset()",{

  subset <- mt_subset(
    product = "MOD11A2",
    lat = 40,
    lon = -110,
    band = "LST_Day_1km",
    start = "2004-01-01",
    end = "2004-03-31",
    progress = FALSE
  )

  # bind with the original dataframe
  subset <- cbind(subset, lat_lon)

  # test conversion
  expect_is(
    sin_to_ll(subset$xllcorner, subset$yllcorner)
    ,
    "data.frame"
  )

  # test conversion
  expect_is(
    sin_to_ll(subset$xllcorner, subset$yllcorner)
    ,
    "data.frame"
  )

  # test sf bounding box conversion
  expect_is(
  apply(
    cbind(subset, sin_to_ll(subset$xllcorner, subset$yllcorner)),
    1, function(x){
    ll_to_bb(lon = x['longitude_ll'],
             lat = x['latitude_ll'],
             cell_size = x['cellsize'],
             nrows = x['nrows'],
             ncols = x['ncols'])[[1]]
  }),
  "sfc"
  )

})
