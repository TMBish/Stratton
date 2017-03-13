# Box Office Mojo ---------------------------------------------------------
get_financials = function(film) {
  
  require(assertthat)
  require(dplyr)
  require(rvest)
  require(stringr)
  
  
  film = "Cast Away"
  
  session = html_session("https://www.imdb.com")
  
  form = html_form(session)[[1]]
  
  form = set_values(form, q = film)
  
  url = submit_form(session, form)
  
  top_result = read_html(url) %>% html_nodes(".result_text , .result_text a")
  
  
  
  
  
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
  
  v = tryCatch({
    
    film_url = format_url(film)
    
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
    
    return(c(revenue, cost))
    
  }, error = function(e) {
    
    return(c(NA,NA))
    
  })
  
  return(v)
  
}
