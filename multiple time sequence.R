library(data.table)
library(plyr)
library(reshape2)
library(scales)
library(ggplot2)

## create a sequence of dates
dateseq = seq(ISOdate(2010,1,1), ISOdate(2014,12,31), by="day")

## create a sequence of values
firstval = seq(1, length(dateseq), by = 1)

## create another sequence of values
secondval = seq(100, length.out = length(firstval), by = 1)

## tie together
dt = data.table(cbind(as.character(as.Date(dateseq)), firstval, secondval))

## cut according to quarters
dt$quarters = cut(as.Date(dt$V1), breaks = "quarter")

## summarize by quarter
vals = ddply(dt, ~quarters, summarise, v1 = mean(as.numeric(firstval)), v2 = mean(as.numeric(secondval)))

## plot
## melt first
melted = melt(vals, id.vars="quarters")
## trim up the dates, dropping the day value
melted$quarters = substr(melted$quarters, 1, 7)
ggplot(melted, aes(x=quarters, y = value, group = variable)) + geom_point(aes(color = variable)) +
        geom_line(aes(color = variable)) +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))

