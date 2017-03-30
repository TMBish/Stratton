library(readr)
library(dplyr)
library(highcharter)
library(shinyjs)
library(shiny)
library(shinyBS)
library(shinysky)
library(DT)
library(stringr)
library(assertthat)

options(stringsAsFactors = FALSE)

# Load Utils --------------------------------------------------------------
sapply(list.files("./utils/", pattern = "*.R$", full.names = TRUE),source)

# HTML Custom -----------------------------------------------------------
use_html = read_file("./data/html_1.html")

examples_html = read_file("./data/html_2.html")

overview_html = read_file("./data/html_3.html")

inspiration_html = read_file("./data/html_4.html")

# Load Timer --------------------------------------------------------------
load_data = function() {
  Sys.sleep(1)
  shinyjs::hide("loading_page")
  shinyjs::show("app_body")
}

# Dimension Map --------------------------------------------------------------
dim_map = function(dim) {
  out = switch(dim,
               "Rotten Tomatoes Score" = "rating",
               "Revenue" = "intl_revenue",
               "Year" = "year",
               "Profit" = "profit",
               "Production Cost" = "prod_cost")
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