# main unit tests

test_that("test download functions",{

  # test listing all products
  products <- try(list_products())

  # see if any of the runs failed
  check = !inherits(products, "try-error")

  # check if no error occured
  expect_true(check)
})
