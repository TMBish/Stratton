library(readr)
library(dplyr)
library(hrbrthemes)
library(highcharter)
library(shinyjs)
library(shiny)
library(shinyBS)
library(shinysky)


options(stringsAsFactors = FALSE)

# Load Utils --------------------------------------------------------------
sapply(list.files("./utils/", pattern = "*.R$", full.names = TRUE),source)

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