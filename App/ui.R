
library(shiny)
library(shinyBS)
library(shinysky)
library(shinyjs)

# Define UI for application that draws a histogram
shinyUI(
  
  fluidPage(
    
    useShinyjs(),
    
    # Javascript and CSS ------------------------------------------------------
    # Custom CSS
    singleton(
      tags$head(
        includeScript(file.path('www', 'message-handler.js')),
        includeCSS(file.path('www', 'style.css'))
      )
    ),
    
    # Application Body --------------------------------------------------------
    
    # App Header --------------------------------------------------------
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
          a("Tom Bishop", href = "wwww.google.com"),
          HTML("&bull;"),
          span("Code"),
          a("on GitHub", href = "https://github.com/TMBish/Stratton"),
          HTML("&bull;")
        )
    ),
    
    # Loading Div -------------------------------------------------------------
    div(
      style="background-color : transparent",
      id = "loading_page",
      h1("Loading...")
    ),
    
    hidden(
      div(
        id = "main_content",
        
        # Sidebar -----------------------------------------------------------------
        # Sidebar with a slider input for number of bins 
        wellPanel(
          
          # Actor / Director Input Box
          h4("Enter the name of an Actor or Director:"),
          
          textInput.typeahead(
            id="search_input",
            placeholder="e.g. Joseph Gordon-Levitt",
            local= typeahead_data,
            valueKey = "Name",
            tokens=seq(1,nrow(typeahead_data)),
            template = HTML("<p class='repo-language'>{{Role}}</p> <p class='repo-name'>{{Name}}</p>")
          ),
          
          br(),
          br(),
          
          bsButton("search", 
                   "Search",
                   icon = icon("refresh"),
                   style = "info"
          )
          
          #verbatimTextOutput("do_plot")
          
        ),
        
        # Body --------------------------------------------------------------------
        
        wellPanel(
          
          tags$div(id = "body_div",
                   
                   tabsetPanel(
                     
                     tabPanel("Chart", 
                              
                              conditionalPanel("output.do_plot > 0",
                                               
                                               br(),
                                               highchartOutput('chart'),
                                               
                                               wellPanel(
                                                 
                                                 fluidRow(
                                                   
                                                   column(3,
                                                          selectInput("y_axis",
                                                                      "Y Axis:",
                                                                      choices = c("Rotten Tomatoes", "Revenue", "Profit"))
                                                   ),
                                                   
                                                   column(3,
                                                          selectInput("x_axis",
                                                                      "X Axis:",
                                                                      choices = c("Revenue", "Profit","Rotten Tomatoes"))
                                                          
                                                   ),
                                                   
                                                   column(3, numericInput("clusters",
                                                                          label = "Number of Clusters:",
                                                                          3,
                                                                          min=1,
                                                                          max=10)
                                                   ),
                                                   column(3, 
                                                          div(id = "cluster-button",
                                                              bsButton("cluster", "Calculate", icon = icon("calculator"), style = "primary"))
                                                   )
                                                 )
                                                 
                                               )
                              )
                     ),
                     
                     tabPanel("Timeline"),
                     
                     tabPanel("Raw Data", wellPanel(dataTableOutput("data_set")))
                   )
                   
          )          
        )
      )
    )
  )
)




