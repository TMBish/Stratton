# Produce Highcharts Graph --------------------------------------------------------------
chart_scatter_h = function(data_object, # Data object
                           actor, # Title for graph
                           axes = c("rating", "intl_revenue"), # Axes Dimensions
                           clstr = FALSE, # Binary whether to add cluster
                           lss = FALSE # Binary on whether to add loess
) {
  
  require(highcharter)
  require(dplyr)
  require(stringr)
  
  c = tryCatch({
    # For shorter code m8
    df = data_object$data
    
    # Filter for complete cases
    df = df %>% filter_(paste0("!is.na(",axes[1],")"), paste0(paste0("!is.na(",axes[2],")")))
    
    #++++++++++++++++++++++++++++++++++
    # Dynamically build chart attributes
    #++++++++++++++++++++++++++++++++++
    
    # Need a helper to get it done: Build the javascript tooltip formats
    tool_format = function(axis, num) {
      
      dirc = switch(num, "1" = "y", "2" = "x")
      if (axis == 'rating'){
        format = paste0("this.",dirc," + '%'")
      } else if (axis == 'intl_revenue' || axis == 'profit' || axis == "prod_cost") {
        format = paste0("'$' + (this.", dirc, "/1000000).toFixed(0) + 'm'")
      } else if (axis == 'year') {
        format = paste0("this.", dirc)
      }
      
    }
    
    c_atr = list()
    for (i in c("x","y")) {
      
      axis = ifelse(i=="x", 2, 1)
      
      # Axis labels
      c_atr[[i]]$label_text = switch(axes[axis],
                                     "rating" = "Rotten Tomatoes Score",
                                     "intl_revenue" = "Box Office Revenue",
                                     "year" = "Year",
                                     "profit" = "Profit",
                                     "prod_cost" = "Production Cost")
      
      # Formmat for the tooltip
      c_atr[[i]]$tooltip_form =  tool_format(axes[axis],axis)
      
      # Format for the axes
      c_atr[[i]]$label_form = str_replace(c_atr[[i]]$tooltip_form, "\\.[xy]", ".value")
      
      # Axis limits
      c_atr[[i]]$min = switch(axes[axis],
                              "rating" = 0,
                              "intl_revenue" = 0,
                              "profit" = 0,
                              "prod_cost" = 0,
                              "year" = min(df[,axes[axis]]))
      c_atr[[i]]$max = switch(axes[axis],
                              "rating" = 100,
                              "intl_revenue" = 1.05 * max(df[,axes[axis]]),
                              "prod_cost" = 1.05 * max(df[,axes[axis]]),
                              "profit" = 1.05 * max(df[,axes[axis]], na.rm = TRUE),
                              "year" = max(df[,axes[axis]]))
      
    }
    
    
    #++++++++++++++++++
    # Build base chart
    #++++++++++++++++++
    
    if (clstr) {
      
      add_clus = df %>% inner_join(data_object$clusters$data, by = "title")
      
      x_var = axes[2]
      y_var = axes[1]
      
      base = 
        add_clus %>%
        select(x = !!sym(x_var), y = !!sym(y_var), cluster, role, title) %>%
        hchart("scatter", hcaes(x = x, y = y, color = cluster))
      
      # Add the cluster centroids
      centroids = data_object$clusters$centers
      for (i in 1:nrow(centroids)) {
        
        base = base %>%
          hc_add_series(name = "cluster Center",
                        data = list_parse2(rev(centroids[i,])),
                        type = "scatter",
                        marker = list(symbol = "plus", radius = 8),
                        color = colorize(1:nrow(centroids))[i])
      }
      
      
    } else {
      
      x_var = axes[2]
      y_var = axes[1]
      
      base = 
        df %>%
        select(x = !!sym(x_var), y = !!sym(y_var), role, title) %>%
        hchart("scatter", color = "#286090", hcaes(x = x, y = y))
      
    }
    
    #+++++++++++++++
    # Add on extras
    #+++++++++++++++
    
    output = 
      base %>%
      hc_add_theme(stratton_thm) %>%
      hc_plotOptions(
        divBackgroundImage = "osiris-small.png",
        scatter = list(marker = list(radius = 4))
      ) %>%
      hc_yAxis(
        title = list(text = c_atr$y$label_text),
        labels = list(formatter = JS(paste0("function(){return(",c_atr$y$label_form,")}"))), 
        min = c_atr$y$min,
        max = c_atr$y$max,
        linewidth = 1,
        gridLineColor = "#737373",
        lineColor = "#737373",
        gridLineWidth = 0.3
      ) %>%
      hc_xAxis(
        title = list(text = c_atr$x$label_text),
        labels = list(formatter = JS(paste0("function(){return(",c_atr$x$label_form,")}"))),
        min = c_atr$x$min,
        max = c_atr$x$max,
        gridLineColor = "#737373",
        gridLineWidth = 0.3
      ) %>%    
      hc_title(text = actor,
               style = list(fontWeight = "bold"),
               align = "left") %>% 
      hc_subtitle(align = "left",
                  style = list(fontStyle = "italic"),
                  text = paste0("A comparison of ", c_atr$y$label_text, " and ", c_atr$x$label_text)) %>% 
      hc_tooltip(useHTML = TRUE, headerFormat = "",
                 # Lol this hurt my brain so much
                 formatter = JS(
                   paste0(
                     "function(){
                     
                     if (this.series.name == 'cluster Center') {
                     
                     return('<strong> Cluster Centroid </strong>')
                     
                     } else if (this.series.name == 'LOESS smooth') {
                     
                     return('<strong> LOESS Smooth </strong>')
                     
                     } else {
                     return (",
                     "'<strong>' + this.point.title + '</strong> <br>' + ",
                     "'<strong> Role: </strong>' + this.point.role + '<br>' + ",
                     "'<strong>", c_atr$y$label_text, ": </strong> ' + ", c_atr$y$tooltip_form, " + '<br>' + ",
                     "'<strong>", c_atr$x$label_text, ": </strong> ' + ", c_atr$x$tooltip_form,
                     ")
                     }
                     }" 
                   )
                 )
      ) %>%
      hc_exporting(enabled =TRUE)
    
    
    #++++++++++++++++++
    # Add Loess
    #++++++++++++++++++
    
    # Add the line to the highchart object
    if (lss) {
      
      output = output %>%
        hc_add_series(name = "LOESS smooth",data = data_object$loess, type = "line") %>%
        hc_plotOptions(
          line = list(
            lineWidth = 3,
            dashStyle = "Dash",
            lineColor = "rgba(0,0,0,0.3)",
            marker = list(radius=0))
        )
    }
    
    return(output)
    
    
  }, error = function(e) {
    
    return(highchart())
    
  })
  
  return(c)
  
  
}


