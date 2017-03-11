# Perform Clustering ------------------------------------------------------
cluster_df = function(df, clusters = 3, dimensions = c("rating", "intl_revenue")) {
  
  train_matrix = df[,dimensions]
  
  train_matrix = data.frame(lapply(train_matrix, scale))
  
  kmean_model = kmeans(train_matrix, clusters)
  
  output = df %>% mutate(cluster = factor(kmean_model$cluster))
  
  return(output)
  
}


