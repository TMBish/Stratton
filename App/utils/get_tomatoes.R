# Rotten Tomatoes ---------------------------------------------------------
get_tomatoes = function(person) {
  
  require(rvest)
  require(stringr)
  require(dplyr)
  
  person_string = str_replace_all(tolower(person), " ", "_")
  
  celeb_url = sprintf("https://www.rottentomatoes.com/celebrity/%s/", person_string)
  
  
  # Function to decode rotten tomatoes
  # credit string into english
  # only interested in actor, director, or actor / director roles
  assign_role = function(credit_string) {
    
    # Remove produce, screenwriter credits
    credit_string = str_replace_all(credit_string, "(?i)producer|screenwriter|(executive producer)"  ,"")
    
    if (grepl("director", credit_string, ignore.case = TRUE)){
      
      aug = str_replace_all(credit_string, "(?i)director", "")
      
      if (grepl("(actor)|[a-z]{3,}", aug, ignore.case = TRUE)) {
        
        return("Actor / Director")
        
      } else {
        
        return("Director")
        
      }
      
    } else if (grepl("(actor)|[a-z]{3,}", credit_string, ignore.case = TRUE)) {
      
      return("Actor")
      
    } else {
      
      # Must be a producer or some shit
      return("Null")
      
    }
    
  }
  
  # Scraping the filmography table using rvest
  # got the Xpath / CSS id of the table
  film_tables = tryCatch(
    {
      
      film_tables = celeb_url %>%
        read_html() %>%
        html_nodes(xpath = "//*[@id='filmographyTbl']") %>%
        html_table()
      
      films = film_tables[[1]]
      
      names(films) = tolower(names(films))
      
      films$role = lapply(films$credit, assign_role)
      
      films = 
        films %>%
        mutate(
          rating = str_replace_all(rating, "\\%", "")
        ) %>%
        select(-credit) %>%
        filter(
          rating != "No Score Yet",
          role != "Null"
        ) %>%
        mutate(rating = as.integer(rating))
      
    }, error = function(e) {
      message("Actor or director not found")  
      return(NA)
    }
  )
  
  return(films)
  
}