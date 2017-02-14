
library(shiny)

# Server logic
shinyServer(function(input, output, session) {
  
  
  revals = reactiveValues(
    data_set = NULL, # Init data set as null
    do_plot = FALSE # Turn off displays when App is opened
  )
  
  
  # Update data set on user search
  observeEvent(input$search, {
    
    # Alert the client
    session$sendCustomMessage(type = 'testmessage', message = list(input$search_input))
    
    # Get rotten tomatoes data for this person
    sel_films = get_tomatoes(input$search_input)
    
    # Get box office data for this person
    sel_films_comp = get_box_office(sel_films)

    # Save as the master data-set
    revals$data_set = sel_films_comp
    
  })
  
  # Output dataset for debugging
  output$data_set = 
    renderDataTable(revals$data_set,
                    options = list(
                      pageLength = 20,
                      initComplete = I("function(settings, json) {alert('Done.');}")
                    ))
  
  
  
  
  
  
  })
