#This script reads in Erin's data and constructs the entry and exit measures for epi simulation

#' Read ROSS
#'
#' Takes in summarized ROSS data, cleans it up and returns a
#' data frame that can be used by the SEIR diff-eq model
#'
#' @param path File path
#' @export
#' @example
#' read_ross("/inputs/fire_01.csv")
read_ross <- function(path){
  data_in <- readr::read_csv(path)
  names_clean <- janitor::clean_names(data_in, "snake")
  w_inc_num <- dplyr::mutate(names_clean,
                              inc_number = paste0(inc_name, " (", inc_number, ")"),
                              day = seq(1, nrow(names_clean), 1))
  final <- dplyr::select(.data = w_inc_num,
                         inc_number,
                         inc_name,
                         total_personnel,
                         from_home = mobed_from_home,
                         from_fire = mobed_from_fire,
                         to_home   = demobed_to_home,
                         to_fire   = demobed_to_fire,
                         date,
                         day)
  return(final)
}
