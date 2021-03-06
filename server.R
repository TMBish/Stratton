# Server logic
shinyServer(function(input, output, session) {
  
  # Initial Loading Screen
  load_data()
  
  # Initialise a reactive vals object
  revals = reactiveValues(
    data_object = list(), # Data object
    clstr = FALSE, # Control when clustering is graphed
    loess = FALSE, # Control when loess is graphed
    do_plot = 0, # Turn off displays when App is opened
    chart = NULL, # Scatter chart object
    init_gif = 1, # Toggle the init gif panel
    gif_path = "./gifs/gif_1.gif"
  )
  
  # Update data set on user search
  observeEvent(input$search, {

    #Turn off plot
    shinyjs::hide("chart_content")
    shinyjs::show("loading-container")

    #Source
    srce = input$source
    # Get rotten tomatoes data for this person
    sel_films = get_tomatoes(input$search_input)
    # Get box office data for this person
    sel_films_comp = append_financials(sel_films, input$source)
    
    # Save as the master data-set
    revals$data_object = list()
    revals$data_object$data = sel_films_comp
    
    # Update the reactive vals object
    revals$chart = chart_scatter_h(revals$data_object,
                                   input$search_input,
                                   axes = c(dim_map(input$y_axis), dim_map(input$x_axis)),
                                   clstr = revals$clstr,
                                   lss = revals$loess)

    #Update plot options
    revals$do_plot = 1
    shinyjs::show("chart_content")
    shinyjs::hide("loading-container")
    revals$init_gif = 0

  })
  
  # Controls ------------------------------------------------------------
  output$do_plot = renderText({
    return(revals$do_plot)
  })
  outputOptions(output, 'do_plot', suspendWhenHidden=FALSE)
  
  output$init_gif = renderText({
    return(revals$init_gif)
  })
  outputOptions(output, 'init_gif', suspendWhenHidden=FALSE)
  
  # Re-run cluster ----------------------------------------------------------
  observeEvent(input$cluster, {
    
    x = dim_map(input$x_axis)
    y = dim_map(input$y_axis)
    
    # Re-run clustering using the clustering utility in global
    d = revals$data_object$data %>%
        filter_(paste0("!is.na(",y,")"),
                paste0(paste0("!is.na(",x,")"))) %>% 
        cluster_df(clusters = input$clusters, dimensions = c(y,x))
  
    # Add clusters to data object  
    revals$data_object$clusters = d
    
    # Turn on cluster plotting
    revals$clstr = TRUE
    
    # Update the reactive vals object
    revals$chart = chart_scatter_h(revals$data_object,
                                   input$search_input,
                                   axes = c(y, x),
                                   clstr = revals$clstr,
                                   lss = revals$loess)
    })
  
  # Loess Regression ----------------------------------------------------------
  observeEvent(input$loess, {
    
    x = dim_map(input$x_axis)
    y = dim_map(input$y_axis)
    
    # Need the df
    d = revals$data_object$data %>%
      filter_(paste0("!is.na(",y,")"),
              paste0(paste0("!is.na(",x,")"))
              )

    # Add loess
    revals$data_object$loess = add_loess(d, c(y, x))
    
    # Turn on loess plotting
    revals$loess = TRUE
    
    # Update the reactive vals object
    revals$chart =  chart_scatter_h(revals$data_object,
                                   input$search_input,
                                   axes = c(y, x),
                                   clstr = revals$clstr,
                                   lss = revals$loess)
  })
  
  # Plot Structure Change ---------------------------------------------------
  observe({

    if (revals$do_plot > 0) {
      
      isolate({
        iso_title = input$search_input
        iso_data = revals$data_object
        
      })
      
      revals$data_object$data= 
        filter(iso_data$data, role %in% input$role_type)
      
      
      # Update the reactive vals object
      revals$chart = chart_scatter_h(iso_data,
                                     iso_title,
                                     axes = c(dim_map(input$y_axis), dim_map(input$x_axis)),
                                     clstr = revals$clstr,
                                     lss = revals$loess)
      
    }

  })
  
  # Control the plotting ------------------------------------------------------------
  observe({
    
    # Flip the plotting binaries with a dependency on the axes
    alert_me = paste(input$x_axis, input$y_axis)

    revals$loess = FALSE
    revals$clstr = FALSE
    
  })
  
  # Output Chart ------------------------------------------------------------
  output$chart = 
    renderHighchart({
      revals$chart
    })
  
  # Output dataset ----------------------------------------------------------
  output$data_set = 
    renderDataTable({
      
      dt = revals$data_object$data %>%
        select(title, year,
               rating, role,
               intl_revenue, prod_cost,
               profit)
      
      dt_out = 
        datatable(
        dt, extensions = c('Buttons', 'Scroller'),
        rownames = FALSE, height = 400,
        colnames = c("Film", "Release Year","Rotten Tomatoes Rating", "Role","Gross Box Office Revenue", "Production Cost","Profit"),
        options = list(
          dom = 'Bfrtip',
          scrollY = 200,
          pageLength = 20,
          scroller = TRUE,
          buttons = 
            list('copy', list(
              extend = 'collection',
              buttons = c('csv', 'excel', 'pdf'),
              text = 'Download'
            ))
          )
      )
      
      return(dt_out)
    })
  
})








