library(data.table)
library(plyr)
library(dplyr)
library(stringr)
library(ggplot2)
library(maps)
library(bit64)
library(RColorBrewer)
library(choroplethr)

simpleCap = function(x) {
    if(!is.na(x)) {
        s = strsplit(x, " ")[[1]]
        paste(toupper(substring(s, 1, 1)), substring(s, 2), sep = "", collapse = " ")
<<<<<<< HEAD
    } else (NA)        
=======
    } else (NA)       
>>>>>>> origin/master
}

## read in the employment data

dt = fread("c:\\data\\2012.annual.singlefile.csv", sep=",", colClasses=c("character", rep("integer", 5),
                                                                         "character", "character",
                                                                         "integer64", "integer64",
                                                                         "integer64", "integer64", "integer64",
                                                                         "integer", "integer", "character",
                                                                         rep("numeric", 7)))
## take a peek at the data
dim(dt)
head(dt)

## additional data
for (u in c("agglevel", "area", "industry", "ownership", "size")) {
    assign(u, read.csv(paste("c:\\data\\", u, "_titles.csv", sep=""), stringsAsFactors=F))
}

## set up these reference files for joining
codes = c("agglevel", "area", "industry", "ownership", "size")
## make a copy just in case something goes wrong
dtfull = dt

## clean up factors
dtfull$agglvl_code = as.integer(dtfull$agglvl_code)

dtfull2 = merge(dtfull, agglevel, by="agglvl_code", all.x = TRUE)
dtfull2 = merge(dtfull2, area, by="area_fips", all.x = TRUE)
dtfull2 = merge(dtfull2, industry, by="industry_code", all.x = TRUE)
<<<<<<< HEAD
dtfull2 = merge(dtfull2, ownership2, by="own_code", all.x = TRUE)
dtfull2 = merge(dtfull2, size2, by="size_code", all.x = TRUE)
=======
dtfull2 = merge(dtfull2, ownership, by="own_code", all.x = TRUE)
dtfull2$size_code = as.integer(dtfull2$size_code)
dtfull2 = merge(dtfull2, size, by="size_code", all.x = TRUE)
>>>>>>> origin/master

data(county.fips)
county.fips$fips = str_pad(county.fips$fips, width = 5, pad = "0")

county.fips$polyname = as.character(county.fips$polyname)
county.fips$county = sapply(gsub('[a-z\ ]+, ([a-z\ ]+)','\\1', county.fips$polyname),simpleCap)
county.fips = unique(county.fips)

data(state.fips)
state.fips$fips = str_pad(state.fips$fips, width=2, pad="0", side = 'left')

state.fips$state = as.character(state.fips$polyname)
state.fips$state = gsub("([a-z\ ]+):[a-z\ \\']+", '\\1', state.fips$state)
state.fips$state = sapply(state.fips$state, simpleCap)

mystatefips = unique(state.fips[,c('fips', 'abb', 'state')])
