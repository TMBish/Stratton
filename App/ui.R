
library(shiny)
library(shinyBS)
library(shinysky)

# Define UI for application that draws a histogram
shinyUI(
  fluidPage(
    
    # Javascript and CSS ------------------------------------------------------
    # Custom CSS
    tags$head(
      tags$style(
        HTML('
         #sidebar {
         background-color: #F2B231;
         }
         
         body, label, input, button, select { 
         font-family: "Arial";
         }

         #body_div {
          background-color: #D3D3D3;
          border-radius: 25px;
          widtht: 300px;
          height: 300px;
         }
           
         h2 {
          font-family: "Arvo", sans-serif;
          font-weight: bold;
         }')
      ),
      
      # JS Alert for Debugging
      tags$head(tags$script(src = "message-handler.js")),
      
      # Arvo google font
      tags$style('<link href="https://fonts.googleapis.com/css?family=Arvo" rel="stylesheet">')
      
      
    ),
    
    # Application Body --------------------------------------------------------
    
    # Application title
    titlePanel("Stratton: an interactive tool for films"),
    
    
      # Sidebar -----------------------------------------------------------------
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
      sidebarPanel(id="sidebar",
                   
                   # Actor / Director Input Box
                   h3("Enter the name of an Actor or Director:"),
                   
                   textInput.typeahead(
                     id="search_input",
                     placeholder="e.g. Joseph Gordon-Levitt",
                     local= typeahead_data,
                     valueKey = "Name",
                     tokens=seq(1,nrow(typeahead_data)),
                     template = HTML("<p class='repo-language'>{{Role}}</p> <p class='repo-name'>{{Name}}</p>")
                   ), 
                   
                   
                   
                   bsButton("search", 
                            "Cluster",
                            icon = icon("refresh"),
                            style = "info"
                   )
      ),
      
      
      
      
      # Body --------------------------------------------------------------------
      mainPanel(
        
        tags$div(id = "body_div",
                 
                 tabsetPanel(
                   tabPanel("Chart", plotOutput('chart')), 
                   tabPanel("Timeline"), 
                   tabPanel("Raw Data", dataTableOutput("data_set"))
                 )
        

        )
      )
    )
  ))








