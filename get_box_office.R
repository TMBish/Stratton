get_box_office = function(films) {
  
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
  
  # Box office mojo seems to have a specific URL structure, including:
  # 1. Dropping a leading "The" for movies starting with the word
  # 2. Removing all spaces (obviously)
  # 3. Lower casing (obviously)
  # 4. Removing all punctuation
  format_url = function(film) { 
    
    base = "http://www.boxofficemojo.com/movies/?id=%s.htm"
    
    film = 
      str_replace(film, "(?i)^the ", "") %>%
      tolower() %>%
      str_replace_all(" ", "") %>%
      str_replace_all("[[:punct:]]", "")
    
    url = sprintf(base, film)
      
    return(url)
    
  }
  
  
  for (i in seq_along(nrow(films))) {
    
    flim_title = films[i, "title"]
    
    film_url = format_url(film_title)
    
    mojo_page = 
      film_url %>%
      read_html() %>%
      html_nodes("td") %>%
      html_text()
    
    grep("= Worldwide:", mojo_page)
    
    revenue = str_extract(mojo_page, "(?i)(?<=Worldwide: \\$)[0-9]+")

    
    
    
  }
  
  
  
  
  
}