library(readr)
library(dplyr)
library(hrbrthemes)
library(highcharter)
library(shinyjs)

options(stringsAsFactors = FALSE)


# HTML Custom -----------------------------------------------------------
overview_html = "

<p> Stratton is a hobby 
  <a href = 'https://shiny.rstudio.com/'> shiny application </a>
    I created in my spare time. The app allows you to do some simple investigative
    analysis of your favourite actors and directors.
    <br> <br>
    The app also showcases some of
    the awesome features of Shiny and the growing ecosystem of satellite packages that
    enables the creation of a web-app like this in just <strong> 860 lines of code </strong>.
    
    <br> <br>

    Aside from <a href = 'http://www.abc.net.au/atthemovies/img/2004/about/david_large.jpg'> the obvious </a> 
    a more detailed discusion of my inspiration can be found by clicking the button below:
<p>
"

inspiration_html = "

<p>

The inspiration for this application originally came from 
<a href = 'https://fivethirtyeight.com/datalab/the-four-types-of-tom-cruise-movies/'> this 538 article, </a>
 which I thought was kinda cool. The centrepiece of which was this chart, which groups 
 Tom Cruise movies together using the dimensions of quality and profitibality: </p>

<img  align='centre' height='400' width='450' src='https://espnfivethirtyeight.files.wordpress.com/2015/07/hickey-datalab-tomcruise-1.png?quality=90&strip=all&w=1150&ssl=1'></img>

<br><br>

<p>
While approximately 75% of the way through developing Stratton I realised I had previously seen, but had 
forgotten about, an alarmingly similar application in 2 places 
<a href = 'https://shiny.rstudio.com/gallery/movie-explorer.html'> here </a> and
<a href = 'https://github.com/bokeh/bokeh/tree/master/examples/app/movies'> here </a>...lol.

<br><br>

Anyway, mine's not exactly the same and includes some technical features that I think are pretty cool: </p>

<ul>
<li> No persistent data storage; </li>
<li> (Thus) Dynamic web-scraping; </li>
<li> Multi-threading to increase scrape speed by <strong> 6x </strong>!; </li>
<li> Dynamic K-means clustering; and </li>
<li> Parameterised high-charting, just check out the <i>chart_cluster_h</i> function (it's a bit of a mess) </li>
</ul>

</p>



"
# Load Timer --------------------------------------------------------------
load_data = function() {
  Sys.sleep(2)
  shinyjs::hide("loading_page")
  shinyjs::show("app_body")
}

# Dimension Map --------------------------------------------------------------
dim_map = function(dim) {
  out = switch(dim,
               "Rotten Tomatoes Score" = "rating",
               "Revenue" = "intl_revenue",
               "Year" = "year",
               "Profit" = "profit")
}

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
  
  films$profit = films$intl_revenue - films$prod_cost
  
  return(films)
  
}


# Perform Clustering ------------------------------------------------------
cluster_df = function(df, clusters = 3, dimensions = c("rating", "intl_revenue")) {
  
  train_matrix = df[,dimensions]
  
  train_matrix = data.frame(lapply(train_matrix, scale))
  
  kmean_model = kmeans(train_matrix, clusters)
  
  output = df %>% mutate(cluster = factor(kmean_model$cluster))
  
  return(output)
  
}


# Produce Ggplot Graph -----------------------------------------------------------
chart_cluster = function(df, axes = c("rating", "intl_revenue")) {
  
  require(ggplot2)
  require(hrbrthemes)
  require(ggalt)
  require(gcookbook)
  require(RColorBrewer)
  
  
  # Translate axis vars to english axis labels
  x_lab = switch(axes[2], "rating" = "Rotten Tomatoes Score"
                 , "intl_revenue" = "Box Office Revenue")
  y_lab = switch(axes[1], "rating" = "Rotten Tomatoes Score"
                 , "intl_revenue" = "Box Office Revenue")
  
  # Produce graph
  gg = ggplot(data = df, aes_string(y = axes[1], x = axes[2], color = "cluster")) +
    geom_point(size = 3) +
    scale_y_continuous(limits = c(0, 1.1 * max(df[,axes[1]]))) +
    scale_x_comma(limits = c(-100000, 1.1 * max(df[,axes[2]]))) +
    scale_color_brewer(type = 'qual', palette = 'Accent') +
    labs(x=x_lab, y=y_lab,
         title="Test plot",
         subtitle="A plot that is only useful for demonstration purposes",
         caption="Powered by Tom Bishop and OSIRIS") +
    theme_ipsum_rc(grid="XY") +
    theme(axis.line.x = element_line(color="black"),
          axis.line.y = element_line(color="black"))
  
  # Loop and encircle the clusters using GGALT functionality
  ind = 1
  for (clust in unique(df$cluster)) {
    
    gg = gg + geom_encircle(
      data = filter(df, cluster == clust),
      color = brewer.pal(length(unique(df$cluster)), name = "Accent")[ind],
      s_shape=0.1, expand=0.001
    )
    
    ind = ind + 1
  }
  
  return(gg)
  
}



# Produce Highcharts Graph --------------------------------------------------------------
stratton_thm = hc_theme_merge(
  hc_theme_elementary(),
  hc_theme(
    chart = list(
      style = list(
        fontFamily = 'Arial',
        backgroundColor = NULL,
        plotBackgroundColor = NULL
      )
    ),
    title = list(
      style = list(
        color = 'white'
      )
    )
  )
)

chart_cluster_h = function(df, actor, axes = c("rating", "intl_revenue"), clstr = FALSE) {
  
  require(highcharter)
  require(dplyr)
  require(stringr)
  
  #++++++++++++++++++++++++++++++++++
  # Dynamically build chart attributes
  #++++++++++++++++++++++++++++++++++
  
  # Need a helper to get it done: Build the javascript tooltip formats
  tool_format = function(axis, num) {
    
    dirc = switch(num, "1" = "y", "2" = "x")
    if (axis == 'rating'){
      format = paste0("this.",dirc," + '%'")
    } else if (axis == 'intl_revenue' || axis == 'profit') {
      format = paste0("'$' + (this.", dirc, "/1000000).toFixed(0) + 'm'")
    } else if (axis == 'year') {
      format = paste0("this.", dirc)
    }
    
  }
  
  c_atr = list()
  for (i in c("x","y")) {
    
    axis = ifelse(i=="x", 2, 1)
    
    # Axis labels
    c_atr[[i]]$label_text = switch(axes[axis],
                                   "rating" = "Rotten Tomatoes Score",
                                   "intl_revenue" = "Box Office Revenue",
                                   "year" = "Year",
                                   "profit" = "Profit")
    
    # Formmat for the tooltip
    c_atr[[i]]$tooltip_form =  tool_format(axes[axis],axis)
    
    # Format for the axes
    c_atr[[i]]$label_form = str_replace(c_atr[[i]]$tooltip_form, "\\.[xy]", ".value")
    
    # Axis limits
    c_atr[[i]]$min = switch(axes[axis],
                            "rating" = 0,
                            "intl_revenue" = 0,
                            "profit" = 0,
                            "year" = min(df[,axes[axis]]))
    c_atr[[i]]$max = switch(axes[axis],
                            "rating" = 100,
                            "intl_revenue" = 1.05 * max(df[,axes[axis]]),
                            "profit" = 1.05 * max(df[,axes[axis]], na.rm = TRUE),
                            "year" = max(df[,axes[axis]]))
    
  }
  
  
  #++++++++++++++++++
  # Build base chart
  #++++++++++++++++++
  
  # Cheeky: Grabbed hcaes_string from the dev version of highcharter
  # really really handy for me
  if (clstr) {
    
    base = hchart(df, "scatter", hcaes_string(x = axes[2], y = axes[1], color = 'cluster'))
    
  } else {
    
    base = hchart(df, "scatter", color = "#286090",hcaes_string(x = axes[2], y = axes[1]))
    
  }
  
  #+++++++++++++++
  # Add on extras
  #+++++++++++++++
  
  output = 
    # hc_add_series(data = hulls %>% filter(cluster==2), 
    #               hcaes_string(x = 'intl_revenue', y = 'rating', color = 'cluster'),
    #               type = "polygon"
    #               ) %>%
    base %>%
    hc_plotOptions(
      divBackgroundImage = "osiris-small.png",
      scatter = list(marker = list(radius = 6))
    ) %>%
    hc_yAxis(
      title = list(text = c_atr$y$label_text),
      labels = list(formatter = JS(paste0("function(){return(",c_atr$y$label_form,")}"))), 
      min = c_atr$y$min,
      max = c_atr$y$max,
      linewidth = 1
    ) %>%
    hc_xAxis(
      title = list(text = c_atr$x$label_text),
      labels = list(formatter = JS(paste0("function(){return(",c_atr$x$label_form,")}"))),
      min = c_atr$x$min,
      max = c_atr$x$max
    ) %>%    
    hc_title(text = actor,
             style = list(fontWeight = "bold"),
             align = "left") %>% 
    hc_subtitle(align = "left",
                style = list(fontStyle = "italic"),
                text = paste0("A comparison of ", c_atr$y$label_text, " and ", c_atr$x$label_text)) %>% 
    hc_tooltip(useHTML = TRUE, headerFormat = "",
               # Lol below looks fucked up
               # This hurt my brain so much
               formatter = JS(
                 paste0(
                   "function(){return (",
                   "'<strong>' + this.point.title + '</strong> <br>' + ",
                   "'<strong> Role: </strong>' + this.point.role + '<br>' + ",
                   "'<strong>", c_atr$y$label_text, ": </strong> ' + ", c_atr$y$tooltip_form, " + '<br>' + ",
                   "'<strong>", c_atr$x$label_text, ": </strong> ' + ", c_atr$x$tooltip_form,
                   ")}" 
                 )
               )
    ) %>%
    hc_exporting(enabled =TRUE)
  
  # Finding Convex Hull Around Clusters
  # hulls = df %>% sample_n(0)
  # for (c in unique(df$cluster)) {
  #   
  #   df_c = df %>% filter(cluster == c)
  #   
  #   hull = df[chull(df[,axes[1]],df[,axes[2]]),]
  #   
  #   hulls = hulls %>% union_all(hull)
  #   
  # }
  
  
  
}


# Smoother ----------------------------------------------------------------
add_loess = function(high_chart, df, axes) {
  
  require(highcharter)
  require(dplyr)
  require(stringr)
  require(ggplot2)
  
  # ggplot does the heavy lifting
  gg = ggplot(data = df, aes_string(x = axes[2], y = axes[1])) + geom_smooth()
  
  # Extract the smoothed
  smoothed = ggplot_build(gg)$data[[1]][,c("x","y")]
  
  names(smoothed) = c(axes[2], axes[1])
  
  test = list_parse2(smoothed)
  
  # Add the line to the highchart object
  output = high_chart %>%
    hc_add_series(name = "LOESS smooth",data = test, type = "line") %>%
    hc_plotOptions(
      line = list(
        lineWidth = 6,
        dashStyle = "Dash",
        lineColor = "rgba(0,0,0,0.3)",
        marker = list(radius=0))
    )
  
  return(output)
  
}

