# IMDB Scrapper---------------------------------------------------------
get_financials = function(filmlist, sauce) {
  
  # This needs to be investigated.
  # Slower than mojo because 2 calls to imdb website
  # must be made due to url structure.
  # Works fine multithreding on personal laptop
  # but if digital ocean VM only has 1 core
  # might be in strife.
  
  require(dplyr)
  require(rvest)
  require(stringr)
  require(xml2)
  require(assertthat)
  
  if (sauce == "IMDB") {
    
    v = tryCatch({
      
      film = filmlist$title
      year = as.integer(filmlist$year)
      
      film = str_replace_all(film," ", "+")
      search_url = sprintf("http://www.imdb.com/find?q=%s&s=exaxt_match=True&tt=on", film)
      
      search_results = 
        search_url %>%
        html_session() %>%
        read_html() %>%
        html_nodes(".result_text")
      
      links = search_results %>% xml_find_first("a/@href") %>% html_text()
      description = search_results %>% html_text() %>% tolower()
      
      candidate_link = links[1]
      description = description[1]
      
      assert_that(str_detect(candidate_link,"^\\/title\\/tt.+"))
      
      # Want to match the year but 'video', 'TV' and 'short' are non films
      desc_regex = paste0("((",year-1,")|(",year,")|(",year+1,"))","(?!.+((video)|(tv)|(short)))")
      
      # Let's test if we've got a non-video / non-tv show that
      # was made in the same year (+- 1 yr) as our movie
      assert_that(str_detect(description, desc_regex))
      
      # Bingo - we have success  
      film_url = sprintf("http://www.imdb.com%s", str_extract(candidate_link,"^\\/title\\/tt[0-9]+"))
      
      block = 
        film_url %>%
        html_session() %>%
        read_html() %>%
        html_nodes("#titleDetails .txt-block") %>%
        html_text() %>% paste0(collapse = "")
      
      cost = 
        str_extract(block, "Budget\\:.{0,}\\$[0-9\\,]+")  %>%
        str_extract("\\$[0-9\\,]+") %>%
        str_replace_all("[\\$\\,]","") %>%
        as.integer()
      
      revenue = 
        str_extract(block, "Gross\\:.+\\$[0-9\\,]+") %>%
        str_extract("\\$[0-9\\,]+") %>%
        str_replace_all("[\\$\\,]","") %>%
        as.integer()
      
      return(c(revenue, cost)) 
      
    }, error = function(e) {
      
      return(c(NA, NA))
      
    })
    
  } else {
    
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
      
      film = filmlist$title
      year = as.integer(filmlist$year)
      
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
    
  }

  return(v)
  
}