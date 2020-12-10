library(shiny)
library(shinydashboard)
library(shinyBS)
library(shinyWidgets)

draft_message <- p(strong("DRAFT 12/10/20: This tool is intended to support line officer and incident
                 manager assessment of COVID-19 risk at the incident level. Updated versions
                 may be provided as both the wildland fire season and our knowledge about COVID
                 changes."))

rose_widths <- list(inputs = 5,
                    graphs = 7,
                    offset = 0)

labels <- c("Low", "Moderate", "High")
label_subtext <- list("(Risk Rating) [Score]", "(Low Risk) [1]", "(Mod Risk) [2]", "(High Risk) [3]")
qual.list <- list("Select One"=0,
                  "Low"="low",
                  "Moderate"="mod",
                  "High"="high")
dur.list <- list("Select One"=0,
                 "Short (< 5 days)"="low",
                 "Medium (5-20 days)"="mod",
                 "Long (> 20 days)"="high")
freq.list <- list("Select One"=0,
                  "Always"="low",
                  "Sometimes"="mod",
                  "Never"="high")
pers.pop <- list("Select One"=0,
                 "Low (50-200)"="low",
                 "Moderate (250-500)"="mod",
                 "High (>500)"="high")
local.pop <- list("Select One"=0,
                  "Low (<=2)"="low",
                  "Moderate (>2, isolated)"="mod",
                  "High (>2, many)"="high")

# Dashboard Sidebar -------------------------------------------------------
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Home", tabName = "home", icon = icon("home")),
    menuItem("Risk Assessment Tool", tabName = "rose_plot", icon = icon("dashboard"))
  )
)

# Dashboard Body ----------------------------------------------------------
body <- dashboardBody(

  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "stylesheet.css")
  ),
  tabItems(

    # Home Tab ----------------------------------------------------------------
    tabItem(
      tabName = "home",
      fluidRow(
        column(
          width = 10, offset = 1,
          box(
            width = NULL,
            h2("COVID-19 Incident Risk Assessment Tool", img(src="team_logo_v1.png", height=170, style = "margin-top:-30px"), align = "center"),
            draft_message,
            p("This online tool was created by Jake Dilliott, Erin Belval, Jude Bayham,
        and Matthew Thompson of the COVID-19 Fire Modeling Team. Feedback can be submitted
        at the bottom of the ", strong("Risk Assessment Tool"), " page and questions or concerns can be sent to ",
              a(href = "mailto: covid.camp.sim@gmail.com", "covid.camp.sim@gmail.com"), ".")
          ),
          box(title = "Disclaimer:", width = NULL, status = "warning", solidHeader = TRUE,
              p("This information is for the purpose of informing USDA Forest Service
               considerations for 2020 COVID-19 wildfire response and is not intended
               for external use. The assessment tools are those of the author(s) and
               should not be construed to represent any official USDA or U.S. Government
               determination policy."),
              p("This tool is not intended for any official record keeping or documentation,
               and is for informational use only."))
        )
      ),
      fluidRow(
        column(
          width = 10, offset = 1,

          box(
            title = "Risk Assessment Tool", width = NULL, status = "primary", solidHeader = TRUE,
            p("A tool for assessing incident level risk based on 9 variables
             related to Camp/ICP Risks, Mitigations, and Community/Local COVID Risks. Risk is
             represented using rose charts with 1 petal for each of the 9 veriables, and length/color
             of each petal coresponding with a risk score. For a walkthrough of this tool visit our ",
              strong(
                a(href = "https://vimeo.com/446881251/9a60394b0c", "Webinar Tutorial.", id="vimeo-webinar")
              )),
            p(strong("Getting Started")),
            tags$ol(
              tags$li("Go to the ", strong("Risk Assessment Tool"), " page using the navigation menu to the left."),
              tags$li("Select 1 option from each of the 9 sub-factor dropdowns."),
              p(em("Charts will show up automatically as you fill in all 3 dropdowns for each risk factor.")),
              tags$li("Fill in the Rationale boxes next to each dropdown with a short justification for your selection.", strong("*")),
              tags$li("If you would like a PDF report containing the Final Risk Assessment chart along with a table of current inputs and rationales, press
                       the ", strong("Download Report"), " next to the Final Risk Assessment chart"),
              tags$li("Fill in the Info and Feedback section at the bottom of the dashboard page, click submit, and wait for a confirmation pop up.", strong("*")),
              p(em(strong("*"), " = These steps are optional, your opinions and feedback appreciated, but not required."))
            )
          ),
          box(title = "Additional Resources For The Risk Assessment Tool", width = NULL, status = "primary", solidHeader = FALSE,
              p("For more information on interpretation and assessment of risk factors you can download this PDF document
                with details on each one of the 3 risk factors and 9 sub-factors. You can also find this information on the
                next page by hovering your mouse over each sub-factor title, which will show a pop-up describing each sub-factor."),
              downloadBttn(outputId = "rf_supplement",
                           style = "simple",
                           label = "Risk Factors Supplement",
                           size = "sm"),
              br(),
              p("If you would like to use the framework for this tool offline, you can click the download button below
                to download a PDF Worksheet with intructions on how to fill out a COVID-19 Incident Risk Assessment
                by hand."),
              downloadBttn(outputId = "worksheet",
                           style = "simple",
                           label = "COVID-19 Incident Risk Assessment Worksheet",
                           size = "sm"))
        )
      ),
      fluidRow(
        HTML("<center>
            <img src='csu_stacked.png' height=130>
            <img src='usda.png' height=86>
            <img src='usfs.png' height=92 style='margin-left:10px'>
            <img src='fire_science.jpg' height=104>
          </center>")
      )
    ), # /tabItem: homepage

    # Rose Plot Tab -----------------------------------------------------------
    tabItem(tabName = "rose_plot",
            fluidRow(
              column(
                width = 10, offset = 1,
                box(
                  width = NULL,
                  h2("COVID-19 Incident Risk Assessment Tool", img(src="team_logo_v1.png", height=170, style = "margin-top:-30px"), align = "center"),

                  draft_message
                )
              )
            ),

            fluidRow(
              column(
                width = rose_widths$inputs, offset = rose_widths$offset,
                box(title = "ICP/Fire Camp Risk Status", width = NULL, status = "primary",
                    solidHeader = TRUE,
                    p("Factors generally relating to the layout of the ICP/camp/base,
                    number of personnel assigned, and duration of the fire, which
                    in turn affect the nature and frequency of contacts, exposure
                    potential, and disease dynamics. Within the fire camp all three
                    sub-factors are within the control of fire leadership. However,
                    number of personnel and camp duration should be decided upon
                    in order to meet the needs of the fire, and control over camp
                    dispersal should be used to mitigate COVID related risk."),

                    fluidRow(
                      column(width=6,
                             pickerInput(inputId = "personnel",
                                         uiOutput("tt_personnel"),
                                         choices = pers.pop,
                                         choicesOpt = list(subtext = label_subtext)),
                             pickerInput(inputId = "dispersal",
                                         uiOutput("tt_dispersal"),
                                         choices = list("Select One"=0,
                                                        "High Dispersal" = "low",
                                                        "Moderate Dispersal" = "mod",
                                                        "Low Dispersal" = "high"),
                                         choicesOpt = list(subtext = label_subtext)),
                             pickerInput(inputId = "duration",
                                         uiOutput("tt_duration"),
                                         choices = dur.list,
                                         choicesOpt = list(subtext = label_subtext))
                      ),
                      column(width=6,
                             rationale_box(name = "personnel"),
                             rationale_box(name = "dispersal"),
                             rationale_box(name = "duration"))
                    )
                )
              ),
              column(
                width = rose_widths$graphs,
                box(
                  width = NULL, status = "success",
                  plotOutput("camp", height = "500px"))
              )
            ),

            fluidRow(
              column(
                width = rose_widths$inputs, offset = rose_widths$offset,
                box(title = "Mitigation Implementation Risk Status", width = NULL,
                    solidHeader = TRUE, status = "primary",
                    p("Factors generally relating to behaviors of personnel in camp(s)
                    and when interacting with other individuals, which in turn
                    affect the spread dynamics of the disease. See the ",
                      a(href="https://www.cdc.gov/coronavirus/2019-ncov/community/wildland-firefighters-faq.html",
                        "CDC FAQs for Wildland Firefighters"), " and ",
                      a(href="https://sites.google.com/a/firenet.gov/fmb/home/covid19-portal/wildland-fire-covid-19-screening-information",
                        "MPHAT Screening Tool"),
                      ". Fire Leadership has control over all three variables associated with mitigation."),
                    fluidRow(
                      column(width = 6,
                             pickerInput(inputId = "screening",
                                         uiOutput("tt_screening"),
                                         choices = freq.list,
                                         choicesOpt = list(subtext = label_subtext)),
                             pickerInput(inputId = "socialdist",
                                         uiOutput("tt_socialdist"),
                                         choices = list("Select One"=0,
                                                        "High compliance" = "low",
                                                        "Moderate compliance" = "mod",
                                                        "Low compliance" = "high"),
                                         choicesOpt = list(subtext = label_subtext)),
                             pickerInput(inputId = "masks",
                                         uiOutput("tt_masks"),
                                         choices = freq.list,
                                         choicesOpt = list(subtext = label_subtext)),
                      ),
                      column(width = 6,
                             rationale_box(name = "screening"),
                             rationale_box(name = "socialdist"),
                             rationale_box(name = "masks")
                      )
                    )
                )
              ),
              column(
                width = rose_widths$graphs,
                box(width = NULL, status = "success", plotOutput("mitigation", height = "500px"))
              )
            ),

            fluidRow(
              column(
                width = rose_widths$inputs, offset = rose_widths$offset,
                box(title = "COVID Risk Status", width = NULL,
                    solidHeader = TRUE, status = "primary",
                    p("Factors generally relating to the number of COVID cases in and outside of
                  the camp and local healthcare capacity that could affect the likelihood of firefighter exposure
                    or ability to treat ill firefighters. Consider factors
                    cited in the ",
                      a(href="https://www.nifc.gov/nicc/administrative/nmac/NMAC2020-22UPDATED_a1.pdf",
                        "NMAC Interagency Checklist for Mobilization of Resources in a COVID-19 Environment"),", ",
                      a(href="http://fsweb.wo.fs.fed.us/covid/pdf/FS_Guidance_Protocols-USDA_Reopening.pdf",
                        "FS Guidance and Protocols to Implement USDA Reopening Playbook(internal FS link.)"),
                      " The number of firefighter cases and their risk to the rest of the camp are affected
                    by Camp Dispersal and Mitigation Risk Factors, while number of local COVID cases and Healthcare
                    Capacity are outside the control of fire leadership."),
                    fluidRow(
                      column(width = 6,
                             pickerInput(inputId = "localpop",
                                         uiOutput("tt_localpop"),
                                         choices = local.pop,
                                         choicesOpt = list(subtext = label_subtext)),
                             pickerInput(inputId = "localcov",
                                         uiOutput("tt_localcov"),
                                         choices = qual.list,
                                         choicesOpt = list(subtext = label_subtext)),
                             pickerInput(inputId = "icu",
                                         uiOutput("tt_icu"),
                                         choices = list("Select One"=0,
                                                        "High capacity" = "low",
                                                        "Moderate capacity" = "mod",
                                                        "Low capacity" = "high"),
                                         choicesOpt = list(subtext = label_subtext))
                      ),
                      column(width = 6,
                             rationale_box(name = "localpop"),
                             rationale_box(name = "localcov"),
                             rationale_box(name = "icu"))
                    )
                )
              ),
              column(
                width = rose_widths$graphs,
                box(width = NULL, status = "success", plotOutput("community", height = "500px"))
              )
            ),

            fluidRow(
              column(
                width = rose_widths$inputs, offset = rose_widths$offset,
                box(title = "Additional Risk Factors", width = NULL, solidHeader = TRUE,
                    status = "primary",
                    p("Additional risk factors to consider include exessive smoke exposure in camp or
                           on fire line, and camp resources originating from areas with high COVID risk.
                           Acting as a proxy for factors not addressed earlier in the model, this is a subjective
                           input and meant to account for additional factors that may be the concern of line
                           officers or incidient managers."),
                    column(width=6,
                           sliderTextInput(inputId = "additional_risk",
                                           uiOutput("tt_additional_risk"),
                                           choices = c("None", "Low", "Moderate","High"),
                                           grid = TRUE,
                                           force_edges = TRUE,
                           )),
                    column(width=6,
                           rationale_box(name = "additional_risk"))),

                box(title = "Final Assessment of Relative Risk", width = NULL, solidHeader = TRUE,
                    status = "primary",
                    p("The resulting risk values from the three COVID-19 risk categories above
                           (ICP/Fire Camp Risk Status, Mitigation Implementation Risk Status, and COVID Risk Status) are automatically filled
                           in for the final risk assessment. Assessment results are intended to complement local evaluation and expert judgment."),
                    p(strong("A PDF report containing the Final Risk Assessment chart, all 9 sub-factor choices, scores, and rationales.")),
                    downloadBttn(outputId = "report",
                                 label = "Download Report",
                                 style = "simple",
                                 color = "success",
                                 size = "sm")
                )
              ),
              column(
                width = rose_widths$graphs,
                box(width = NULL, status = "success", plotOutput("relative", height = "500px"))
              )
            ),
            HTML("<center>
                   <img src='csu_stacked.png' height=130>
                   <img src='usda.png' height=86>
                   <img src='usfs.png' height=92 style='margin-left:10px'>
                   <img src='fire_science.jpg' height=104>
                 </center>")
    ) # /tabItem: rose_plot
  ) # /tabItems
) # /dashboardbody

## This sets up the dashboard
ui <- dashboardPage(
  dashboardHeader(title = "COVID Camp Assessment Dashboard", titleWidth = 400),
  sidebar,
  body
)
