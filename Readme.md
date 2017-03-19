# Overview

Stratton 

## Use

Visit stratton at my website - hosted here.

If you want to play around with it on your local machine you can do so pretty easily. 

### Step 1

Get some packages you might not already have:

```R
# Packs on CRAN
cran_packs = c("shinyBS", "shinyjs", "DT", "highcharter")
lapply(cran_packs, install.packages)

# Shiny Sky
library(devtools)
install_github("AnalytixWare/shinysky")

```
### Step 2

Thank Rstudio for thier *runGithub* function:

```R
runGithub("TMBish/Stratton")
```

## Issues & Improvements

* __Add:__ Movie timeline tab in nice bootstrap template
* __Fix:__ Redirect financial info scraping to a more robust and complete data source
	+ Getting from [Box Office Mojo](http://www.boxofficemojo.com/) currently
	+ They have a really crap URL system leading to lots of missing financial data in stratton (for example [smh](http://www.boxofficemojo.com/movies/?id=mastermind.htm))
	+ Did re-write for imdb (in the variants sub-folder) but it was too slow 
* __Add:__ error region for LOESS regression - looks nicer that way
* __Add:__ functionality to dynamically label clusters a la 538

