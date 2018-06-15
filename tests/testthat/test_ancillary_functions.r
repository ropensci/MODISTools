# ancillary unit tests

test_that("test read write functions",{

  # download data
  subset = try(mt_subset(product = "MOD11A2",
                              site_name = "sitename",
                              lat = 40,
                              lon = -110,
                              band = "LST_Day_1km",
                              start = "2004-01-01",
                              end = "2004-02-01",
                              internal = TRUE))

  # write file
  write_file = try(mt_write(subset))

  # read file
  subset_disk = try(mt_read(paste0(tempdir(),
                  "/sitename_MOD11A2_2004-01-01_2004-02-01.csv")))

  # see if data formats equal eachother
  equals = identical(subset, subset_disk)

  # see if any of the runs failed
  check = equals &
          !inherits(write_file,"try-error") &
          !inherits(subset,"try-error") &
          !inherits(subset_disk, "try-error")

  # check if no error occured
  expect_true(check)
})
