# Append Box Office ---------------------------------------------------------
append_financials = function(films){
  
  require(parallel)
  
  film_list = apply(films[,c("title","year")], 1, as.list )
  
  #+++++++++++++++++++++
  # Begin Multi-Thread'n
  #+++++++++++++++++++++
  
  # Use most of the comp cores
  no_cores = detectCores() - 2
  
  # Initiate cluster
  cl = makeCluster(no_cores)
  
  results = parLapply(cl, film_list, get_financials)
  
  stopCluster(cl)
  
  #+++++++++++++++++++
  # End Multi-Thread'n
  #+++++++++++++++++++
  
  films$intl_revenue = sapply(results, "[", 1)
  
  films$prod_cost = sapply(results, "[", 2)
  
  films$profit = films$intl_revenue - films$prod_cost
  
  return(films)
  
}

