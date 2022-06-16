#' Filter the intersections between transects and shorelines
#'
#' \code{baseline_filter} allows to filter the original intersections and select only the closest intersection between each transect and coastline.
#'
#' @param shp Shapefile. A point format shapefile with the intersections between each transect and each shoreline.
#' @param position character. Default \code{"MIX"}. \code{position = "MIX"} is recommended for use a coastline as baseline. The baseline position in relation to the coastlines. There are three options: "MIX" for intermediate baselines, "OFF" for offshore baselines, and "ON" for onshore baselines.
#' @param out_points Integer. Output name for the filter intersection points shapefile.
#'
#' @details
#' This function is part of the pre-processing stages and is used to ensure that for each baseline-transect,
#' only one crossing with each date-stamped coastline is used.
#' The filter selects the crossing that is closest to the baseline and neglects the others (Gomez-Pazo et al., \emph{2022}).
#'
#' @return \itemize{
#'    \item{A shapefile with the filtered intersection points, only one point for each transect/shoreline pair.}
#'}
#'
#'@references {
#' Gomez-Pazo, A., Payo, A., Paz-Delgado, M.V., Delgadillo-Calzadilla, M.A. (2022)
#' \emph{Open Digital Shoreline Analysis System: ODSAS v1.0}
#' Journal of Marine Science and Engineering, 10, 26.
#'}
#' @seealso  \code{\link{coast_var}}; \code{\link{coast_rates}}
#'
#' @import sf dplyr tidyverse tidyr stringr
#'
#' @examples
#' \dontrun{
#' #Load libraries
#' library(sf)
#' library(CoastCR)
#'
#' #Intersections shapefile
#' shp <- st_read(system.file("./extdata/intersect.shp", package = "CoastCR"))
#'
#' #Define baseline position. Offshore = OFF; Onshore = ON; Mixed = MIX.
#' position = "OFF"
#'
#' #Define output name
#' out_points <- "./inters_filter.shp"
#'
#' baseline_filter(shp, position, out_points)
#' }
#'
#' @export

baseline_filter <- function(shp, position = "MIX", out_points) {
  if (position == "OFF"){
    shp2 <- shp %>%
      dplyr::filter(Distance < 0) %>%
      unite(ID_02, c("ID_Profile", "ID_Coast"))%>%
      group_by(ID_02) %>%
      dplyr::filter(Distance == max(Distance)) %>%
      dplyr::distinct(ID_02, .keep_all = TRUE) %>%
      mutate(Normal = sub("_.*","", ID_02),
             Coast = sub(".*_","", ID_02))
    st_write(shp2, out_points)

  } else if (position == "ON"){
    shp2 <- shp %>%
      dplyr::filter(Distance > 0) %>%
      unite(ID_02, c("ID_Profile", "ID_Coast"))%>%
      group_by(ID_02) %>%
      dplyr::filter(Distance == min(Distance)) %>%
      dplyr::distinct(ID_02, .keep_all = TRUE) %>%
      mutate(Normal = sub("_.*","", ID_02),
             Coast = sub(".*_","", ID_02))
    st_write(shp2, out_points)

  } else if (position == "MIX"){
    shp2 <- shp %>%
      mutate(abs = abs(Distance)) %>%
      unite(ID_02, c("ID_Profile", "ID_Coast"))%>%
      group_by(ID_02) %>%
      dplyr::filter(abs == min(abs))%>%
      dplyr::distinct(ID_02, .keep_all = TRUE) %>%
      mutate(Normal = sub("_.*","", ID_02),
             Coast = sub(".*_","", ID_02))
    st_write(shp2, out_points)

  } else{
    print("ERROR")
  }
}

