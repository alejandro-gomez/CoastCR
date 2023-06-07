test_that("coast_rates", {
  testthat::skip_on_cran()

  setwd(tempdir())

  dist <- st_read(system.file("./extdata/normals_coast_rate.shp", package = "CoastCR"))

  shp <- st_read(system.file("./extdata/intersect.shp", package = "CoastCR"))

  normals <- st_read(system.file("./extdata/normals.shp", package = "CoastCR"))

  table <- read.csv(system.file("./extdata/table_coastlines.csv", package = "CoastCR"))

  position = "OFF"

  out_points <- "./int_filter.shp"
  out_name <- "./normals_rates.shp"

  coast_var(shp, normals, table, position, out_points, out_name)
  res <- st_read("./normals_rates.shp")

  expect_equal(res, dist)

})
