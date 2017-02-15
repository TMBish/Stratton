get_financials = function(film) {
  
  require(assertthat)
  require(dplyr)
  require(rvest)
  require(stringr)
  
  # Box office mojo seems to have a specific URL structure, including:
  # 1. Dropping a leading "The" for movies starting with the word
  # 2. Removing all spaces (obviously)
  # 3. Lower casing (obviously)
  # 4. Removing all punctuation
  # 5. Replacing ampersand with and
  # 6. Removing trailing parenthetic movie descriptions
  #   Note: There are many other idiosyncracies that I can't account for
  #   for example try looking up the kids movie "Megamind". 
  #   What the fuck man
  format_url = function(film) { 
    
    base = "http://www.boxofficemojo.com/movies/?id=%s.htm"
    
    film = 
      str_replace(film, "(?i)^the ", "") %>%
      tolower() %>%
      str_replace_all(" ", "") %>%
      str_replace_all("\\&", "and") %>%
      str_replace_all("\\([a-z0-9]+\\)","") %>%
      str_replace_all("[[:punct:]]", "")
    
    url = sprintf(base, film)
    
    return(url)
    
  }
  
  tryCatch({
    
    film_url = format_url(film)
    
    # Look up bold elements on the mojo page
    mojo_page = 
      film_url %>%
      read_html() %>%
      html_nodes("b") %>%
      html_text()
    
    # Raise an error if noting on page
    if (length(mojo_page)==2) {stop()}
    
    ind = grep("Worldwide:", mojo_page, ignore.case = TRUE)
    
    revenue = as.integer(str_replace_all(mojo_page[ind + 1], "(\\$)|(,)",""))
    
    # Cost line is unfortunately fixed
    cost_string = mojo_page[9]
    
    # Some handy formatting on the production cost!
    # Thanks box office mojo!
    if (cost_string == "N/A") {
      
      cost = NA
      
    } else {
      
      # Reformat "million / thousand" string
      magnitude = str_extract(cost_string, "(?i)million|thousand")
      
      multipler = ifelse(magnitude == "million", 1000000, 1000)
      
      cost = as.integer(str_replace_all(cost_string, "(\\$)|([a-z])","")) * multipler
      
    }
    
  }, error = function(e) {
    
    revenue = NA
    cost = NA
    
  })
  
  return(list(revenue, cost))
  
}



append_box_office = function(films){
  
  
  
}

get_box_office2 = function(films) {
  
  require(assertthat)
  require(dplyr)
  require(rvest)
  require(stringr)
  
  # Using a films data frame from the get_tomatoes function
  assert_that(
    nrow(films) >= 1 &&
      ncol(films) == 4 &&
      "tbl_df" %in% class(films))
  
  # We'll iteratively find the box office gross for the films in the table
  cash_money = rep(0, nrow(films))
  cost_money = rep(0, nrow(films))
  
  # Box office mojo seems to have a specific URL structure, including:
  # 1. Dropping a leading "The" for movies starting with the word
  # 2. Removing all spaces (obviously)
  # 3. Lower casing (obviously)
  # 4. Removing all punctuation
  # 5. Replacing ampersand with and
  # 6. Removing trailing parenthetic movie descriptions
  #   Note: There are many other idiosyncracies that I can't account for
  #   for example try looking up the kids movie "Megamind". 
  #   What the fuck man
  format_url = function(film) { 
    
    base = "http://www.boxofficemojo.com/movies/?id=%s.htm"
    
    film = 
      str_replace(film, "(?i)^the ", "") %>%
      tolower() %>%
      str_replace_all(" ", "") %>%
      str_replace_all("\\&", "and") %>%
      str_replace_all("\\([a-z0-9]+\\)","") %>%
      str_replace_all("[[:punct:]]", "")
    
    url = sprintf(base, film)
    
    return(url)
    
  }
  
  
  for (i in 1:nrow(films)) {
    
    tryCatch(
      
      {
        film_title = films[i, "title"]
        
        film_url = format_url(film_title)
        
        # Look up bold elements on the mojo page
        mojo_page = 
          film_url %>%
          read_html() %>%
          html_nodes("b") %>%
          html_text()
        
        ind = grep("Worldwide:", mojo_page, ignore.case = TRUE)
        
        revenue = as.integer(str_replace_all(mojo_page[ind + 1], "(\\$)|(,)",""))
        
        # Cost line is unfortunately fixed
        cost_string = mojo_page[9]
        
        # Some handy formatting on the production cost!
        # Thanks box office mojo!
        if (cost_string == "N/A") {
          
          cost = NA
          
        } else {
          
          # Reformat "million / thousand" string
          magnitude = str_extract(cost_string, "(?i)million|thousand")
          
          multipler = ifelse(magnitude == "million", 1000000, 1000)
          
          cost = as.integer(str_replace_all(cost_string, "(\\$)|([a-z])","")) * multipler
          
        }
        
        # Fill the vec with the vals
        cash_money[i] = revenue
        cost_money[i] = cost
      }, error = function(e) { 
        
        cash_money[i] = NA
        cost_money[i] = NA
        
      })
    
  }
  
  films$intl_revenue = cash_money
  films$prod_cost = as.integer(cost_money)
  return(films %>% filter(intl_revenue > 0))
  
}