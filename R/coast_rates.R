#' Coast Rates
#'
#' \code{coast_rates} estimate the main parameters about the coastal variations.
#'
#' @param inter_dist Shapefile. A point format shapefile with the intersections between each transect and the coastlines.
#' @param normals Shapefile. A polyline shapefile with all normal lines included in the study site.
#' @param table CSV. A table with the information about the coastlines dates in format (dd/mm/yyyy) and the associated uncertainty to each coastline in meters. The column names should be "Date" and "Uncertainty".
#' @param out_name Integer. Output name for the resulting shapefile with the rates to each transect.
#'
#' @details
#' The
#'
#' @return \itemize{
#'    \item{A polyline shapefile with all rates associated to each transect.}
#'    \item{A table in png format with the central tendency stats for each parameter.}
#' }
#'
#' @import qwraps2 gtsummary webshot
#'
#' @importFrom stats dist
#' @importFrom stats na.omit
#' @importFrom gt gtsave
#'
#' @examples
#' # Load data
#'
#' @export


coast_rates <- function(inter_dist, normals, table, out_name) {
  webshot::install_phantomjs(
    version = "2.1.1",
    baseURL = "https://github.com/wch/webshot/releases/download/v0.3.1/",
    force = FALSE)

  table$Date <- as.Date(table$Date, "%d/%m/%Y")
  list1 <- NULL
  for (i in 1:nrow(table)){
    name_d <- paste("D", table$Date[i], sep = "_")
    name_t <- paste("Y", table$Date[i], sep = "_")
    a <- inter_dist %>%
      st_drop_geometry() %>%
      mutate(dist = ifelse(Coast == i-1, Distance, NA)) %>%
      group_by(Normal) %>%
      dplyr::filter(!is.na(dist)) %>%
      dplyr::select(Normal, dist)
    names(a) <- c("Normal", paste("D", table$Date[i], sep = "_"))
    assign(paste("Y", table$Date[i], sep = "_"), a)
    list1[[i]] <- a
    yrs = Reduce(function(...) merge(..., by="Normal", all=T), list1)
  }
  mm_Dates <- c(paste("D", min(table$Date), sep = "_"),
                paste("D", max(table$Date), sep = "_"))
  SCE_val <- NULL
  normals2 <- normals %>%
    dplyr::select(1)%>%
    merge(yrs, by = "Normal", all.x = T)%>%
    mutate(NSM = (get(mm_Dates[2]) - get(mm_Dates[1])),
           EPR = NSM / (as.numeric(abs(difftime(min(table$Date), max(table$Date), units = "days")/365))),
           EPRunc = (sqrt((as.numeric(table$Uncertainty[table$Date==max(table$Date)])^2) +
                            (as.numeric(table$Uncertainty[table$Date==min(table$Date)])^2)))/
             (as.numeric(abs(difftime(min(table$Date), max(table$Date), units = "days")/365)))) %>%
    dplyr::select(Normal, NSM, EPR, EPRunc, everything())

  list2 <- NULL
  SCE_comp <- normals2 %>%
    st_drop_geometry() %>%
    mutate(SCE_max = do.call(pmax, c(select(., 5:ncol(.)), na.rm = TRUE)),
           SCE_min = do.call(pmin, c(select(., 5:ncol(.)), na.rm = TRUE)),
           SCE = abs(SCE_max - SCE_min)) %>%
    dplyr::select(Normal, SCE)
  normals3 <- merge(normals2, SCE_comp, by="Normal", all=T) %>%
    dplyr::select(Normal, NSM, EPR, EPRunc, SCE, everything())

  list3 <- NULL
  ancient <- paste("D", min(table$Date), sep = "_")
  for (z in 1:nrow(normals3)){
    St_P <- NULL
    for (k in 1:nrow(table)){
      if (ancient == paste("D", table$Date[k], sep = "_")){
        Dist_c <- normals3[z,] %>%
          st_drop_geometry() %>%
          mutate(Date_C = as.numeric(0),
                 Distance_C = as.numeric(0),
                 w_C = 1/(as.numeric(table$Uncertainty[k])^2)) %>%
          dplyr::select(Normal, Date_C, Distance_C, w_C)
        assign(paste("Dist_n", table$Date[k], sep = "_"), Dist_c)
        list3 <- Dist_c
      } else if (ancient != paste("D", table$Date[k], sep = "_")){
        Dist_c <- normals3[z,] %>%
          st_drop_geometry() %>%
          mutate(Date_C = as.numeric(abs(difftime(min(table$Date),
                                                  table$Date[k], units = "days")/365)),
                 Distance_C = as.numeric(get(paste("D", table$Date[k], sep = "_")) -
                                           get(paste("D", min(table$Date), sep = "_"))),
                 w_C = 1/(as.numeric(table$Uncertainty[k])^2)) %>%
          dplyr::select(Normal, Date_C, Distance_C, w_C)
        assign(paste("Dist_n", table$Date[k], sep = "_"), Dist_c)
        list3 <- Dist_c
      } else{
        print("ERROR")
      }
      St_P <- rbind(St_P, na.omit(list3))
    }
    mean_Date <- mean(St_P$Date_C, na.rm = T)
    mean_Dist <- mean(St_P$Distance_C, na.rm = T)
    SS <- 0
    SCP <- 0
    totalSS <- 0
    for (x in 1:nrow(St_P)){
      SS <- (SS + (St_P$Date_C[x]- mean_Date)^2)
      SCP <- (SCP + (St_P$Date_C[x]- mean_Date)*(St_P$Distance_C[x]- mean_Dist))
      totalSS <- totalSS + ((St_P$Distance_C[x]- mean_Dist)^2)
    }
    b <- SCP/SS
    LRR <- b
    normals3$LRR[z] <- LRR
    r2 <- b * SCP
    residualsSS <- totalSS - (b * SCP)
    LR2 <- (b * SCP) / totalSS
    normals3$LR2[z] <- LR2
    sumW <- 0
    sumWX <- 0
    sumWY <- 0
    sumWXY <- 0
    sumWYY <- 0
    sumWXX <- 0
    for (v in 1:nrow(St_P)){
      sumW <- sumW + St_P$w_C[v]
      sumWY <- sumWY + (St_P$w_C[v] * St_P$Distance_C[v])
      sumWX <- sumWX + (St_P$w_C[v] * St_P$Date_C[v])
      sumWXX <- sumWXX + (St_P$w_C[v] * St_P$Date_C[v] * St_P$Date_C[v])
      sumWYY <- sumWYY + (St_P$w_C[v] * St_P$Distance_C[v] * St_P$Distance_C[v])
      sumWXY <- sumWXY + (St_P$w_C[v] * St_P$Date_C[v] * St_P$Distance_C[v])
      SS_w <- sumWXX - (sumWX * sumWX/sumW)
      SCP_w <- sumWXY - (sumWX * sumWY/sumW)
      totalSS_w <- sumWYY - (sumWY * sumWY / sumW)
    }
    b_w <- SCP_w/SS_w
    WLR <- b_w
    normals3$WLR[z] <- WLR
    regressionSS_W <- b_w * SCP_w
    residualSS_W <- totalSS_w - regressionSS_W
    WR2 <- regressionSS_W / totalSS_w
    normals3$WR2[z] <- WR2
  }
  normals4 <- normals3 %>%
    dplyr::select("Normal", "NSM", "EPR", "EPRunc",
                             "SCE", "LRR", "LR2", "WLR", "WR2")
  st_write(normals4, out_name) #Export the new shapefile.

  normals4 %>% select(NSM, EPR, SCE, LRR, WLR) %>% st_drop_geometry()%>%
    tbl_summary(type = all_continuous() ~ "continuous2",
                statistic = list(all_continuous() ~ c("{mean}", "{sd}",
                                                      "{min}", "{median}", "{max}")),
                digits = all_continuous() ~ 3, missing = "no") %>%
    modify_header(label ~ "**Parameters**") %>% bold_labels() %>% as_gt() %>%
    gt::gtsave(filename = paste(gsub(".shp*$","", out_name), ".png"))
}
