
library(shiny)
library(shinyBS)
library(shinysky)

# Define UI for application that draws a histogram
shinyUI(
  fluidPage(
    
    # Javascript and CSS ------------------------------------------------------
    # Custom CSS
    singleton(
      tags$head(
        includeScript(file.path('www', 'message-handler.js')),
        includeCSS(file.path('www', 'style.css'))
      )
    ),
    
    # Application Body --------------------------------------------------------
    
    # App Header
    div(id = "headerSection",
        
        # tags$img(
        #   id = "header_logo",
        #   src = "icon_black.jpg"
        # ),
        
        h1("STRATTON"),
        
        # author info
        
        span(
          style = "font-size: 1.2em",
          span("Created by "),
          a("Tom Bishop", href = "http://deanattali.com"),
          HTML("&bull;"),
          span("Code"),
          a("on GitHub", href = "https://github.com/TMBish/Stratton"),
          HTML("&bull;")
        )
    ),
    
    
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
        wellPanel(
          tags$div(id = "body_div",
                   
                   tabsetPanel(
                     tabPanel("Chart", 
                              
                              fluidRow(
                                
                                column(2, div(id = "x_axis_box", selectInput("x_axis","",choices = c("Rotten Tomatoes Score", "Thing 2")))),
                                
                                column(10, highchartOutput('chart', height = 500))
                                
                                
                              )
                     ),
                     
                     tabPanel("Timeline"), 
                     tabPanel("Raw Data", dataTableOutput("data_set"))
                   )
                   
          )          
        )
      )
    )
  ))

