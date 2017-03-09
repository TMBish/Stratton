
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
    div(id = "loading_page",
        
        style="background-color : transparent",
        h1("Loading...")
        
    ),
    
    # Inspiration Modal -------------------------------------------------------
    bsModal("searchpane", "Why did I even make this thing?", "inspiration", size = "large",
            
            HTML(inspiration_html)
    ),
    
    hidden(
      
      div(id = "main_content",
          sidebarLayout(
            # Sidebar -----------------------------------------------------------------
            sidebarPanel(width = 3,
                         
                         # Actor / Director Input Box
                         h3("Control Panel"), br(),
                         
                         wellPanel(         
                           
                           tags$label("Enter the name of an Actor or Director:"),
                           
                           textInput.typeahead(
                             id = "search_input",
                             placeholder="eg. Danny McBride",
                             local= typeahead_data,
                             valueKey = "Name",
                             tokens=seq(1,nrow(typeahead_data)),
                             template = HTML("<p class='repo-language'>{{Role}}</p> <p class='repo-name'>{{Name}}</p>")
                           ),
                           
                           br(),
                           br(),
                           
                           bsButton("search", 
                                    "Search The Web",
                                    icon = icon("search"),
                                    style = "primary"
                           )
                         ), br(),
                         
                         
                         
                         h3("What is Stratton?"), br(),
                         
                         wellPanel(
                           
                           HTML(overview_html),
                           
                           bsButton("inspiration", 
                                    "The Inspiration",
                                    icon = icon("lightbulb-o"),
                                    style = "danger"
                           )
                           
                         )
            ),
            
            
            mainPanel(
              
              # Tabs --------------------------------------------------------------------
              tags$div(id = "body_div",
                       
                       tabsetPanel(
                         
                         # Analyse Tab -------------------------------------------------------------
                         
                         tabPanel("Analyse", 
                                  
                                  #+++++++++++++++
                                  # Loading Gif
                                  #+++++++++++++++
                                  
                                  hidden(
                                    div(id = "loading-container",
                                        
                                        wellPanel(
                                          tags$img(src = "box.gif", id = "loading-spinner"),
                                          h4("crawlin...")
                                        )
                                    )
                                  ),
                                  
                                  div(id= "chart_content",
                                      
                                      conditionalPanel("output.do_plot > 0",
                                                       
                                                       br(),
                                                       
                                                       #+++++++++++++++
                                                       # The Chart
                                                       #+++++++++++++++
                                                       
                                                       wellPanel(
                                                         highchartOutput('chart', height=500)
                                                       ),
                                                       
                                                       
                                                       #+++++++++++++++
                                                       # The options
                                                       #+++++++++++++++
                                                       
                                                       fluidRow(
                                                         
                                                         column(6,
                                                                
                                                                wellPanel(
                                                                  
                                                                  h3("Chart Options"),br(),
                                                                  
                                                                  fluidRow(
                                                                    column(4,
                                                                           selectInput("y_axis",
                                                                                       "Y Axis:",
                                                                                       choices = c("Rotten Tomatoes Score", "Revenue", "Profit", "Year"))
                                                                    ),
                                                                    
                                                                    column(4,
                                                                           selectInput("x_axis",
                                                                                       "X Axis:",
                                                                                       choices = c("Revenue", "Profit","Rotten Tomatoes Score", "Year"))
                                                                           
                                                                    ),
                                                                    
                                                                    column(4,
                                                                           
                                                                           checkboxGroupInput("role_type", label = "Role:", inline = TRUE,
                                                                                              choices = c("Actor", "Director", "Actor/Director"),
                                                                                              selected = c("Actor", "Director", "Actor/Director"))
                                                                           
                                                                    )
                                                                  )
                                                                )
                                                         ),
                                                         
                                                         column(6,
                                                                wellPanel(
                                                                  
                                                                  h3("Analytics"),br(),
                                                                  
                                                                  fluidRow(
                                                                    column(4, tags$label(id = "loess-label", "Add LOESS regression line:")),
                                                                    column(2, bsButton("loess", " Smooth", icon = icon("line-chart"), style = "primary")),
                                                                    
                                                                    column(4, numericInput("clusters",
                                                                                           label = "Number of film clusters:",
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
)









