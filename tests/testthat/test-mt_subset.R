context("test-mt_subset")
library(magrittr)

study_sites <- data.frame(
  site_name = paste("test", 1:2),
  lat = 40,
  lon = -110,
  stringsAsFactors = FALSE
)

subsets <- mt_batch_subset(
  df = study_sites,
  product = "MOD11A2",
  band = "LST_Day_1km",
  internal = TRUE,
  start = "2004-01-01",
  end = "2004-02-28",
  out_dir = tempdir())

test_that("conversion to `sf` works", {
  skip_if_not_installed("sf")
  skip_if_not_installed("purrr")
  skip_if_not_installed("dplyr")
  # single extracts
  expect_silent(
    subsets %>%
      purrr::map_df(mt_tidy) %>%
      head(1) %>%
      dplyr::mutate(
        # these operations could definitely be in `mt_subset`
        xc = xllcorner %>% corner_to_coord,
        yc = yllcorner %>% corner_to_coord,
        geometry = corner_to_sfc(xc, yc)
      ) %>%
      sf::st_as_sf()
  )
  # multiple extracts
  expect_silent(
    subsets %>%
      purrr::map_df(mt_tidy) %>%
      head(2) %>%
      dplyr::mutate(
        xc = xllcorner %>% corner_to_coord,
        yc = yllcorner %>% corner_to_coord,
        geometry = corner_to_sfc(xc, yc)
      ) %>%
      sf::st_as_sf()
  )
})
