# main unit tests

test_that("test download functions",{

  # test listing all products
  products <- try(list_products())

  # test listing all products
  bands <- try(list_bands(product = "MOD11A2"))

  # see if any of the runs failed
  check = !inherits(products, "try-error") &
    !inherits(bands, "try-error")

  # check if no error occured
  expect_true(check)
})
