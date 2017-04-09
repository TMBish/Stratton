shinyUI(
  
  fluidPage(useShinyjs(),
            
            # Javascript and CSS ------------------------------------------------------
            singleton(
              tags$head(
                includeCSS(file.path('www', 'style.css')),
                tags$title("Stratton | Actor analytics with shiny"),
                tags$meta(name="description", content="Use the tool to uncover an interesting, data-evidenced story about an actor or director."),
                tags$link(rel = "image_src", href = "http://www.abc.net.au/atthemovies/img/2004/about/david_large.jpg")                
              )
            ),
            
            
            # App Header --------------------------------------------------------
            div(id = "header-section",
                
                fluidRow(
                  column(1, tags$img(id = "header-logo",src = "icon-2.png")),
                  column(1,
                         h1(id = "strat-title", "Stratton")
                  ),
                  # author info
                  div(id = "app-details",
                      column(2, offset= 8,
                             tags$p(
                               span(
                                 style = "font-size: 1.2em",
                                 span("Created by "),
                                 a("Tom Bishop", href = "https://github.com/TMBish/")
                               )
                             ),
                             tags$p(
                               span(
                                 style = "font-size: 1.2em",
                                 span("Code"),
                                 a("on GitHub", href = "https://github.com/TMBish/Stratton")                               )
                             )
                      )
                  ))
            ),
            
            
            # Loading Div -------------------------------------------------------------
            div(id = "loading_page",
                
                style="background-color : transparent",
                h1("Loading...")
                
            ),
            
            # Exampls Modal -------------------------------------------------------
            bsModal("expane", "Show me some examples", "examples", size = "large",
                    
                    HTML(examples_html)
            ),            
            # Inspiration Modal -------------------------------------------------------
            bsModal("searchpane", "Where did I theive this idea from?", "inspiration", size = "large",
                    
                    HTML(inspiration_html)
            ),
            
            
            # App Body ----------------------------------------------------------------
            hidden(
              div(id = "app_body",
                  sidebarLayout(
                    
                    
                    # Sidebar -----------------------------------------------------------------
                    sidebarPanel(width = 3,
                                 
                                 # Search Control Panel
                                 h3("Control Panel"), 
                                 br(),
                                 wellPanel(       
                                   
                                   #Data Sorce
                                   selectInput("source", label = "Choose a data source", 
                                               choices = c("IMDB", "Box Office Mojo")),
                                   
                                   
                                   bsTooltip("source", "IMDB searches will be much slower but produce a more complete dataset.",
                                             "right", options = list(container = "body")),
                                  
                                   #Search Label
                                   tags$label("Enter the name of an Actor or Director:"),
                                   # Search Input Box
                                   textInput.typeahead(
                                     id = "search_input", placeholder="eg. Danny McBride",
                                     local= typeahead_data, valueKey = "Name",
                                     tokens=seq(1,nrow(typeahead_data)),
                                     template = HTML("<p class='repo-language'>{{Role}}</p> <p class='repo-name'>{{Name}}</p>")
                                   ),br(),br(),
                                   #Search Button
                                   bsButton("search", 
                                            "Search The Web",
                                            icon = icon("search"),
                                            style = "primary"
                                   )
                                 ), br(), 
                                 
                                 # App Description
                                 h3("Stratton Info"), 
                                 br(),
                                 wellPanel(
                                   HTML(use_html),  
                                   bsButton("examples", 
                                            "Examples",
                                            icon = icon("blind"),
                                            style = "danger"
                                   )
                                 ),
                                 
                                 wellPanel(
                                   
                                   #Customer HTML para
                                   HTML(overview_html),
                                   # Modal button
                                   bsButton("inspiration", 
                                            "The Inspiration",
                                            icon = icon("lightbulb-o"),
                                            style = "danger"
                                   )
                                 )
                    ),
                    
                    
                    # Main Panel -----------------------------------------------------------------
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
                                                
                                                # Initial loading gif - shitty hack cause shiny's playing up
                                                # conditionalPanel("output.init_gif > 0",
                                                                 wellPanel(
                                                                   tags$img(src = "box.gif", 
                                                                              #paste0("./gifs/gif_",sample(1:14, 1),".gif"),
                                                                            width = 150,
                                                                            id = "loading-spinner"),
                                                                   h3("searching the web...")
                                                                 )         
                                                # ),
                                                
                                                # # The randomised loading gif for all subsequent searches
                                                # conditionalPanel("output.init_gif == 0",
                                                #                  wellPanel(
                                                #                    uiOutput("loading_gif"),
                                                #                    h3("searching the web...")
                                                #                  )          
                                                # )     
                                                
                                            )
                                          ),
                                          
                                          #+++++++++++++++
                                          # Scatter Chart
                                          #+++++++++++++++
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
                                                                            column(6,
                                                                                   selectInput("y_axis","Y Axis:",
                                                                                               choices = c("Rotten Tomatoes Score", "Revenue", "Profit", "Year", "Production Cost")
                                                                                   )
                                                                            ),
                                                                            column(6,
                                                                                   selectInput("x_axis", "X Axis:",
                                                                                               choices = c("Revenue", "Profit","Rotten Tomatoes Score", "Year", "Production Cost")
                                                                                   )
                                                                            )
                                                                          ),
                                                                          checkboxGroupInput("role_type", label = "Role:", inline = TRUE,
                                                                                             choices = c("Actor", "Director", "Actor/Director"),
                                                                                             selected = c("Actor", "Director", "Actor/Director")
                                                                          )
                                                                        )
                                                                 ),
                                                                 
                                                                 #+++++++++++++++
                                                                 # Analytics Buttons
                                                                 #+++++++++++++++
                                                                 
                                                                 column(6,
                                                                        wellPanel(
                                                                          
                                                                          h3("Analytics"), br(),
                                                                          
                                                                          fluidRow(
                                                                            column(6, numericInput("clusters",
                                                                                                   label = "Number of film clusters:",
                                                                                                   3,
                                                                                                   min=1,
                                                                                                   max=10)
                                                                            ),
                                                                            column(6,
                                                                                   div(id = "cluster-button",
                                                                                       bsButton("cluster", "Cluster", icon = icon("calculator"), style = "primary"))
                                                                            )
                                                                          ),
                                                                          
                                                                          fluidRow(
                                                                            column(6, tags$label(id = "loess-label", "Add Trend Line:")),
                                                                            column(6, bsButton("loess", " Smooth", icon = icon("line-chart"), style = "primary"))
                                                                          )
                                                                        )
                                                                 )
                                                               )
                                              )
                                          )
                                 ),
                                 
                                 #+++++++++++++++
                                 # Timeline
                                 #+++++++++++++++
                                 tabPanel("Timeline",
                                          br(),
                                          wellPanel(
                                            div(id="timeline",
                                                h3("Currently Under Development")
                                            )
                                          )
                                 ),
                                 
                                 #+++++++++++++++
                                 # Raw Data
                                 #+++++++++++++++
                                 tabPanel("Raw Data", 
                                          br(),
                                          
                                          conditionalPanel("output.do_plot > 0",
                                                           wellPanel(dataTableOutput("data_set"))
                                          )
                                 )
                               )
                      )
                    )
                  )
              )
            )
  )
)











