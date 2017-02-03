get_box_office = function(films) {
  
  require(assertthat)
  require(dplyr)
  require(rvest)
  
  # Using a films data frame from the get_tomatoes function
  assert_that(
      nrow(films) >= 1 &&
      ncol(films) == 4 &&
      "tbl_df" %in% class(films))
  
  # We'll iteratively find the box office gross for the films in the table
  cash_money = rep(0, nrow(films))
  
  for (i in seq_along(nrow(films))) {
    
    
    
    
    
    
    
  }
  
  
  
  
  
}