library(shiny)
library(shinycssloaders)
library(shinydashboard)
library(shinyWidgets)
library(shinythemes)
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
  tags$style(HTML('#clicks{border-color: #000; background-color: #000; color: #FFFFFF }')),
  tags$style(HTML('#Deductible{border-color: #000;}')),
  tags$style(HTML('#MemberNum{border-color: #000;}')),
  tags$style(HTML('#title{color: #000; font-family:Verdana}')),
  tags$style(HTML('#mem{color: #000; font-family:Verdana;font-weight: bold;}')),
  tags$style(HTML('#ded{color: #000; font-family:Verdana;font-weight: bold;}')),
  tags$style(HTML('#str{color: #000; font-family:Verdana; font-weight: bold;}')),
  tags$style(HTML('#adj{color: #000; font-family:Verdana; font-weight: bold;}')),
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
    font-family: 'Times New Roman', Times, serif;
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
  
  setBackgroundColor(color = c("#FFF","red","#000"), gradient = "linear", direction = "bottom"),
  titlePanel(
    div(
      id = "app-header",
      # tags$img(
      #   src = "utah_logo.png",
      #   id = "app-logo"
      # ),
      h1(id = "title", "General Liability Loss Simulator")
    )
  ),
  
  sidebarLayout(position = "left",
                sidebarPanel(width = 4,
                             style = ("border-color:#000; border-width: 2px; background-color: #FFFFFF"),           
                             numericInput("MemberNum", h6(id = "mem","Member Number"), value = premium_data$member_number[1]),  
                             numericInput("Deductible", h6(id = "ded","Deductible"), value = NULL),
                             
                             selectInput("Strategy", h6(id = "str","Select Strategy"),
                                         choices = list("- Select a Strategy -","Organic_LR", 
                                                        "Organic_Heavy_LR", 
                                                        "Moderate_Aggressive_LR", 
                                                        "Aggressive_LR", 
                                                        "Extreme_LR")),
                             helpText("Pricing Strategies: ",br(),
                                      "Organic - 3% increase every year",br(),
                                      "Organic Heavy - 5% increase every year",br(),
                                      "Moderate Aggressive - 15% Increase now 5% after",br(),
                                      "Aggressive - 30% Increase now 5% after",br(),
                                      "Extreme - 50% Increase now 5% increase after"),
                             
                             
                             sliderInput("Adjuster", h6(id = "adj","Loss Severity Adjuster"), 
                                
                                         min = -3, max = 1, value = -1, step = 0.1),
                             
                             helpText("To INCREASE Loss Severity, move NEGATIVE.",
                                      "To REDUCE Loss Severity Move POSITIVE.", br(),
                                      "Note: When slider is set to 1, this means all losses will be reduced $0.",
                                      "Adjuster defaults to making Loss Severity 2x's worse"),
                             
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
                    tags$script(HTML("$('.box').eq(0).css('border', '2px solid #000');"))
                  ),
                  fluidRow(
                    box(
                      div(
                        class = "dygraph-wrapper",
                        dygraphOutput("Simulator") %>% withSpinner(color = "#000", type = 6)
                      ),
                      title = "Simulated Loss Ratios",
                      width = 15
                    ),
                    tags$script(HTML("$('.box').eq(1).css({'border' : '2px solid #000'});"))
                  ),
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
  
  RunSim <- eventReactive(input$clicks, {run_200Scenarios(premium_data,loss_data,input$MemberNum, input$Deductible, input$Adjuster, input$Strategy)})
  
  output$Simulator <- renderDygraph({
    GenSimPlot(RunSim(),premium_data,input$Deductible,input$MemberNum,input$Strategy)
  })
  
}
# Run the application 
shinyApp(ui = ui, server = server, options = list(width = 1200, height = 900))