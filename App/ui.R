
library(shiny)

# Define UI for application that draws a histogram
shinyUI(
  fluidPage(
    
    tags$head(
      tags$style(
      HTML('
         #sidebar {
         background-color: #F2B231;
         }
         
         body, label, input, button, select { 
         font-family: "Arial";
         }
           
         h2 {
          font-family: "Arvo", sans-serif;
          font-weight: bold;
         }')
    ),
    
    tags$style(
      '<link href="https://fonts.googleapis.com/css?family=Arvo" rel="stylesheet">'
    )
    
    
    ),
    
    
    
    # Application title
    titlePanel("Old Faithful Geyser Data"),
    
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
      sidebarPanel(id="sidebar",
        sliderInput("bins",
                    "Number of bins:",
                    min = 1,
                    max = 50,
                    value = 30)
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        plotOutput("distPlot")
      )
    )
  ))
