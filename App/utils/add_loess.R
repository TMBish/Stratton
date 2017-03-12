# Smoother ----------------------------------------------------------------
add_loess = function(df, axes) {
  
  require(highcharter)
  require(dplyr)
  require(stringr)
  require(ggplot2)
  
  # ggplot does the heavy lifting
  gg = ggplot(data = df, aes_string(x = axes[2], y = axes[1])) + geom_smooth()
  
  # Extract the smoothed
  smoothed = ggplot_build(gg)$data[[1]][,c("x","y")]
  
  names(smoothed) = c(axes[2], axes[1])
  
  output = list_parse2(smoothed)
  
  return(output)
  
}

