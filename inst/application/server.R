server <- function(input, output, session){

  # Camp Risk Assessment Tool -----------------------------------------------
  # Plot 1
  campListen <- reactive ({
    list(input$personnel, input$dispersal, input$duration)
  })
  observeEvent(campListen(), {
    if (input$personnel != 0 && input$dispersal != 0 && input$duration != 0) {
      output$camp <- renderPlot({
        ggrose(personnel = input$personnel, dispersal = input$dispersal, duration = input$duration,
               screening = input$screening, socialdist = input$socialdist, masks = input$masks,
               localpop = input$localpop, localcov = input$localcov, icu = input$icu,
               additional_risk = input$additional_risk, chart_num = 1)
      })
    }
  })

  # Plot 2
  mitigationListen <- reactive ({
    list(input$screening, input$socialdist, input$masks)
  })
  observeEvent(mitigationListen(), {
    if (input$screening !=0 && input$socialdist !=0 && input$masks !=0) {
      output$mitigation <- renderPlot({
        ggrose(personnel = input$personnel, dispersal = input$dispersal, duration = input$duration,
               screening = input$screening, socialdist = input$socialdist, masks = input$masks,
               localpop = input$localpop, localcov = input$localcov, icu = input$icu,
               additional_risk = input$additional_risk, chart_num = 2)
      })
    }
  })

  # Plot 3
  communityListen <- reactive ({
    list(input$localpop, input$localcov, input$icu)
  })
  observeEvent(communityListen(), {
    if (input$localpop !=0 && input$localcov !=0 && input$icu !=0) {
      output$community <- renderPlot({
        ggrose(personnel = input$personnel, dispersal = input$dispersal, duration = input$duration,
               screening = input$screening, socialdist = input$socialdist, masks = input$masks,
               localpop = input$localpop, localcov = input$localcov, icu = input$icu,
               additional_risk = input$additional_risk, chart_num = 3)
      })
    }
  })

  # Plot 4
  allInputsListen <- reactive({
    list(input$personnel, input$dispersal, input$duration,
         input$screening, input$socialdist, input$masks,
         input$localpop, input$localcov, input$icu,
         input$additional_risk)
  })
  observeEvent(allInputsListen(), {
    if (input$personnel != 0 && input$dispersal != 0 && input$duration != 0 &&
        input$screening !=0 && input$socialdist !=0 && input$masks !=0 &&
        input$localpop !=0 && input$localcov !=0 && input$icu !=0) {
      output$relative <- renderPlot({
        ggrose(personnel = input$personnel, dispersal = input$dispersal, duration = input$duration,
               screening = input$screening, socialdist = input$socialdist, masks = input$masks,
               localpop = input$localpop, localcov = input$localcov, icu = input$icu,
               additional_risk = input$additional_risk, chart_num = 4)
      })
    }
  })



  # Input Tooltips ----------------------------------------------------------
  output$tt_personnel <- tool_tip(variable = "Number of Personnel",
                                  text = "All else being equal, the greater the number of personnel assigned, the higher the likelihood of an infected individual getting missed by screening or the higher the likelihood of person-to-person contact and exposure. Thus, this variable is asking for the total personnel assigned to the fire who are not 	working remotely.")

  output$tt_dispersal <- tool_tip(variable = "Camp Dispersal",
                                  text = "All else being equal, the less dispersed personnel are at camp, the higher the likelihood of person-to-person contact and exposure. This variable is rating if the fire camp is highly dispersed with little interaction between firefighters outside of work on the fireline/ICP (highly dispersed) or if fire camp is functioning more traditionally, with high levels of interaction between personnel.")

  output$tt_duration <- tool_tip(variable = "Camp Duration",
                                 text = "All else being equal, the longer the duration of the incident, the higher the likelihood of an infected individual entering camp and disease spreading throughout the camp population. This variable is counting days since the fire response began.")

  output$tt_screening <- tool_tip(variable = "Screening Frequency",
                                  text = 'All else being equal, screening and/or testing lower the opportunities for infected individuals to enter the fire. A screening tool has been provided by MPHAT. Screening must occur at least every time an individual arrives at the fire and daily thereafter to be classified as “always.”')

  output$tt_socialdist <- tool_tip(variable = "Social Distancing Discipline",
                                   text = 'All else being equal, higher levels of social distancing lessen chances for the disease to spread. This term refers to adherence to “module of one” concept, keeping six feet distances between individuals, and minimizing all contacts outside of module as one, including minimizing contact with the general public. This does NOT refer to any camp dispersal measures as those are accounted for elsewhere.')

  output$tt_masks <- tool_tip(variable = "Wearing Masks",
                              text = 'All else being equal, more frequent use of cloth masks by personnel lowers the overall camp risk. Cloth masks prevent the spread of disease as a form of source control, and are thus protective for the camp as a whole, but are not PPE intended to provide protection for the individual wearing the mask.')

  output$tt_localpop <- tool_tip(variable = "Firefighter Cases",
                                 text = 'All else being equal, as the number of firefighter cases goes up, so does the likelihood of additional exposures and infections. This variable is tracking both the number of individual cases and their location in the overall population – if infections are seen across multiple crews or “modules,” then the possibility of within-camp transmission and outbreak risk is greater.')

  output$tt_localcov <- tool_tip(variable = "Local COVID Cases",
                                 text = "All else being equal, the more prevalent the disease is in the surrounding community, the higher the likelihood of exposure if there are contacts with community members. Consider also evaluating 14-day trajectories of documented cases per official state and regional gating criteria.")

  output$tt_icu <- tool_tip(variable = "Local Healthcare Capacity (ICU Beds Available)",
                            text = "All else being equal, the lower the local capacity to treat firefighters should they become infected, the greater the concern over health outcomes. The important factor is the number of ICU beds relative to amount of fire personnel.")

  output$tt_examples <- tool_tip(variable = "Example Scenarios",
                                 text = "Some example scenarios that use different R0 and EIR Values.")

  output$tt_R0 <- tool_tip(variable = "Infection Rate",
                           text = 'This slider controls the rate at which new infections occur within camps. Within the context of the model it controls the rate at which individuals move from Susceptible to Exposed.')

  output$tt_eir <- tool_tip(variable = "Entry Infected Rate",
                            text = "This slider controls the percent of individuals entering the fire as infected. New infections are assumed to enter the Exposed class.")

  # output$tt_additional_risk <- tool_tip(variable = "Additional Risk Factors",
  #                             text = "A proxy for factors not addressed earlier in the model. This is a subjective input and meant to account for additional factors that may be the concern of line officers or incidient managers.")

  # Download handlers for sub-factor supplement and CIRA worksheet
  output$rf_supplement <- downloadHandler(
    filename = "Interpreting-and-Assessing-Risk-Factors-v4.pdf",
    content = function(file) {
      file.copy("www/risk-factor-supplement-v4.pdf", file)
    }
  )

  output$worksheet <- downloadHandler(
    filename = "CIRA-Worksheet-v5.pdf",
    content = function(file) {
      file.copy("www/cira-worksheet-v5.pdf", file)
    }
  )

  # Handles the pdf report for download
  output$report <- downloadHandler(
    filename = "covid_risk_report.pdf",
    content = function(file) {

      # Create a temp file directory in case of permissions errors once deployed
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("www/report.Rmd", tempReport, overwrite = TRUE)

      # These are the parameters that get passed to the Rmd file, first inputs then rationales
      params <- list(personnel = input$personnel, dispersal = input$dispersal, duration = input$duration,
                     screening = input$screening, socialdist = input$socialdist, masks = input$masks,
                     localpop = input$localpop, localcov = input$localcov, icu = input$icu,
                     additional_risk = input$additional_risk,
                     personnel_r = input$personnel_r, dispersal_r = input$dispersal_r, duration_r = input$duration_r,
                     screening_r = input$screening_r, socialdist_r = input$socialdist_r, masks_r = input$masks_r,
                     localpop_r = input$localpop_r, localcov_r = input$localcov_r, icu_r = input$icu_r,
                     additional_risk_r = input$additional_risk_r)

      # Knit the document passing the params list
      rmarkdown::render(tempReport, output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv()))
    }
  )
}
