expand_names <- function(){
  out <- data.frame(pop_class   = c("S", "E", "I",
                                    "R", "N", "D",
                                    "A", "Q", "TI"),
                    description = c("Susceptible", "Exposed", "Infectious",
                                    "Removed", "Population", "Demob Infected",
                                    "Asymptomatic", "Quarantined", "Cumulative Infected"))
  return(out)
}


SEIR_to_plot <- function(fire_data, Rnot_, eir_) {
  varying_data <- dplyr::transmute(fire_data,
                                   entry = fire_data$from_home + fire_data$from_fire,
                                   exit  = fire_data$to_home + fire_data$to_fire)

  setup_info <- SEIR_setup(t = length(fire_data$day),
                           R0 = Rnot_,
                           I.init = 2,
                           eir = eir_,
                           varying_data)
  epi_sim <- SEIR_entry_exit(setup_info, SEIR_eqn)
  output <- dplyr::mutate(epi_sim,
                          fire = fire_data$inc_number[1],
                          short_fire_name = fire_data$inc_name[1],
                          RNot = Rnot_,
                          entry_inf_rt = eir_)
  return(output)
}

SEIR_plot <- function(fire_params, log_scale = TRUE, legend_pos, plot_type = "all_states", ...) {

  expanded_names <- expand_names()

  if (plot_type == "all_states") {
    states <- c("S", "E", "I", "R")
    state_levels <- c("Susceptible", "Exposed", "Infectious", "Removed")
  } else if (plot_type == "infected_states") {
    states <- c("E", "I", "R")
    state_levels <- c("Exposed", "Infectious", "Removed")
  }

  filtered <- dplyr::select(fire_params, fire, time, dplyr::all_of(states))
  pivoted  <- tidyr::pivot_longer(filtered, cols = dplyr::all_of(states), names_to = "pop_class", values_to = "value")
  joined   <- dplyr::inner_join(pivoted, expanded_names, by = c("pop_class"))
  mutated  <- dplyr::mutate(joined, description = factor(description, levels = expanded_names$description))
  baseline_to_plot <- tidyr::drop_na(mutated)

  baseline_to_plot$description <- as.character(baseline_to_plot$description)
  baseline_to_plot$description <- factor(baseline_to_plot$description, levels = state_levels)

  p_out <- ggplot2::ggplot(data = baseline_to_plot, ggplot2::aes(x = time, y = value, fill = description)) +
    ggplot2::scale_fill_manual(name = "",
                               values = c("#1B9E77", "#D95F02", "#7570B3", "#E7298A"),
                               breaks = c("Susceptible", "Exposed","Infectious","Removed")) +
    ggplot2::geom_bar(width = 1, stat = "identity", position = "stack") +
    ggplot2::theme_bw(base_size = 18) +
    ggplot2::theme(legend.position = legend_pos,
                   legend.background = ggplot2::element_blank()) +
    ggplot2::labs(x="Days Since Ignition",
                  y="",
                  ...)

  if(log_scale == TRUE){
    p_out <- p_out + ggplot2::scale_y_log10()
  }

  return(p_out)
}

## Unit Test
# SEIR_test <- SEIR_to_plot(selected_fire = "lolo_peak",
#                                Rnot_ = 2.68,
#                                eir_ = 0.01)
# SEIR_plot(fire_params = SEIR_test,
#           log_scale = FALSE,
#           legend_pos = c(.9, .8),
#           plot_type = "all_states",
#           title = "Highline Susceptible, Exposed, Infectious, and Removed")



cumulative_inf <- function(fire_params, log_scale = FALSE, legend_pos, ...) {

  expanded_names <- expand_names()

  with_TI  <- dplyr::mutate(fire_params, TI = fire_params$D+fire_params$R)
  filtered <- dplyr::select(with_TI, fire, time, N, TI)
  pivoted  <- tidyr::pivot_longer(filtered, cols = c(N, TI), names_to = "pop_class", values_to = "value")
  joined   <- dplyr::inner_join(pivoted, expanded_names, by = c("pop_class"))
  mutated  <- dplyr::mutate(description = factor(description, levels = expanded_names$description))
  baseline_to_plot <- tidyr::drop_na(mutated)

  baseline_to_plot$description <- as.character(baseline_to_plot$description)
  baseline_to_plot$description <- factor(baseline_to_plot$description, levels = c("Population", "Cumulative Infected"))

  p_out <- ggplot2::ggplot(data = baseline_to_plot, ggplot2::aes(x = time, y = value, color = description)) +
    ggplot2::scale_color_brewer(name = "", palette = "Dark2") +
    ggplot2::geom_line(size = 2) +
    ggplot2::theme_bw(base_size = 16) +
    ggplot2::theme(legend.position = legend_pos,
                   legend.background = ggplot2::element_blank()) +
    ggplot2::labs(x = "Days Since Ignition",
                  y = "",
                  ...)

  if(log_scale == TRUE){
    p_out <- p_out + ggplot2::scale_y_log10()
  }

  return(p_out)
}

## Unit Test
# cumulative_inf(fire_params = highline_test,
#                log_scale = FALSE,
#                legend_pos = c(0.9, 0.9),
#                title = "Testing Epi Plot")

total_inf <- function(output_of_runs, R0, entry_inf_rate, selected_fire,
                        log_scale = TRUE, legend_pos, ...){
  expanded_names <- expand_names()

  filtered <- dplyr::filter(dplyr::bind_rows(output_of_runs),
                            RNot == R0 & entry_inf_rate == entry_infected_rate & short_fire_name == selected_fire)
  with_TI  <- dplyr::mutate(filtered, TI = D+R)
  selected <- dplyr::select(with_TI, fire, time, TI)
  pivoted  <- tidyr::pivot_longer(selected, cols = c(TI), names_to = "pop_class", values_to = "value")
  joined   <- dplyr::inner_join(pivoted, expanded_names, by = c("pop_class"))
  mutated  <- dplyr::mutate(joined, description = factor(description, levels = expanded_names$description))
  baseline_to_plot <- tidyr::drop_na(mutated)

  p_out <- ggplot2::ggplot(data = baseline_to_plot, ggplot2::aes(x = time, y = value, fill = description)) +
    ggplot2::scale_color_brewer(name="", palette = "Dark2") +
    ggplot2::geom_line(size = 1, color = "red") +
    ggplot2::theme_bw() +
    ggplot2::theme(legend.position = legend_pos,
          legend.background = ggplot2::element_blank()) +
    ggplot2::labs(x="Days Since Ignition",
         y="",
         ...)

  if(log_scale == TRUE){
    p_out <- p_out + ggplot2::scale_y_log10()
  }

  return(p_out)

}

## Unit test
# total_inf(output_of_runs = vary_r0_and_ee,
#             R0 = 2.68,
#             entry_inf_rate = 0.01,
#             selected_fire = "LOLO PEAK",
#             log_scale = TRUE,
#             legend_pos = c(.9, .9),
#             title = "Total Infected")
