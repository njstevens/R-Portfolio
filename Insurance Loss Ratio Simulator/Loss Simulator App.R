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
  tags$style(HTML('#clicks{border-color: #84341c; background-color: #990606; color: #FFFFFF }')),
  tags$style(HTML('#Deductible{border-color: #84341c;}')),
  tags$style(HTML('#MemberNum{border-color: #84341c;}')),
  tags$style(HTML('#title{color: #84341c; font-family:Verdana}')),
  tags$style(HTML('#mem{color: #84341c; font-family:Verdana;font-weight: bold;}')),
  tags$style(HTML('#ded{color: #84341c; font-family:Verdana;font-weight: bold;}')),
  tags$style(HTML('#str{color: #84341c; font-family:Verdana; font-weight: bold;}')),
  tags$style(HTML('#adj{color: #84341c; font-family:Verdana; font-weight: bold;}')),
  
  setBackgroundColor(color = c("#FEF9EF","#F7F1E5","#EADBBE",trustColors[3]), gradient = "linear", direction = "bottom"),
    titlePanel(
      fluidRow(
      column(3, 
            # img(height = 200, width = 200, src = "Utah_Utes_logo.png",alt = "Utah Utes Logo")
             ),
      column(9, h1(id = "title","General Liability Loss Simulator"))
      
      )),
   
    sidebarLayout(position = "left",
       sidebarPanel(width = 4,
                   style = ("border-color:#84341c; border-width: 2px; background-color: #FFFFFF"),           
        numericInput("MemberNum", h6(id = "mem","Member Number"), value = trustdata$member_number[1]),  
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
        box(tabsetPanel(type = "pills",
          tabPanel("Severity Assesment",dygraphOutput("sev_assess")),
          tabPanel("Frequency Assessment", dygraphOutput("freq_assess"))),title = "Loss Assessment", width = 15),
          tags$script(HTML("$('.box').eq(0).css('border', '2px solid #84341c');"))
        ),
        fluidRow(
            box(dygraphOutput("Simulator") %>% withSpinner(color = "#84341c", type = 6), title = "Simulated Loss Ratios", width = 15),
            tags$script(HTML("$('.box').eq(1).css({'border' : '2px solid #84341c'});"))
           ),
        

        
  )
 )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$sev_assess <- renderDygraph({
      trust.LossesAssesment(ecarm,trustdata,input$MemberNum,output = "Severity")
      })
    
    output$freq_assess <- renderDygraph({
      trust.LossesAssesment(ecarm,trustdata,input$MemberNum,output = "Frequency")
      })
    
    RunSim <- eventReactive(input$clicks, {trust.200Scenarios(trustdata,ecarm,input$MemberNum, input$Deductible, input$Adjuster, input$Strategy)})
    
    output$Simulator <- renderDygraph({
      trust.GenSimPlot(RunSim(),trustdata,input$Deductible,input$MemberNum,input$Strategy)
      })
   
}
# Run the application 
shinyApp(ui = ui, server = server, options = list(width = 1200, height = 900))


