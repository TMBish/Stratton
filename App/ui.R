
library(shiny)
library(shinyBS)
library(shinysky)

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
    titlePanel("Stratton: an interactive tool for films"),
    
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
      sidebarPanel(id="sidebar",
      
                   h3("Enter the name of an Actor or Director:"),
                   
                   textInput.typeahead(
                     id="search_input",
                     placeholder="e.g. Keanu Reeves",
                     local= typeahead_data,
                     valueKey = "Name",
                     tokens=c(1,2),
                     template = HTML("<p class='repo-language'>{{Role}}</p> <p class='repo-name'>{{Name}}</p>")
                     ), 
                   
                   
                   
                   bsButton("search", 
                            "Cluster",
                            icon = icon("refresh"),
                            style = "info"
                   )
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        plotOutput("distPlot")
      )
    )
  ))
