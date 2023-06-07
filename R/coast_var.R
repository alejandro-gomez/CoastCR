#' Filter intersections and estimate variation rates
#'
#' \code{coast_var} allows to filter the original intersections and select only the closest intersection between each transect and shoreline.
#'
#' @param shp Shapefile. A point format shapefile with the intersections between each transect and each shoreline.
#' @param normals Shapefile. A polyline format shapefile with all normal lines (transects) included in the study site.
#' @param table CSV. A table with the information about the coastlines dates in format (dd/mm/yyyy) and the associated uncertainty to each coastline in meters. The column names should be "Date" and "Uncertainty".
#' @param position character. Default \code{"MIX"}. \code{position = "MIX"} is recommended for use a coastline as baseline. The baseline position in relation to the coastlines. There are three options: "MIX" for intermediate baselines, "OFF" for offshore baselines, and "ON" for onshore baselines.
#' @param out_points Integer. Output name for the filter intersection points shapefile.
#' @param out_name Integer. Output name for the resulting shapefile with the rates of each transect.
#'
#' @details
#' The \code{coast_var} is the main function included in this \code{CoastCR} version, as part of ODSAS (Gomez-Pazo et al., \emph{2022}).
#' This function runs \code{baseline_filter} and \code{coast_rates} to doing the entire coastal change process.
#' The first step filters the intersection points, to remove the duplicate points
#' and selects the crossing that is closest to the baseline and neglects the others.
#' The second step estimates the main coastal variation rates explained in detail in \code{CoastCR} documentation.
#'
#' @return \itemize{
#'    \item{A shapefile with the filtered intersection points}
#'    \item{A polyline shapefile with all rates associated to each transect.}
#'    \item{A table in png format with the central tendency stats for each parameter.}
#' }
#'
#'
#' @examples
#'
#' #Load libraries
#' library(sf)
#' library(CoastCR)
#' setwd(tempdir())
#'
#' #Intersections shapefile
#' shp <- st_read(system.file("./extdata/intersect.shp", package = "CoastCR"))
#'
#' #Normal lines shapefile
#' normals <- st_read(system.file("./extdata/normals.shp", package = "CoastCR"))
#'
#' #Table with dates and associated uncertainty
#' table <- read.csv(system.file("./extdata/table_coastlines.csv", package = "CoastCR"))
#'
#' #Define baseline position. Offshore = OFF; Onshore = ON; Mixed = MIX.
#' position = "OFF"
#'
#' #Define outputs names
#' out_points <- tempfile("int_filter", fileext = ".shp")
#' out_name <- tempfile("normals_rates", fileext = ".shp")
#'
#' coast_var(shp, normals, table, position, out_points, out_name)
#'
#'
#' @references {
#' Gomez-Pazo, A., Payo, A., Paz-Delgado, M.V., Delgadillo-Calzadilla, M.A. (2022)
#' \emph{Open Digital Shoreline Analysis System: ODSAS v1.0}
#' Journal of Marine Science and Engineering, 10, 26.
#'}
#' @seealso  \code{\link{baseline_filter}}; \code{\link{coast_rates}}
#'
#' @export

coast_var <- function(shp, normals, table, position = "MIX",
                      out_points, out_name) {
  baseline_filter(shp, position, out_points)

  int_d <- st_read(out_points)

  coast_rates(int_d, normals, table, out_name)

}
