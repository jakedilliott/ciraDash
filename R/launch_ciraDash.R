#' Launches the CIRA Dashboard as a shiny app
#' @param ... Additional args for \code{shiny::runApp}
#' @export
launch_ciraDash <- function(...) {
  shiny::runApp(appDir = system.file("application", package = "ciraDash"),
                ...)
}
