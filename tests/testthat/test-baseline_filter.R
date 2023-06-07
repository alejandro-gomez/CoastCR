test_that("baseline_filter", {
  testthat::skip_on_cran()

  test_dir <- tempdir()

  setwd(test_dir)

  shp <- st_read(system.file("./extdata/intersect.shp", package = "CoastCR"))

  dist <- st_read(system.file("./extdata/dist.shp", package = "CoastCR"))

  position = "OFF"

  out_points <- "./inters_filter1.shp"

  baseline_filter(shp, position, out_points)

  res <- st_read("./inters_filter1.shp")

  expect_equal(res, dist, tolerance = 0.0009)

  unlink(test_dir, recursive = TRUE)

})
