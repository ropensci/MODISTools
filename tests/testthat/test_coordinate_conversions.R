context("Ancillary functions")

# test coordinate conversions
test_that("test coordinate transforms",{
  skip_on_cran()
  subset <- mt_subset(
    product = "MOD11A2",
    lat = 40,
    lon = -110,
    band = "LST_Day_1km",
    start = "2004-01-01",
    end = "2004-03-31",
    progress = FALSE
  )

  # test conversion
  expect_is(
    sin_to_ll(x = subset$xllcorner, y = subset$yllcorner)
    ,
    "data.frame"
  )

  # test conversion missing parameter
  expect_error(
    sin_to_ll(x = subset$xllcorner)
  )

  # test sf bounding box conversion
  expect_is(
    apply(subset,1, function(x){
      mt_bbox(xllcorner = x['xllcorner'],
              yllcorner = x['yllcorner'],
              cellsize = x['cellsize'],
              nrows = x['nrows'],
              ncols = x['ncols'])
    })[[1]],
    "sfc"
  )

  # test sf bounding box conversion missing parameter
  expect_error(
    apply(sbuset, 1, function(x){
      mt_bbox(cellsize = x['cellsize'],
              nrows = x['nrows'],
              ncols = x['ncols'])
    })
  )
})

# test raster conversions
test_that("test raster conversion",{
  skip_on_cran()
  subset <- mt_subset(
    product = "MOD11A2",
    lat = 40,
    lon = -110,
    band = "LST_Day_1km",
    start = "2004-01-01",
    end = "2004-03-31",
    progress = FALSE
  )

 # good conversion
 expect_silent(mt_to_raster(subset))

 # not a data frame
 expect_error(mt_to_raster(df = "not a dataframe"))

 # missing input
 expect_error(mt_to_raster())
})

