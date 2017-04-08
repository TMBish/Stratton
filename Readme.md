# Overview

## Use

I've hosted this app on a personal AWS shiny server which you can access [here.](tmbish.me/shiny/stratton "Me Shiny Server")

If you want to play around with it on your local machine you can do so pretty easily. This will also run quite a bit quicker (depending on your machine size) since I multi-threaded the webscraping which isn't utilized on the AWS VM which has only 1 core.

### Step 1

Get some packages you might not already have:

```R
# Packs on CRAN
cran_packs = c("shinyBS", "shinyjs", "DT", "highcharter", "devtools")
lapply(cran_packs, install.packages)

# Shiny Sky
library(devtools)
install_github("AnalytixWare/shinysky")

```
### Step 2

Thank Rstudio for thier sweet *runGithub* function:

```R
runGithub("TMBish/Stratton")
```

## Issues & Improvements

* __Add:__ Movie timeline tab in nice bootstrap template
* __Issue:__ IMDB scraping is much slower but box office mojo is prone to data errors:
	+ BOM have a really crap URL system leading to lots of missing financial data if you scrape this data source (for example [this dumbass url](http://www.boxofficemojo.com/movies/?id=mastermind.htm))
* __Add:__ error region for LOESS regression - looks nicer that way
* __Add:__ functionality to dynamically label clusters a la 538 - I think this would be challenging.

