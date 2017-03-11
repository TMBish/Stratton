library(shiny)

# Server logic
shinyServer(function(input, output, session) {
  
  # Initial Loading Screen
  load_data()
  
  # Initialise a reactive vals object
  revals = reactiveValues(
    data_set = NULL, # Init data set as null
    do_plot = 0, # Turn off displays when App is opened
    chart = NULL # Scatter chart object
  )
  
  
  # Update data set on user search
  observeEvent(input$search, {
    
    #Turn off plot
    shinyjs::hide("chart_content")
    shinyjs::show("loading-container")

    # Get rotten tomatoes data for this person
    sel_films = get_tomatoes(input$search_input)
    
    # Get box office data for this person
    sel_films_comp = append_box_office(sel_films)
    
    # Save as the master data-set
    revals$data_set = sel_films_comp
    
    # Create plot
    d = filter(revals$data_set, !is.na(intl_revenue)) %>% cluster_df()
    
    revals$chart = chart_cluster_h(d, input$search_input)
    
    #Update plot options
    revals$do_plot = 1
    shinyjs::show("chart_content")
    shinyjs::hide("loading-container")

  })
  
  # Output dataset ----------------------------------------------------------
  output$data_set = 
    renderDataTable({
      
      dt = revals$data_set
      names(dt) = c("Rotten Tomatoes Rating", "Film Title", "Box Office Gross", "Release Year", "Role", "Revenue", "Production Cost", "Profit")
      return(dt)
      }, options = list(pageLength = 10)
      )
  
  
  # Plot Control ------------------------------------------------------------
  output$do_plot = renderText({
    return(revals$do_plot)
  })
  outputOptions(output, 'do_plot', suspendWhenHidden=FALSE)
  
  
  # Re-run cluster ----------------------------------------------------------
  observeEvent(input$cluster, {
    
    # Re-run clustering using the clustering utility in global
    d = filter(revals$data_set, !is.na(intl_revenue)) %>% 
      cluster_df(clusters = input$clusters, dimensions = c(dim_map(input$y_axis), dim_map(input$x_axis)))

    # Update the reactive vals object
    revals$chart = chart_cluster_h(d, input$search_input, axes = c(dim_map(input$y_axis), dim_map(input$x_axis)), clstr = TRUE)
    
  })
  
  # Loess Regression ----------------------------------------------------------
  observeEvent(input$loess, {
    
    # Need the df
    d = filter(revals$data_set, !is.na(intl_revenue))
    
    # Graph the chart object
    c = revals$chart
    
    # Grab the current axes
    axes = c(dim_map(input$y_axis), dim_map(input$x_axis))
    
    # Update the chart with a smoother
    revals$chart = add_loess(c, d, axes)

  })
  
  
  
  # Plot Structure Change ---------------------------------------------------
  observe({

    if (revals$do_plot > 0) {
     
      d = filter(revals$data_set, 
                 !is.na(intl_revenue),
                 role %in% input$role_type)
      
      if ("cluster" %in% names(d)) {
      
        revals$chart = chart_cluster_h(d, 
                                       input$search_input,
                                       axes = c(dim_map(input$y_axis), dim_map(input$x_axis)))
                                       #clstr = TRUE)  
      } else {
        revals$chart = chart_cluster_h(d, 
                                       input$search_input,
                                       axes = c(dim_map(input$y_axis), dim_map(input$x_axis)))
      }
      
      
    }

  })
  
  
  
  # Output Chart ------------------------------------------------------------
  output$chart = 
    renderHighchart({
      revals$chart
    })
  
  
  
})








