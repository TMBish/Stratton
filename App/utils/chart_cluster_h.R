# Produce Highcharts Graph --------------------------------------------------------------
chart_cluster_h = function(df, actor, axes = c("rating", "intl_revenue"), clstr = FALSE) {
  
  require(highcharter)
  require(dplyr)
  require(stringr)
  
  #++++++++++++++++++++++++++++++++++
  # Dynamically build chart attributes
  #++++++++++++++++++++++++++++++++++
  
  # Need a helper to get it done: Build the javascript tooltip formats
  tool_format = function(axis, num) {
    
    dirc = switch(num, "1" = "y", "2" = "x")
    if (axis == 'rating'){
      format = paste0("this.",dirc," + '%'")
    } else if (axis == 'intl_revenue' || axis == 'profit') {
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
                                   "profit" = "Profit")
    
    # Formmat for the tooltip
    c_atr[[i]]$tooltip_form =  tool_format(axes[axis],axis)
    
    # Format for the axes
    c_atr[[i]]$label_form = str_replace(c_atr[[i]]$tooltip_form, "\\.[xy]", ".value")
    
    # Axis limits
    c_atr[[i]]$min = switch(axes[axis],
                            "rating" = 0,
                            "intl_revenue" = 0,
                            "profit" = 0,
                            "year" = min(df[,axes[axis]]))
    c_atr[[i]]$max = switch(axes[axis],
                            "rating" = 100,
                            "intl_revenue" = 1.05 * max(df[,axes[axis]]),
                            "profit" = 1.05 * max(df[,axes[axis]], na.rm = TRUE),
                            "year" = max(df[,axes[axis]]))
    
  }
  
  
  #++++++++++++++++++
  # Build base chart
  #++++++++++++++++++
  
  # Cheeky: Grabbed hcaes_string from the dev version of highcharter
  # really really handy for me
  if (clstr) {
    
    base = hchart(df, "scatter", hcaes_string(x = axes[2], y = axes[1], color = 'cluster'))
    
  } else {
    
    base = hchart(df, "scatter", color = "#286090",hcaes_string(x = axes[2], y = axes[1]))
    
  }
  
  #+++++++++++++++
  # Add on extras
  #+++++++++++++++
  
  output = 
    # hc_add_series(data = hulls %>% filter(cluster==2), 
    #               hcaes_string(x = 'intl_revenue', y = 'rating', color = 'cluster'),
    #               type = "polygon"
    #               ) %>%
    base %>%
    hc_plotOptions(
      divBackgroundImage = "osiris-small.png",
      scatter = list(marker = list(radius = 6))
    ) %>%
    hc_yAxis(
      title = list(text = c_atr$y$label_text),
      labels = list(formatter = JS(paste0("function(){return(",c_atr$y$label_form,")}"))), 
      min = c_atr$y$min,
      max = c_atr$y$max,
      linewidth = 1
    ) %>%
    hc_xAxis(
      title = list(text = c_atr$x$label_text),
      labels = list(formatter = JS(paste0("function(){return(",c_atr$x$label_form,")}"))),
      min = c_atr$x$min,
      max = c_atr$x$max
    ) %>%    
    hc_title(text = actor,
             style = list(fontWeight = "bold"),
             align = "left") %>% 
    hc_subtitle(align = "left",
                style = list(fontStyle = "italic"),
                text = paste0("A comparison of ", c_atr$y$label_text, " and ", c_atr$x$label_text)) %>% 
    hc_tooltip(useHTML = TRUE, headerFormat = "",
               # Lol below looks fucked up
               # This hurt my brain so much
               formatter = JS(
                 paste0(
                   "function(){return (",
                   "'<strong>' + this.point.title + '</strong> <br>' + ",
                   "'<strong> Role: </strong>' + this.point.role + '<br>' + ",
                   "'<strong>", c_atr$y$label_text, ": </strong> ' + ", c_atr$y$tooltip_form, " + '<br>' + ",
                   "'<strong>", c_atr$x$label_text, ": </strong> ' + ", c_atr$x$tooltip_form,
                   ")}" 
                 )
               )
    ) %>%
    hc_exporting(enabled =TRUE)
  
  # Finding Convex Hull Around Clusters
  # hulls = df %>% sample_n(0)
  # for (c in unique(df$cluster)) {
  #   
  #   df_c = df %>% filter(cluster == c)
  #   
  #   hull = df[chull(df[,axes[1]],df[,axes[2]]),]
  #   
  #   hulls = hulls %>% union_all(hull)
  #   
  # }
  
  
  
}


