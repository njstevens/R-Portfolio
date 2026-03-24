library(shiny)
library(shinycssloaders)
library(shinydashboard)
library(shinyWidgets)
library(shinythemes)
library(zoo)
library(bslib)
# This sets the working directory to wherever app.R lives
tryCatch({
  # Case 1: Interactive session in RStudio
  app_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
}, error = function(e) {
  # Case 2: When running via Run App / deployed / command line
  app_dir <- dirname(normalizePath(sys.frames()[[1]]$ofile, mustWork = FALSE))
})

# Fallback: if neither method works (e.g., shinyapps.io), use current working directory
if (is.null(app_dir) || app_dir == "") {
  app_dir <- getwd()
}

setwd(app_dir)
message("Working directory set to: ", app_dir)

# Now source other scripts relative to this directory
source(file.path(app_dir, "Loss Simulation Functions.R"))
source(file.path(app_dir, "generated_data_for_loss_simulation.R"))



# Define UI for application that draws a histogram
ui <- fluidPage(
  useShinydashboard(),
  tags$head(
    tags$style(HTML("
    input[type='radio'] {
      accent-color: #337ab7;
    }
  "))
  ),
  tags$style(HTML('#clicks{border-color: #000; background-color: #000; color: #FFFFFF }')),
  tags$style(HTML('#Deductible{border-color: #000;}')),
  tags$style(HTML('#MemberNum{border-color: #000;}')),
  tags$style(HTML('#title{color: #000; font-family:Verdana}')),
  tags$style(HTML('#mem{color: #000; font-family:Verdana;font-weight: bold;}')),
  tags$style(HTML('#ded{color: #000; font-family:Verdana;font-weight: bold;}')),
  tags$style(HTML('#str{color: #000; font-family:Verdana; font-weight: bold;}')),
  tags$style(HTML('#adj{color: #000; font-family:Verdana; font-weight: bold;}')),
  tags$style(HTML("
    .radio-inline {
      white-space: nowrap;
      margin-right: 20px;
    }
  ")),
  tags$style(HTML("
  #app-header {
    display: flex;
    align-items: center;
    gap: 20px;            /* <-- FIXED separation */
    padding-left: 10px;
  }
  

  #app-logo {
    height: 80px;
    flex-shrink: 0;       /* logo never squishes */
  }
  
    #title {
    font-family: 'Inter', sans-serif;
    font-weight: 600;
  }
  
.dygraph-wrapper {
  width: 100%;
  overflow: hidden;
}

.dygraph-legend {
  max-width: 100%;
  white-space: normal !important;
  word-break: break-word;
}

")),

  setBackgroundImage(src = "white_waves_opt.png"),
  #setBackgroundColor(color = c("#A9D7F6","#F1BC5F"), gradient = "linear", direction = "bottom"),
  titlePanel(
    div(
      id = "app-header",
      # tags$img(
      #   src = "utah_logo.png",
      #   id = "app-logo"
      # ),
     
      h1(id = "title",
         icon("project-diagram"), 
         "General Liability Loss Simulator"
         )
    )
  ),
  
  sidebarLayout(position = "left",
                sidebarPanel(width = 4,
                             style = "background-color: rgba(255, 255, 255, 0.65);
                             border: 2px solid rgba(0, 0, 0, 0.2);
                             backdrop-filter: blur(2px);
                             -webkit-backdrop-filter: blur(2px);",           
                             virtualSelectInput("MemberNum",
                                          h6(id = "mem","Member Number"), 
                                          choices = premium_data$member_number,
                                          selected = premium_data$member_number[1],
                                          search = TRUE
                                          ),  
                             numericInput("Deductible", h6(id = "ded","Deductible"), value = NULL),
                             
                             radioButtons("Strategy", h6(id = "str","Select Strategy"),
                                         choices = list("Low Risk",
                                                        "Standard",
                                                        "High Risk"),
                                         inline = TRUE,
                                         selected = "Standard"),
                             helpText("Pricing Strategies: ",br(),
                                      "Low Risk - Focuses on a heavier pricing decrease for improved losses, only keeps high increases for severe increases in loss frequency Rewards lower loss ratios more heavily as well",br(),
                                      "Standard - geared to lower loss ratios without unreasonable increases in premiums",br(),
                                      "High Risk - Very little reward for improved loss frequency, bigger increases."
                                      ),
                             # 
                             
                             sliderInput("p_pareto", "Catastrophe Probability (per claim)",
                                         min = 0, max = 0.10, value = 0.02, step = 0.001),
                             
                             helpText("Manually adjust the probability of catastrophic loss"),
                             
                             actionButton("clicks", "Run Simulator")),
                
                
                
                mainPanel(
                  fluidRow(
                    box(
                      tabsetPanel(
                        type = "pills",
                        tabPanel(
                          "Severity Assesment",
                          div(
                            class = "dygraph-wrapper",
                            dygraphOutput("sev_assess")
                          )
                        ),
                        tabPanel(
                          "Frequency Assessment",
                          div(
                            class = "dygraph-wrapper",
                            dygraphOutput("freq_assess")
                          )
                        )
                      ),
                      title = "Loss Assessment",
                      width = 15
                    ),
                    tags$script(HTML("
                    $('.box').css({
                    'background': 'rgba(255, 255, 255, 0.65)',
                    'border': '2px solid rgba(0, 0, 0, 0.25)',
                    'backdrop-filter': 'blur(2px)',
                    '-webkit-backdrop-filter': 'blur(2px)',
                    'box-shadow': '0 8px 24px rgba(0, 0, 0, 0.2)'});
                                     ")
                    )
                  ),
                  fluidRow(
                    box(
                      div(
                        class = "dygraph-wrapper",
                        plotlyOutput("Simulator", height = "60vh") %>% withSpinner(color = "#000", type = 6)
                      ),
                      title = "Simulated Loss Ratios",
                      width = 15
                    ),
                    tags$script(HTML("
                    $('.box').css({
                    'background': 'rgba(255, 255, 255, 0.65)',
                    'border': '2px solid rgba(0, 0, 0, 0.25)',
                    'backdrop-filter': 'blur(2px)',
                    '-webkit-backdrop-filter': 'blur(2px)',
                    'box-shadow': '0 8px 24px rgba(0, 0, 0, 0.2)'});
                                     ")
                                )
                  )
                )
              )
  )

# Define server logic required to draw a histogram
server <- function(input, output) {

  
  output$sev_assess <- renderDygraph({
    LossesAssesment(loss_data,premium_data,input$MemberNum,output = "Severity")
  })
  
  output$freq_assess <- renderDygraph({
    LossesAssesment(loss_data,premium_data,input$MemberNum,output = "Frequency")
  })
  
  RunSim <- eventReactive(input$clicks, {

        run_simulations(
          LRData        = premium_data,
          losses        = loss_data,
          membernumber  = input$MemberNum,
          Deductible    = as.numeric(input$Deductible),
          p_pareto = as.numeric(input$p_pareto),
          n_sims        = 200,
          n_show        = 20,
          prc_strat = input$Strategy
        )
     
  })


  output$Simulator <- renderPlotly({
    GenSimPlot(RunSim(),
               premium_data,
               input$Deductible,
               input$MemberNum,
               input$Strategy
               )
  })

  
  
}
# Run the application 
shinyApp(ui = ui, server = server, options = list(width = 1200, height = 900))