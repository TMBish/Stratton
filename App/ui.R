
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
        fluidRow(
          column(4,
                 wellPanel(
                   
                   # Actor / Director Input Box
                   h3("Enter the name of an Actor or Director:"),
                   
                   textInput.typeahead(
                     id="search_input",
                     placeholder="e.g. Danny Mcbride",
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
                            style = "primary"
                   )
                   
                   #verbatimTextOutput("do_plot")
                   
                 )
          ),
          
          column(7, offset = 1,
                 wellPanel())
        ),
        
        # Body --------------------------------------------------------------------
        
        wellPanel(
          
          tags$div(id = "body_div",
                   
                   tabsetPanel(
                     
                     tabPanel("Scatter", 
                              
                              hidden(
                                div(id = "loading-container",
                                    
                                    wellPanel(
                                      tags$img(src = "box.gif", id = "loading-spinner"),
                                      h4("loading...")
                                    )
                                )
                              ),
                              
                              div(id= "chart_content",
                                  
                                  conditionalPanel("output.do_plot > 0",
                                                   
                                                   br(),
                                                   wellPanel(highchartOutput('chart', height=600)),
                                                   
                                                   wellPanel(
                                                     
                                                     fluidRow(
                                                       
                                                       column(2,
                                                              selectInput("y_axis",
                                                                          "Y Axis:",
                                                                          choices = c("Rotten Tomatoes Score", "Revenue", "Profit", "Year"))
                                                       ),
                                                       
                                                       column(2,
                                                              selectInput("x_axis",
                                                                          "X Axis:",
                                                                          choices = c("Revenue", "Profit","Rotten Tomatoes Score", "Year"))
                                                              
                                                       ),
                                                       
                                                       column(3,
                                                              
                                                              checkboxGroupInput("role_type", label = "Role:", inline = TRUE,
                                                                                 choices = c("Actor", "Director", "Actor/Director"),
                                                                                 selected = c("Actor", "Director", "Actor/Director"))
                                                              
                                                       )
                                                     ),
                                                     
                                                     fluidRow(
                                                       
                                                       column(2, numericInput("clusters",
                                                                              label = "Cluster films into groups:",
                                                                              3,
                                                                              min=1,
                                                                              max=10)
                                                       ),
                                                       column(2, 
                                                              div(id = "cluster-button",
                                                                  bsButton("cluster", "Cluster", icon = icon("calculator"), style = "primary"))
                                                       )
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





