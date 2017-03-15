# Append Box Office ---------------------------------------------------------
append_financials = function(films){
  
  require(parallel)
  
  #+++++++++++++++++++++
  # Begin Multi-Thread'n
  #+++++++++++++++++++++
  
  # Use most of the comp cores
  no_cores = detectCores() - 2
  
  # Initiate cluster
  cl = makeCluster(no_cores)
  
  test = parLapply(cl, films$title, get_financials)
  
  stopCluster(cl)
  
  #+++++++++++++++++++
  # End Multi-Thread'n
  #+++++++++++++++++++
  
  films$intl_revenue = sapply(test, "[", 1)
  
  films$prod_cost = sapply(test, "[", 2)
  
  films$profit = films$intl_revenue - films$prod_cost
  
  return(films)
  
}

