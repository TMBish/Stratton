# Box Office Mojo ---------------------------------------------------------
get_financials = function(film, year, actor) {
  
  require(dplyr)
  require(rvest)
  require(stringr)
  require(xml2)
  
  v = tryCatch({
   
    film = str_replace_all(film," ", "+")
    search_url = sprintf("http://www.imdb.com/find?q=%s&s=exaxt_match=True&tt=on", film)
    
    search_results = 
      search_url %>%
      read_html() %>%
      html_nodes(".result_text")
    
    links = search_results %>% xml_find_first("a/@href") %>% html_text()
    description = search_results %>% html_text() %>% tolower()
    
    film_url = sprintf("http://www.imdb.com%s", str_extract(links[1],"^\\/title\\/tt[0-9]+"))
    
    print("success")
    # plausible = grep("^\\/title\\/tt.+", links)
    # 
    # # Want to match the year but 'video', 'TV' and 'short' are non films
    # this_regex = paste0("((",year-1,")|(",year,")|(",year+1,"))", "(?!.+((video)|(tv)|(short)))")
    # 
    # # Let's test if we've got a non-video / non-tv show that
    # # was made in the same year as our movie
    # bingo = grep(this_regex, description[plausible], perl = TRUE)
    # 
    # if (length(bingo) == 1) {
    #   print("bingo")
    #   
    #   film_url = sprintf("http://www.imdb.com%s", str_extract(links[bingo],"^\\/title\\/tt[0-9]+"))
    #   
    # } else {
    #   
    #   print(":(")
    #   
    #   potential_films = 
    #     links[grep("^\\/title\\/tt.+",links)] %>%
    #     str_extract("^\\/title\\/tt[0-9]+")
    #   
    #   # Test each URL for instances of the actor's name
    #   test_suffix = function(imdb_suffix, actor) {
    #     
    #     url = sprintf("http://www.imdb.com%s", imdb_suffix)
    #     
    #     cast_links = url %>%
    #       read_html() %>%
    #       html_nodes("#titleCast .itemprop") %>%
    #       html_text()
    #     
    #     actor_count = sum(grepl(actor, cast_links))
    #     
    #     return(actor_count)
    #   }
    #   
    #   name_count = unlist(lapply(potential_films, function(x){return(test_suffix(x, actor))}))
    #   
    #   candidate = which.max(name_count)
    #   
    #   film_url = sprintf("http://www.imdb.com%s", potential_films[candidate])
    #   
    # }
    
    block = 
      film_url %>%
      read_html() %>%
      html_nodes("#titleDetails .txt-block") %>%
      html_text() %>% paste0(collapse = "")
    
    cost = 
      str_extract(block, "Budget\\:.+\\$[0-9\\,]+") %>%
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
  
  return(v)

}