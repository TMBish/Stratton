
library(shiny)

# Server logic
shinyServer(function(input, output, session) {
  
  
  revals = reactiveValues(
    data_set = NULL, # Init data set as null
    do_plot = FALSE # Turn off displays when App is opened
  )
  
  
  # Update data set on user search
  observeEvent(input$search, {
    
    # Get rotten tomatoes data for this person
    sel_films = get_tomatoes(input$search_input)
    
    # Get box office data for this person
    sel_films_comp = append_box_office(sel_films)
    
    # Save as the master data-set
    revals$data_set = sel_films_comp
    
    #Update plot options
    revals$do_plot = TRUE
    
  })
  
  # Output dataset ----------------------------------------------------------
  output$data_set = 
    renderDataTable(revals$data_set,
                    options = list(
                      pageLength = 20
                    ))
  
  
  # Output Chart ------------------------------------------------------------
  output$chart = 
    renderHighchart({
      
      if (revals$do_plot) {
        
        d = filter(revals$data_set, !is.na(intl_revenue))
        
        cl_d = cluster_df(d)
        
        chart_cluster_h(cl_d)
        
      }
      
    })
  
  
  
})




