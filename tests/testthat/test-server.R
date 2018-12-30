context("test-server")

test_that("error messages from server are shown to the user", {
  skip_on_cran()
  # temporary wrapper
  ss <- function(lon, lat) {
    mt_subset(product = "MOD11A2",
              lat = lat,
              lon = lon,
              band = "LST_Day_1km",
              start = "2004-01-01",
              end = "2004-01-02",
              progress = FALSE)
  }

  expect_silent(
    x <- ss(-110, 40)
  )
  expect_error(
    ss(40, -110),
    "Invalid argument: Latitude must be between -90 and 90 degrees."
  )
  expect_error(
    ss(400, -40),
    "Invalid argument: Longitude must be between -180 and 180 degrees."
  )
})
