
<!-- README.md is generated from README.Rmd. Please edit that file -->

# COVID-19 Incident Risk Assessment Dashboard

<!-- badges: start -->

[![DOI](https://zenodo.org/badge/317966909.svg)](https://zenodo.org/badge/latestdoi/317966909)
[![Last-changedate](https://img.shields.io/badge/last%20change-2021--04--12-yellowgreen.svg)](/commits/master)
<!-- badges: end -->

This tool is intended to support line officer and incident manager
assessment of COVID-19 risk at the incident level. Updated versions may
be provided as both the wildland fire season and our knowledge about
COVID changes.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools") # Install R devtools if you have not already
devtools::install_github("jakedilliott/cira_dashboard")
```

## Example

You can run the CIRA dashboard locally with:

``` r
library(ciraDash)
ciraDash::launch_ciraDash()
```
