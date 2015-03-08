# ## markdown lecture
# # a text to html conversion tool for web writers (john gruber)
#     *itlaics*
#     ** bold**
#     # main heading
#     ## secondary heading
#     ### tertiary heading
#     - list one
#     - list two
# 
# ordered list (numbers don't matter, markdown will fix numbers)
#     1. first
#     2. second
#     3. third
#     
# links
#     [text in sqaure brackets](url)
# 
#     newlines are double space

## R markdown

# simple, so we don't have to focus on formatting, but do the writing instead
# http://daringfireball.net/projects/markdown
# 
# So R markdown is the integration of R code with markdown (above), using live R code
# 
# the results of the R code are inserted into the output markdown document
# 
# a core tool in literate statistical programming
# 
# knitr converts r markdown inot html (or other things)
# straight markdown can be converted using the markdown package
# 
# any basic text editor can be used to create a markdown document
# 
# R markdown -> markdown -> html. The only file edited in this flow is the R markdown file
# 
# Literate statistical programming with knitr
# 
# putting data and code together in the same document
# 
# an article is a stream of text and code
# analysis code is divided into text and code "chunks"
# presentation code formats results (tables, plots, etc)
# article text explains what's going on
# literate programs are weaved to produce human-readable documents and tangled to produce
#     machine-readable documents
# 

very simplified formatting

good for
manuals
short/medium length thechnical documents
tutorials
reports (esp. if automatic or generated periodically)
Data preprocessing documents/summaries

not good for 
very long research articles
complex time consuming queries
complicated formatting

Rmd -> md -> html

only edit the Rmd file

making tables
library(xtable)
xt = xtable(summary(fit))
print(xt, type = "html")


global options. applies to every code chunk

```{r setoptions, echo=FALSE}
opts_chunk$set(echo = FALSE, results = "hide")
```

but then can override for specific chunks

results - "asis", "hide"
echo - "TRUE", "FALSE"

caching computations

cache=TRUE
the output of a chunk is stored on disk, so next time document is created the results 
are read from disk


library(plyr)

weekdayorweekend = function(x){
    theday = weekdays(x)
    if (theday == "Saturday"){
        answer = "weekend"
    } else {
        answer = "weekday"
    }
    answer    
}

data = read.table("activity.csv", header=TRUE, sep=",")
## convert the variable 'interval' from an integer to a factor
data$interval = as.factor(data$interval)

tminutes = function(x){
    ## minutes = last two characters
    minutes = as.integer(substr(x, nchar(x)-1, nchar(x)))
    ## hrs = everything except the last two characters; if there's only
    ## two characters, then hrs = 0
    hrs = ifelse(nchar(x) > 2, as.integer(substr(x, 1, nchar(x)-2)), 0)
    thevalue = (60 * hrs) + minutes
    ## return
    thevalue
}


## calculate average steps per interval, across days
act_pattern = ddply(data, ~interval, summarise, meansteps = mean(steps, na.rm = TRUE))
## convert the 'interval' into a more usable value for plotting the time series
act_pattern$minutes = tminutes(as.character(act_pattern$interval))

## first, get all the rows where 'steps' is NA
missing = data[which(is.na(data$steps)),]
## now merge this data set with the act_pattern data set by 'interval'.  The act_pattern
## data set has the average values for each interval. 'meansteps' will be added to each
## interval in the resulting data set
notna = merge(act_pattern, missing, by="interval")

## now merge this data set with the original data, which is riddled with NA.
## merge based on 'interval', 'steps', and 'date'. The meansteps column will be 
## added to the resulting data set. I used 'steps' as a joining factor so that the 
## 'meansteps' value will only be added to rows in which is.na(steps) is true.
all = merge(notna, data, by=c("interval", "steps", "date"), all.y = TRUE)

# finally, if 'steps' == NA, then replace NA with the 'meansteps' value
all$steps = ifelse(is.na(all$steps), all$meansteps, all$steps)
## to create a data set identical to the original but with imputed values
## remove extra column
all$meansteps = NULL
## and use original column order 
all = all[c("steps", "date", "interval")]


## convert the date from a factor to an actual date
all$date = as.Date(all$date)
## apply our weekday or weekend function
all$ww = weekdayorweekend(all$date)






























