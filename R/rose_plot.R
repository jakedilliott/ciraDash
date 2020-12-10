#' Creates a tooltip
#'
#' @export
#' @examples
#' tool_tip("Duration", "A length of time.")
tool_tip <- function(variable, text){
  shiny::renderUI({
    shinyBS::tipify(a(variable), text, placement = "top", trigger = "hover")
  })
}

#' Creates a text box for rationales
#'
#' @export
#' @examples
#' rationale_box("Duration")
rationale_box <- function(name) {
  shiny::textAreaInput(inputId = paste0(name, "_r"),
                       label = "Rationale",
                       resize = "none")
}

#' Takes in rose chart inputs from the UI and outputs a
#' tibble to be used in the ggrose function
clean_rose_inputs <- function(personnel, dispersal, duration,
                              screening, socialdist, masks,
                              localpop, localcov, icu) {

  rose_labels <- c("Personnel", "Dispersal", "Duration",
                   "Screening", "Social \n Distancing", "Wearing \n Masks",
                   "Firefighter \n cases", "Local Covid \n Cases", "Healthcare \n Capacity")

  rating_list <- c(personnel, dispersal, duration,
                   screening, socialdist, masks,
                   localpop, localcov, icu)

  y_list <- purrr::map_dbl(rating_list,
                           function(y) {
                             out <- switch(stringr::str_to_lower(y),
                                           0,
                                           low  = 1,
                                           mod  = 2,
                                           high = 3)
                             return(out)
                           })
  out <- dplyr::tibble(x = rose_labels, y = y_list, rating = rating_list)

  out
}


#' Converts ratings to numeric values, or numeric values to ratings
convert_rating <- function(input) {
  if(is.character(input)) {
    output <- switch(stringr::str_to_lower(input),
                     none = 0,
                     low  = 1,
                     moderate = 2,
                     high = 3)
  } else if(is.numeric(input)) {
    output <- dplyr::case_when(
      input == 1 ~ "Low",
      input == 2 ~ "Mod",
      input == 3 ~ "High")
  } else {
    stop(paste0("invalid 'type' (", class(input), ") of argument"))
  }

  output
}

#' GGRose
#'
#' A graphical wrapper function that takes inputs from the Rose Chart
#' UI page and resturns a graphical output of thos inputs.
#'
#' @return
#' A ggplot object
#'
#' @export
ggrose <- function(personnel, dispersal, duration,
                   screening, socialdist, masks,
                   localpop, localcov, icu,
                   additional_risk, chart_num) {

  color_list <- list("low"  = "#51A3A3",
                     "mod"  = "#F19953",
                     "high" = "#C1292E")
  ## Turn all of the inputs into a tibble with factor names and factor scores
  inputs <- clean_rose_inputs(personnel, dispersal, duration,
                              screening, socialdist, masks,
                              localpop, localcov, icu)

  ## Programs alpha for each chart, calculate category scores, if final chart
  ## then show final result
  if (chart_num == 1) {
    alpha_ <- c(1,1,1, 0,0,0,0,0,0)
    category_alpha <- c(1,0,0)
    line_alpha <- c(1,1,0)
    score <- sum(data.frame(inputs$y[1:3]))
  } else if (chart_num == 2) {
    alpha_ <- c(0,0,0, 1,1,1, 0,0,0)
    category_alpha <- c(0,1,0)
    line_alpha <- c(0,1,1)
    score <- sum(data.frame(inputs$y[4:6]))
  } else if (chart_num == 3) {
    alpha_ <- c(0,0,0,0,0,0, 1,1,1)
    category_alpha <- c(0,0,1)
    line_alpha <- c(1,0,1)
    score <- sum(data.frame(inputs$y[7:9]))
  } else {
    alpha_ <- c(rep(.9, 9))
    category_alpha <- c(1,1,1)
    line_alpha <- c(1,1,1)
    score <- sum(data.frame(inputs$y)) + convert_rating(additional_risk)
  }

  ## Turn score into results depending on chart number
  if (chart_num == 4) {
    score_max <- "/30"
    if (score %in% 9:13) {
      result <- "Low"
      result_color <- color_list$low
    } else if (score %in% 14:18) {
      result <- "Moderate"
      result_color <- color_list$mod
    } else {
      result <- "High"
      result_color <- color_list$high
    }
  } else {
    score_max <- "/9"
    if (score %in% 3:4) {
      result <- "Low"
      result_color <- color_list$low
    } else if (score %in% 5:6) {
      result <- "Moderate"
      result_color <- color_list$mod
    } else if (score %in% 7:9) {
      result <- "High"
      result_color <- color_list$high
    }
  }

  to_plot_y <- sapply(inputs$y, function(y){y+1})
  to_plot <- dplyr::mutate(inputs, y = to_plot_y, alpha = alpha_)

  ## Keep petals in order by changing x to a character then back to vector
  to_plot$x <- as.character(to_plot$x)
  to_plot$x <- factor(to_plot$x, levels = unique(to_plot$x))
  result_xy <- list(x = 8.2, y = 7)
  #We should be able to do this with line segments using geom_segment
  #frame_lines <- tibble(x = c(0.5,3.5,6.5),xend = c(0.5,3.5,6.5),y=c(1,1,1),yend=c(4,4,4))

  p <- ggplot2::ggplot(to_plot, ggplot2::aes(x, y, fill = rating, alpha = alpha_)) +
    ggplot2::coord_polar(direction = -1) +
    ggplot2::geom_col(width = 1, color = "white") +
    ggplot2::scale_fill_manual(values = c("#c1292e", "#51a3a3", "#f19953", "#ffffff"), breaks = c("high", "low", "mod", 0)) +
    ggplot2::annotate(geom = "segment", x=c(0.5,3.5,6.5), xend=c(0.5,3.5,6.5), y=c(1,1,1), yend=c(5,5,5), alpha = line_alpha) +
    ggplot2::geom_col(ggplot2::aes(y=2, alpha = 0), width = 1) +
    ggplot2::geom_col(ggplot2::aes(y=1, alpha = 1), width = 1,fill = "white",color = NA) +
    ggplot2::geom_text(ggplot2::aes(y=1.6, label = convert_rating(y-1)), size = 6) +
    ggplot2::geom_text(ggplot2::aes(y=y+1.25, label = x), nudge_x = c(.1,0,0, 0,0,0, 0,0,0), size = 6) +
    ggplot2::annotate(geom = "text", x = c(2.5,5,7.5), y = c(6.3,6,6.3),
             alpha = category_alpha ,size = 6, fontface = "bold",
             label = c("Camp Risk", "Mitigation Risk", "COVID Risk")) +
    ggplot2::geom_label(x = result_xy$x, y = result_xy$y, size = 7, fill = result_color,
               label = paste("Result: ", result, " \n Score: ", score, score_max)) +
    ggplot2::theme_void() +
    ggplot2::guides(fill = "none") +
    ggplot2::scale_alpha_continuous(range = c(0,1), guide = "none")

  p
}
