
library(shiny)

# Server logic
shinyServer(function(input, output, session) {
   
  
  # Event to run when user selects new person
  observeEvent(input$search, {
    
    # Alert the client
    session$sendCustomMessage(type = 'testmessage', message = list(input$search_input))
    
    # Currently selected actor
    sel_search = input$search_input
    
    # Get rotten tomatoes data for this person
    sel_films = get_tomatoes(sel_search)
    
    # Get box office data for this person
    sel_films_comp = get_box_office(sel_films)
    
    # Save as the master data-set
    data_set = sel_films_comp
    
    
    
  })
  
  output$data_set = renderDataTable({
    
    return(data_set)
    
  })
  
  
  
  
  
  
})
