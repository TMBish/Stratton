
library(shiny)

# Server logic
shinyServer(function(input, output, session) {
  
  # Load the screen
  load_data()
  
  # Initialise a reactive vals object
  revals = reactiveValues(
    data_set = NULL, # Init data set as null
    do_plot = 0, # Turn off displays when App is opened
    chart = NULL 
  )
  
  
  # Update data set on user search
  observeEvent(input$search, {
    
    # Get rotten tomatoes data for this person
    sel_films = get_tomatoes(input$search_input)
    
    # Get box office data for this person
    sel_films_comp = append_box_office(sel_films)
    
    # Save as the master data-set
    revals$data_set = sel_films_comp
    
    # Create plot
    d = filter(revals$data_set, !is.na(intl_revenue)) %>% cluster_df()
    
    revals$chart = chart_cluster_h(d)
    
    #Update plot options
    revals$do_plot = 1
    
  })
  
  # Output dataset ----------------------------------------------------------
  output$data_set = 
    renderDataTable(revals$data_set,
                    options = list(
                      pageLength = 20
                    ))
  
  
  # Plot Control ------------------------------------------------------------
  output$do_plot = renderText({
    return(revals$do_plot)
  })
  outputOptions(output, 'do_plot', suspendWhenHidden=FALSE)
  
  
  # Re-run cluster ----------------------------------------------------------
  observeEvent(input$cluster, {
    
    # Re-run clustering using the clustering utility in global
    d = filter(revals$data_set, !is.na(intl_revenue)) %>% cluster_df(clusters = input$clusters)

    # Update the reactive vals object
    revals$chart = chart_cluster_h(d)
    
  })
  
  # Output Chart ------------------------------------------------------------
  output$chart = 
    renderHighchart({
      revals$chart
    })
  
  
  
})






