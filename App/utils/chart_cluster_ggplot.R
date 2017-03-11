# Produce Ggplot Graph -----------------------------------------------------------
chart_cluster_ggplot = function(df, axes = c("rating", "intl_revenue")) {
  
  require(ggplot2)
  require(hrbrthemes)
  require(ggalt)
  require(gcookbook)
  require(RColorBrewer)
  
  
  # Translate axis vars to english axis labels
  x_lab = switch(axes[2], "rating" = "Rotten Tomatoes Score"
                 , "intl_revenue" = "Box Office Revenue")
  y_lab = switch(axes[1], "rating" = "Rotten Tomatoes Score"
                 , "intl_revenue" = "Box Office Revenue")
  
  # Produce graph
  gg = ggplot(data = df, aes_string(y = axes[1], x = axes[2], color = "cluster")) +
    geom_point(size = 3) +
    scale_y_continuous(limits = c(0, 1.1 * max(df[,axes[1]]))) +
    scale_x_comma(limits = c(-100000, 1.1 * max(df[,axes[2]]))) +
    scale_color_brewer(type = 'qual', palette = 'Accent') +
    labs(x=x_lab, y=y_lab,
         title="Test plot",
         subtitle="A plot that is only useful for demonstration purposes",
         caption="Powered by Tom Bishop and OSIRIS") +
    theme_ipsum_rc(grid="XY") +
    theme(axis.line.x = element_line(color="black"),
          axis.line.y = element_line(color="black"))
  
  # Loop and encircle the clusters using GGALT functionality
  ind = 1
  for (clust in unique(df$cluster)) {
    
    gg = gg + geom_encircle(
      data = filter(df, cluster == clust),
      color = brewer.pal(length(unique(df$cluster)), name = "Accent")[ind],
      s_shape=0.1, expand=0.001
    )
    
    ind = ind + 1
  }
  
  return(gg)
  
}



