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
test_that("test terra conversion",{
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

  multi_band <- mt_subset(product = "MCD12Q1",
                          lat = 48.383662,
                          lon = 2.610250,
                          band = c("LC_Type1","LC_Type2"),
                          start = "2005-01-01",
                          end = "2005-06-30",
                          km_lr = 2,
                          km_ab = 2,
                          site_name = "testsite",
                          internal = TRUE,
                          progress = FALSE)

  # good conversion into stack
  expect_silent(mt_to_terra(subset))

  # multi-band error
  expect_error(mt_to_terra(multi_band))

  # not a data frame
  expect_error(mt_to_terra(df = "not a dataframe"))

  # missing input
  expect_error(mt_to_terra())
})

