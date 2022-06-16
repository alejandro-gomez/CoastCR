test_that("coast_rates", {
  testthat::skip_on_cran()

  normals <- st_read(system.file("./extdata/normals.shp", package = "CoastCR"))

  table <- read.csv(system.file("./extdata/table_coastlines.csv", package = "CoastCR"))

  inter_dist <- st_read(system.file("./extdata/dist.shp", package = "CoastCR"))

  dist <- st_read(system.file("./extdata/normals_coast_rates.shp", package = "CoastCR"))

  out_name <- "./normals_coast_rates.shp"

  coast_rates(inter_dist, normals, table, out_name)

  res <- st_read("./normals_coast_rates.shp")

  expect_equal(res, dist)

})
