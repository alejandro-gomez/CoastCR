CoastCR <img src="inst/image/logo.png" align="right" alt="" width="140" />
=========================================================
# `CoastCR`: Coastal Change using R

<!-- badges: start -->
[![R-CMD-check](https://github.com/alejandro-gomez/CoastCR/workflows/R-CMD-check/badge.svg)](https://github.com/alejandro-gomez/CoastCR/actions)
<!-- badges: end -->
  
## Overview

**CoastCR** is an open source package for computing coastline time series and trend analysis using the baseline and transect approach. This tool is a part of ODSAS (Open Digital Shoreline Analysis System v1.0) which uses both CoastCR and SAGA GIS [1]. CoastCR main input is the points representing the intersections along transects perpendicular to a baseline, of a set of date-stamped coastlines (obtained during mapping stage using SAGA GIS) and calculates the standard metrics of coastline change and rate of change similarly to the metrics produced using Digital Shoreline Analysis System (DSAS) [2, 3].

----

Contents:

* [What is this package used for?](#what-is-this-package-used-for)
* [How it works](#how-it-works)
  * [Installation](#installation)
  * [Examples](#examples)
* [Package citation](#package-citation)
* [Authors](#authors)
* [Contact](#contact)
* [References](#references)

----

## What is this package used for?
Many researchers and practitioners interested on Shoreline Change Analysis often separate the mapping stages (mostly done within a GIS) from the time series and trend analyses, which can be undertaken in a programming environment [1]. This package is intended to be used for the time series and trend analyses using R programming environment which is an open-source software.

The main functions implemented in, `CoastCR` are used to:

-    Compute the **coastline change** using the most common change metrics used on transects to a baseline method. Two main functions are included in the current version to filter and estimate the parameters:

     - ***Baseline filter***: This function is part of the pre-processing stages and is used to ensure that for each baseline-transect, only one crossing with each date-stamped coastline is used. If for a given transect and date-stamped coastline, more than one crossing is found (e.g., as might happen for very wiggly coastlines), the filter selects the crossing that is closest to the baseline and neglects the others.
  
     - ***Coast rates***: This function estimates the main five key measures for each individual transect and also produce aggregates for all transects identically as within the DSAS tool [2]. This five metrics are:
     
        - **NSM**: Net Shoreline Movement (m).
        - **EPR**: End Point Rate (m yr<sup>-1</sup>).
        - **SCE**: Shoreline Change Envelope (m).
        - **LRR**: Linear Regression Rate (m yr<sup>-1</sup>).
        - **WLR**: Weighted Linear Regression Rate (m yr<sup>-1</sup>).

&nbsp;

- ***Coastline Variations*** is the main function that runs the aforementioned functions. First, filters the intersection points and then calculates the key measures of change.
        
## How it works

### Installation

``` r
# To install the latest version from Github:
# install.packages("remotes")
remotes::install_github("alejandro-gomez/CoastCR")
```

### Examples

Coming soon!

## Package citation

Using CoastCR for research publication?  Please **cite it**! I'm an early career scientist and every citation matters.

***Gómez-Pazo, A., Payo, A., Paz-Delgado, M.V., Delgadillo-Calzadilla, M.A.***, (*2022*). *Open Digital Shoreline Analysis System: ODSAS v1.0*. Journal of Marine Science and Engineering, 10, 26. doi: https://doi.org/10.3390/jmse10010026

## Authors

Alejandro Gómez-Pazo

M. Victoria Paz-Delgado

Contributors: Andres Payo and M.A. Delgadillo-Calzadilla

## Contact

Alejandro Gómez-Pazo: a.gomez@usc.es

## References

[1] Gómez-Pazo, A., Payo, A., Paz-Delgado, M.V., Delgadillo-Calzadilla, M.A., 2022. Open Digital Shoreline Analysis System: ODSAS v1.0. Journal of Marine Science and Engineering, 10, 26. doi: https://doi.org/10.3390/jmse10010026

[2] Himmelstoss, E.A., Henderson, R.E., Kratzmann, M.G., Farris, A.S., 2018. Digital Shoreline Analysis System (DSAS) version 5.0 user guide. US Geological Survey Open File Report 2018-1179, 110 pp

[3] Burningham, H.; Fernandez-Nunez, M. 19 - shoreline change analysis. In Sandy beach morphodynamics, Jackson, D.W.T.; Short, A.D., Eds. Elsevier: 2020; pp 439-460.
