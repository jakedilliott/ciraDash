# functions used in the report.rmd

#' Show selection
#'
#' Change ratings back into selections
#' @export
show_selection <- function(personnel, dispersal, duration,
                           screening, socialdist, masks,
                           localpop, localcov, icu,
                           additional_risk) {
  personnel <- switch(personnel,
                      low="Low(50-200)",
                      mod="Moderate (200-500)",
                      high="High (>500)")
  dispersal <- switch(dispersal,
                      mod="Moderate",
                      low="High",
                      high="Low")
  duration <- switch(duration,
                     low="Short (<5 Days)",
                     mod="Medium (5-20 Days)",
                     high="Long (>5 Days)")
  screening <- switch(screening,
                      low="Always",
                      mod="Sometimes",
                      high="Never")
  socialdist <- switch(socialdist,
                       low="High",
                       mod="Moderate",
                       high="Low")
  masks <- switch(masks,
                  low="Always",
                  mod="Sometimes",
                  high="Never")
  localpop <- switch(localpop,
                     low="Low (<50k)",
                     mod="Moderate (50-250k)",
                     high="High (>250k)")
  localcov <- switch(localcov,
                     low="Low",
                     mod="Moderate",
                     high="High")
  icu <- switch(icu,
                low="High",
                mod="Moderate",
                high="Low")
  return(list(personnel, dispersal, duration,
              screening, socialdist, masks,
              localpop, localcov, icu,
              additional_risk))
}

#' Switch function for additional_risk
#' @export
switch_additional <- function(additional) {
  switch(stringr::str_to_lower(additional),
         "none"=0,
         "low"=1,
         "moderate"=2,
         "high"=3)
  }

