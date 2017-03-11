# Smoother ----------------------------------------------------------------
add_loess = function(high_chart, df, axes) {
  
  require(highcharter)
  require(dplyr)
  require(stringr)
  require(ggplot2)
  
  # ggplot does the heavy lifting
  gg = ggplot(data = df, aes_string(x = axes[2], y = axes[1])) + geom_smooth()
  
  # Extract the smoothed
  smoothed = ggplot_build(gg)$data[[1]][,c("x","y")]
  
  names(smoothed) = c(axes[2], axes[1])
  
  test = list_parse2(smoothed)
  
  # Add the line to the highchart object
  output = high_chart %>%
    hc_add_series(name = "LOESS smooth",data = test, type = "line") %>%
    hc_plotOptions(
      line = list(
        lineWidth = 6,
        dashStyle = "Dash",
        lineColor = "rgba(0,0,0,0.3)",
        marker = list(radius=0))
    )
  
  return(output)
  
}

