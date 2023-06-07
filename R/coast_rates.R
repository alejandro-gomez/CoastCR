#' Calculate the coastal variation rates
#'
#' \code{coast_rates} estimate the main parameters about the coastal variations, as NSM, LRR or WLR.
#'
#' @param inter_dist Shapefile. A point format shapefile with the intersections between each transect and the shoreline.
#' @param normals Shapefile. A polyline format shapefile with all normal lines (transects) included in the study site.
#' @param table CSV. A table with the information about the coastlines dates in a column named "Day" in format (YYYYY-mm-dd). If the information about the acquisition hour is available, the user should introduce a column called "Hour" in format (HH:MM:SS) and the associated uncertainty to each coastline in meters. The column names should be "Day", "Hour" and "Uncertainty".
#' @param out_name Integer. Output name for the resulting shapefile with the rates of each transect.
#'
#' @details
#' This function is part of ODSAS method (Gomez-Pazo et al., \emph{2022}) and estimates the main five key measures for each individual transect and also produce aggregates
#' for all transects identically as within the DSAS tool (Himmelstoss et al., 2018).
#' The rates and their units are explained in detail in \code{CoastCR} documentation.
#'
#' @return \itemize{
#'    \item{A polyline shapefile with all rates associated to each transect.}
#'    \item{A csv file with the central tendency stats and quantiles .25, .75 and .90 for each parameter.}
#' }
#'
#' @references {
#' Gomez-Pazo, A., Payo, A., Paz-Delgado, M.V., Delgadillo-Calzadilla, M.A. (2022)
#' \emph{Open Digital Shoreline Analysis System: ODSAS v1.0}
#' Journal of Marine Science and Engineering, 10, 26.
#'
#' Himmelstoss, E.A., Henderson, R.E., Kratzmann, M.G., Farris, A.S. (2018)
#' \emph{Digital Shoreline Analysis System (DSAS) version 5.0 user guide}
#' US Geological Survey Open File Report 2018-1179, 110 pp
#'}
#' @seealso  \code{\link{baseline_filter}}; \code{\link{coast_var}}
#'
#' @import qwraps2
#'
#' @importFrom stats dist
#' @importFrom stats na.omit
#' @importFrom utils write.csv
#' @importFrom psych describe
#'
#' @examples
#' library(sf)
#' library(CoastCR)
#' setwd(tempdir())
#'
#' #Normal lines shapefile
#' normals <- st_read(system.file("./extdata/normals.shp", package = "CoastCR"))
#'
#' #Table with dates and associated uncertainty
#' table <- read.csv(system.file("./extdata/table_coastlines.csv", package = "CoastCR"))
#'
#' #Filtered intersections shapefile
#' inter_dist <- st_read(system.file("./extdata/dist.shp", package = "CoastCR"))
#'
#' #Define output name
#' out_name <- tempfile("normals_coast_rates", fileext = ".shp")
#'
#' coast_rates(inter_dist, normals, table, out_name)
#'
#'
#' @export

coast_rates <- function(inter_dist, normals, table, out_name) {
  if ("Hour" %in% colnames(table)) {
    table$Date <- as.POSIXlt(paste(table$Day, table$Hour, sep = ""), format = "%Y-%m-%d %H:%M:%S")
  } else {
    table$Date <- as.POSIXlt(table$Day, format = "%Y-%m-%d")
  }

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
    yrs <- Reduce(function(...) merge(..., by="Normal", all = TRUE), list1)
  }
  mm_Dates <- c(paste("D", min(table$Date), sep = "_"),
                paste("D", max(table$Date), sep = "_"))
  SCE_val <- NULL
  normals2 <- normals %>%
    dplyr::select(1)%>%
    merge(yrs, by = "Normal", all.x = TRUE)%>%
    mutate(NSM = (get(mm_Dates[2]) - get(mm_Dates[1])),
           EPR = NSM / (as.numeric(abs(difftime(min(table$Date),
                                                max(table$Date), units = "days")/365))),
           EPRunc = (sqrt((as.numeric(
             table$Uncertainty[table$Date==max(table$Date)])^2) +
               (as.numeric(
                 table$Uncertainty[table$Date==min(table$Date)])^2)))/
             (as.numeric(abs(difftime(min(table$Date), max(table$Date),
                                      units = "days")/365)))) %>%
    dplyr::select(Normal, NSM, EPR, EPRunc, everything())

  list2 <- NULL
  SCE_comp <- normals2 %>%
    st_drop_geometry() %>%
    mutate(SCE_max = do.call(pmax, c(select(., 5:ncol(.)), na.rm = TRUE)),
           SCE_min = do.call(pmin, c(select(., 5:ncol(.)), na.rm = TRUE)),
           SCE = abs(SCE_max - SCE_min)) %>%
    dplyr::select(Normal, SCE)
  normals3 <- merge(normals2, SCE_comp, by="Normal", all = TRUE) %>%
    dplyr::select(Normal, NSM, EPR, EPRunc, SCE, everything())

  list3 <- NULL
  ancient <- paste("D", min(table$Date), sep = "_")
  for (z in 1:nrow(normals3)){
    St_P <- NULL
    for (k in 1:nrow(table)){
      if (ancient == paste("D", table$Date[k], sep = "_")){
        Dist_c <- normals[z,] %>%
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
                 Distance_C = as.numeric(get(paste("D", table$Date[k],
                                                   sep = "_")) -
                                           get(paste("D", min(table$Date), sep = "_"))),
                 w_C = 1/(as.numeric(table$Uncertainty[k])^2)) %>%
          dplyr::select(Normal, Date_C, Distance_C, w_C)
        assign(paste("Dist_n", table$Date[k], sep = "_"), Dist_c)
        list3 <- Dist_c
      } else{
        stop("Dates information is not correct, check date format.")
      }
      St_P <- rbind(St_P, na.omit(list3))
    }
    mean_Date <- mean(St_P$Date_C, na.rm = TRUE)
    mean_Dist <- mean(St_P$Distance_C, na.rm = TRUE)
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
  st_write(normals4, out_name)

  n4 <- normals4%>%
    st_drop_geometry()
  summary_data <- describe(n4[ ,c("NSM", "EPR", "EPRunc", "SCE", "LRR", "WLR")],
                           quant = c(.25,.75,.90)) %>%
    dplyr::select("n", "mean", "sd", "median", "min", "max", "range",
                  "Q0.25", "Q0.75", "Q0.9")
  names(summary_data) <- c("n", "Mean", "SD", "Median", "min", "Max", "Range",
                           "Quantile .25", "Quantile .75", "Quantile .9")
  write.csv(summary_data, paste0(gsub(".shp*$","_summary",out_name),".csv"))
}
