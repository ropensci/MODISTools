# main unit tests

test_that("test download functions",{

  # test listing all products
  products <- try(list_products())

  # test listing all products
  bands <- try(list_bands(product = "MOD11A2"))
  bands_err <- try(list_bands(product = "MOD11A6"))

  # see if any of the runs failed
  check = !inherits(products, "try-error") &
          !inherits(bands, "try-error") &
          inherits(bands_err, "try-error")

  # check if no error occured
  expect_true(check)
})
