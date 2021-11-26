#' Coastline Variations
#'
#' \code{coast_var} allows to filter the original interesections and select only the closest intersection between each transect and coastline.
#'
#' @param shp Shapefile. A point format shapefile with the intersections between each transect and the coastlines.
#' @param normals Shapefile. A polyline shapefile with all normal lines included in the study site.
#' @param table CSV. A table with the information about the coastlines dates in format (dd/mm/yyyy) and the associated uncertainty to each coastline in meters. The column names should be "Date" and "Uncertainty".
#' @param position character. The baseline position in relation to the coastlines. The options are: offshore, put "OFF"; onshore, put "ON"; or intermediate, put "MIX".
#' @param out_points Integer. Output name for the filter intersection points shapefile.
#' @param out_name Integer. Output name for the resulting shapefile with the rates to each transect.
#'
#' @details
#' The
#'
#' @return \itemize{
#'    \item{A shapefile with the filtered intersection points}
#'    \item{A polyline shapefile with all rates associated to each transect.}
#'    \item{A table in png format with the central tendency stats for each parameter.}
#' }
#'
#'
#' @examples
#' # Load data
#'
#' @export

coast_var <- function(shp, normals, table, position, out_points, out_name) {
  baseline_filter(shp, position, out_points)

  int_d <- st_read(out_points)

  coast_rates(int_d, normals, table, out_name)

}
