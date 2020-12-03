#' Launch Application
#'
#' Launches the CIRA Dashboard as a shiny app
#' @param ... Additional args for \code{shiny::runApp}
#' @export
#' @example
#' launch_application(...)
launch_application <- function(...) {
  shiny::runApp(appDir = system.file("application", package = "ciraDash"),
                ...)
}
