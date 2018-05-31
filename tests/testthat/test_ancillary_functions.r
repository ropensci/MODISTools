# ancillary unit tests

test_that("test read write functions",{

  # download data
  subset_disk = try(get_subset(product = "MOD11A2",
                               lat = 40,
                               lon = -110,
                               band = "LST_Day_1km",
                               start = "2004-01-01",
                               end = "2004-03-31",
                               internal = FALSE))

  # read file
  df = try(read_subset(paste0(tempdir(),
                  "/sitename_MOD11A2_2004-01-01_2004-03-31.csv")))

  # see if any of the runs failed
  check = !inherits(df, "try-error") &
          !inherits(subset_disk, "try-error")

  # check if no error occured
  expect_true(check)
})
