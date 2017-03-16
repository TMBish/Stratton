# Overview

Stratton 

## Use

Visit stratton at my website - hosted here.

If you want to play around with it on your local machine use shiny's sweet rungithub function:

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

