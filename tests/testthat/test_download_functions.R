context("Test downloads")

# test functions without parameters
# only can fail upon server error
test_that("test mt_products()",{
  skip_on_cran()
  expect_is(mt_products(), "data.frame")
})

test_that("test mt_sites()",{
  skip_on_cran()
  expect_is(mt_sites(), "data.frame")
})

test_that("test mt_bands()",{
  skip_on_cran()
  expect_is(mt_bands(product = "MOD11A2"), "data.frame")
  expect_error(mt_bands(product = "MOD11A6"))
})

# download tests
test_that("test mt_dates()",{
  skip_on_cran()

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
  skip_on_cran()

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

  # dates out of range
  expect_error(
    mt_subset(
      product = "MOD11A2",
      lat = 40,
      lon = -110,
      band = "LST_Day_1km",
      start = "1990-01-01",
      end = "1990-02-20",
      progress = FALSE
    )
  )

  # no band provided
  expect_error(
    mt_subset(
      product = "MOD11A2",
      lat = 40,
      lon = -110,
      start = "2004-01-01",
      end = "2004-02-20",
      progress = FALSE
    )
  )

  # bad band provided
  expect_error(
    mt_subset(
      product = "MOD11A2",
      lat = 40,
      lon = -110,
      band = "LST_Day_0km",
      start = "2004-01-01",
      end = "2004-02-20",
      progress = FALSE
    )
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

  # wrong product provided
  expect_error(
    mt_subset(
      product = "MOD11AZ",
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
  skip_on_cran()

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

  # test batch download from csv
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

  # error bad product name
  expect_error(
    mt_batch_subset(
      df = df,
      product = "MOD11AZ",
      band = "LST_Day_1km",
      internal = TRUE,
      start = "2004-01-01",
      end = "2004-03-31"
    )
  )

  # error missing product
  expect_error(
    mt_batch_subset(
      df = df,
      band = "LST_Day_1km",
      internal = TRUE,
      start = "2004-01-01",
      end = "2004-03-31"
    )
  )

  # error bad band name
  expect_error(
    mt_batch_subset(
      df = df,
      product = "MOD11A2",
      band = "LST_Day_0km",
      internal = TRUE,
      start = "2004-01-01",
      end = "2004-03-31"
    )
  )

  # missing band name
  expect_error(
    mt_batch_subset(
      df = df,
      product = "MOD11A2",
      internal = TRUE,
      start = "2004-01-01",
      end = "2004-03-31"
    )
  )
})
