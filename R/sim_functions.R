#' Make Entry Exit Data
#'
#' This is data generated as a stand in for real ROSS data.
#' If there is no Entry/Exit data given to the SEIR Setup function
#' it will use this function to create data.
#'
#' @param t Numeric input, a length of time
#' @example
#' make_entry_exit(45)
make_entry_exit <- function(t){
  #This function is a stand in for ross data coming from Erin
  entry = (10+7*t+.5*t^2-.01*t^3)/10
  entry[entry<0] = 0
  exit = rep(0,length=length(t))
  t.index = length(entry)-14
  exit[15:length(exit)] = entry[1:t.index]
  return(cbind(entry,exit))
}




#Function to construct the parameter matrix
#' SEIR Setup
#'
#' Constructs a parameter data frame for use in the SEIR model function
#'
#' @param t Simulation duration, in days
#' @param R0 Basic reproduction number
#' @param De Incubation period, in days
#' @param Di Infectious period, in days
#' @param N.init Initial population
#' @param I.init Initial number of infected individuals
#' @param eir Entry Infection Rate
#' @param varying Parameters that vary over time
#' @export
#' @example
#' SEIR_setup(t = 70, R0 = 2.68, De = 5, Di = 3, N.init = 10, I.init = 1, eir = 0.1, varying = highline)
SEIR_setup <- function(t=70,
                       R0=2.68,
                       De=5,
                       Di=3,
                       N.init=10,
                       I.init=1,
                       eir=.1,
                       varying){
  # Set time vector
  time <- seq(0,t,1)

  # Build parameter matrix
  static <- c(R0 = R0,
              De = De,
              Di = Di,
              eir = eir)

  if (missing(varying)) {
    time_varying <- make_entry_exit(time)
  } else {
    if (is.null(colnames(varying))) {
      stop("Matrix varying must be named.")
    }
    time_varying <- varying
  }

  param_names <- c(names(static), colnames(time_varying))
  parameters <- cbind(matrix(static,
                             nrow = nrow(time_varying),
                             ncol = length(static),
                             byrow = T),
                      time_varying)

  colnames(parameters) <- param_names

  # Set init
  init <- c(S = N.init-I.init,
            E = 0,
            I = I.init,
            R = 0,
            N = N.init,
            D = 0)

  return(list(time = time, init = init, parameters = parameters))
}


#' Defining the SEIR equations
#'
#' A series of differential equations used by the SEIR_entry_exit function
#' to run the model
#'
#' @param time Length of time
#' @param state Initial states
#' @param parameters Parameters that change
SEIR_eqn <- function(time, state, parameters){
  with(as.list(c(state,parameters)),{
    dS <- -(R0/Di)*(S*I/N) + (1-eir)*entry - (S/N)*exit       #Susceptible
    dE <- (R0/Di)*(S*I/N) + (eir)*entry - E/De - (E/N)*exit   #Exposed
    dI <- E/De - I/Di - (I/N)*exit                            #Infected
    dR <- I/Di - (R/N)*exit                                   #Removed
    dN <- entry - exit                                        #Population
    dD <- ((E)/N)*exit + (I/N)*exit + (R/N)*exit              #Demob infected
    #dW <- I/Di-(R/14)                                        #Workforce out sick:
    # if recovery period is 14 days, change in sick workforce is the newly removed minus those recovering
    return(list(c(dS,dE,dI,dR,dN,dD)))}
  )
}

#' Die Out Function
#'
#' @param x Number of infected individuals
#' @param m Die out threshold
die_out_fun <- function(x, m = .02){
  sum(stats::runif(x)>m)
}

#' SEIR Epi Model wrapper
#'
#' This function wraps the solver and formats output data for plotting and processing
#'
#' @param inputs A data frame that was created with the SEIR_setup function
#' @param equation The desired set of differential equations
#' @param .die_out Logical, implement stochastic die out
SEIR_entry_exit <- function(inputs, equation, .die_out = FALSE){
  # Parsing the input list
  time <- inputs$time
  init <- inputs$init
  parameters <- inputs$parameters

  #Define the shell to populate
  shell <- vector("list",length = nrow(parameters))

  #Setting the first element to the initial settings
  shell[[1]] <- init

  #Set index for infectious class
  i_index <- which(names(init)=="I")

  #Extracting names from parameters to reuse
  name_temp <- names(parameters[1,])

  #Solving the ODE
  for (i in c(1:(length(time)-1))) {
    if (i>1) {
      #Reset initial values where sim ended yesterday
      init <- shell[[i-1]][2,c(2:(length(init)+1))]

      if (.die_out == TRUE) {
        if (init[i_index]>0) {
          #Stochastic die out
          init[i_index] <- die_out_fun(round(init[i_index]), m = .02)

          if (init[i_index]==0) {
            break
          }
        }
      }
    }
    #Grabbing parameters for each time step (and renaming the vector)
    param_temp <- parameters[i,]
    names(param_temp) <- name_temp

    shell[[i]] <- deSolve::ode(y      = init,
                               times  = c(time[i], time[i]+1),
                               func   = equation,
                               parms  = param_temp,
                               method = "ode45")
    # shell[[i]] <- ifelse(shell[[i]] < 0, 0, shell[[i]])
  }

  out <- purrr::map_dfr(shell,
                        function(x){
                          dplyr::slice(as.data.frame(x), 2)
                        })

  return(out)
}
