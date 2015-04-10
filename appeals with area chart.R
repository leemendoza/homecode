
require(xlsx)
require(ggplot2)
require(dplyr)
require(tidyr)
## library(rpivotTable)

######################################################################
## used to convert converted excel dates to real dates
dateCleanup = function(x) {
    if(class(x) == "Factor")
        x = as.character(x)
    if(class(x) != "numeric")
        return (as.Date(as.numeric(x) - 25569, origin="1970-01-01"))
    else
        return (as.Date(x - 25569, origin="1970-01-01"))
}

######################################################################
## used to return a vector of percentages of a given column
colPercent = function (x) {    
    return (x/sum(x, na.rm = TRUE))
}

## the location of the appeals log
fn = "S:\\Appeals Log\\Appeals - LOG\\Appeals Log\\Appeal Log 9-1-07 LT PCS and LOCET combined.xlsx"
## read from the xlsx file
df = read.xlsx2(fn, "Pending OAAS Appeals Log", stringsAsFactors = FALSE)

## date cleanups
df$Date.BOA.DAL.Received.Appeal = dateCleanup(df$Date.BOA.DAL.Received.Appeal)
df$Date.Received.from.BOA = dateCleanup(df$Date.Received.from.BOA)
df$Date.Sent.to.Appeals = dateCleanup(df$Date.Sent.to.Appeals)
df$Date.of.Decision = dateCleanup(df$Date.of.Decision)

## let's limit this to the start of FY 2014
dflimited = filter(df, Date.Received.from.BOA >= "2013-07-01")

## setup for monthly totals
dflimited$monthyear = cut(dflimited$Date.Received.from.BOA, breaks = "month")

## use this to look at a pivot table
## rpivotTable(dflimit)

## this selects just the decision and the month/year the appeal was received from BOA
## it also computes counts for each combination, then transposes the data into
## wide format
timeline = dflimited %>% 
    select(Resolution.Decision, monthyear) %>% 
    group_by(Resolution.Decision, monthyear) %>% 
    summarize("count" = n()) %>%
    spread(monthyear, count)

## fix up the missing label
timeline$Resolution.Decision[which(timeline$Resolution.Decision == '')] = 'None'

## create a new data frame that shows percentage instead of counts for each column (timeframe)
timelinePercent = NULL
## this is the main category column
timelinePercent$Resolution.Decision = timeline$Resolution.Decision

## for each of the remaining columns, calculate percent of the count in each category,
## return the vector, and bind to the rest
for (i in 2:ncol(timeline)) {
    timelinePercent = cbind(timelinePercent, colPercent(timeline[,i]))
} 

## now go back to long format
## convert column names (except Resolution.Decision) into a variable called monthyear, take the 
## values as variable named percent
appealsPercent = timelinePercent %>%
    gather(monthyear, percent, -Resolution.Decision)

## get rid of missing values, converting to zero
appealsPercent[is.na(appealsPercent)] = 0

appealsPercent$monthyear = as.Date(appealsPercent$monthyear)

## plot an area chart showing proportions of each resolution
p = ggplot(appealsPercent, aes(x = monthyear, y = percent, group = Resolution.Decision, fill = Resolution.Decision))  
p + geom_area(position = "fill", color = "black") 

