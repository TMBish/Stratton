library(readr)
library(dplyr)
library(hrbrthemes)

options(stringsAsFactors = FALSE)

# Type-ahead Lists ---------------------------------------------------------
actors_list = read_csv('./data/actors.csv')

directors_list = read_csv('./data/directors.csv')

actor_director = actors_list %>% inner_join(directors_list)

typeahead_data = 
  cbind(actors_list, data.frame(Role = rep("Actor",1000))) %>%
  anti_join(actor_director) %>%
  union_all(cbind(directors_list, data.frame(Role = rep("Director", 250)))) %>%
  union_all(cbind(actor_director, data.frame(Role = rep("Actor / Director", nrow(actor_director)))))

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




# Box Office Mojo ---------------------------------------------------------
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

append_box_office = function(films){
  
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
  
  return(films)
  
}


# Perform Clustering ------------------------------------------------------
cluster_df = function(df, clusters = 3, dimensions = c("rating", "intl_revenue")) {
  
  train_matrix = df[,dimensions]
  
  kmean_model = kmeans(train_matrix, clusters)
  
  output = df %>% mutate(cluster = factor(kmean_model$cluster))
  
  return(output)
  
}


# Produce Graph -----------------------------------------------------------
chart_cluster = function(df, axes = c("rating", "intl_revenue")) {
  
  require(ggplot2)
  require(hrbrthemes)
  require(gcookbook)
  
  x_lab = switch(axes[2], "rating" = "Rotten Tomatoes Score"
                        , "intl_revenue" = "Box Office Revenue")
  y_lab = switch(axes[1], "rating" = "Rotten Tomatoes Score"
                        , "intl_revenue" = "Box Office Revenue")
  
  ggplot(data = df, aes_string(y = axes[1], x = axes[2], color = "cluster")) +
    geom_point(size = 3) +
    scale_y_continuous(limits = c(0,100)) +
    scale_x_comma() +
    labs(x=x_lab, y=y_lab,
         title="Test plot",
         subtitle="A plot that is only useful for demonstration purposes",
         caption="Powered by Tom Bishop and OSIRIS") +
    theme_ipsum_rc(grid="XY") +
    theme(axis.line.x = element_line(color="black"),
          axis.line.y = element_line(color="black"))
    
}
