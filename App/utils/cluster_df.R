# Perform Clustering ------------------------------------------------------
cluster_df = function(df, clusters = 3, dimensions = c("rating", "intl_revenue")) {
  
  train_matrix = df[,dimensions]
  
  # Scale / Normalise each column
  train_matrix = lapply(train_matrix, scale)
  
  # For re-scaling
  mu = c(attr(train_matrix[[dimensions[1]]],"scaled:center"), attr(train_matrix[[dimensions[2]]],"scaled:center"))
  sd = c(attr(train_matrix[[dimensions[1]]],"scaled:scale"), attr(train_matrix[[dimensions[2]]],"scaled:scale"))
  
  kmean_model = kmeans(as.data.frame(train_matrix), clusters)
  
  output = list()
  
  output$data = df %>%
    mutate(cluster = factor(kmean_model$cluster)) %>%
    select(title, cluster)
  
  centroids = as.data.frame(kmean_model$centers)
  
  # Need to unscale the centers for plotting
  for (i in 1:2) {
    centroids[,i] = centroids[,i] * sd[i] + mu[i]
  }
  
  output$centers = centroids
  
  return(output)
  
}


