#' Baseline filter
#'
#' \code{baseline_filter} allows to filter the original interesections and select only the closest intersection between each transect and coastline.
#'
#' @param shp Shapefile. A point format shapefile with the intersections between each transect and the coastlines.
#' @param position character. The baseline position in relation to the coastlines. The options are: offshore, put "OFF"; onshore, put "ON"; or intermediate, put "MIX".
#' @param out_points Integer. Output name for the resulting shapefile.
#'
#' @details
#' The
#'
#' @return \itemize{
#'    \item{A shapefile with the filtered intersection points}
#' }
#'
#' @import sf dplyr tidyverse tidyr stringr
#'
#' @examples
#' # Load data
#'
#' @export

baseline_filter <- function(shp, position, out_points) {
  if (position == "OFF"){
    shp2 <- shp %>%
      dplyr::filter(Distance < 0) %>%
      unite(ID_02, c("ID_Profile", "ID_Coast"))%>%
      group_by(ID_02) %>%
      dplyr::filter(Distance == max(Distance)) %>%
      mutate(Normal = sub("_.*","", ID_02),
             Coast = sub(".*_","", ID_02))
    st_write(shp2, out_points)

  } else if (position == "ON"){
    shp2 <- shp %>%
      dplyr::filter(Distance > 0) %>%
      unite(ID_02, c("ID_Profile", "ID_Coast"))%>%
      group_by(ID_02) %>%
      dplyr::filter(Distance == min(Distance)) %>%
      mutate(Normal = sub("_.*","", ID_02),
             Coast = sub(".*_","", ID_02))
    st_write(shp2, out_points)

  } else if (position == "MIX"){
    shp2 <- shp %>%
      mutate(abs = abs(Distance)) %>%
      unite(ID_02, c("ID_Profile", "ID_Coast"))%>%
      group_by(ID_02) %>%
      dplyr::filter(abs == min(abs))%>%
      mutate(Normal = sub("_.*","", ID_02),
             Coast = sub(".*_","", ID_02))
    st_write(shp2, out_points)

  } else{
    print("ERROR")
  }
}

