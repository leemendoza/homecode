library(data.table)
library(plyr)
library(dplyr)
library(stringr)
library(ggplot2)
library(maps)
library(bit64)
library(RColorBrewer)
library(choroplethr)


## a discretizing function
Discretize = function(x, breaks = NULL) {
    if (is.null(breaks)) {
        breaks = quantile(x, c(seq(0, .8, by=.2), 0.9, 0.95, 0.99, 1))
        if (sum(breaks == 0)>1) {
            temp = which(breaks == 0, arr.ind=TRUE)
            breaks = breaks[max(temp):length(breaks)]
        }
    }
    
    x.discrete = cut(x, breaks, include.lowest = TRUE)
    breaks.eng = ifelse(breaks > 1000, paste(round(breaks/1000), 'K', sep = ''), round(breaks))
    Labs = paste(breaks.eng[-length(xx)], breaks.eng[-1], sep='-')
    ## apply the labels to the data
    levels(x.discrete) = Labs
    return(x.discrete)
}


simpleCap = function(x) {
    if(!is.na(x)) {
        s = strsplit(x, " ")[[1]]
        paste(toupper(substring(s, 1, 1)), substring(s, 2), sep = "", collapse = " ")
    } else (NA)       
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
dtfull2$own_code = as.integer(dtfull2$own_code)
dtfull2 = merge(dtfull2, ownership, by="own_code", all.x = TRUE)
dtfull2$size_code = as.integer(dtfull2$size_code)
dtfull2 = merge(dtfull2, size, by="size_code", all.x = TRUE)

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

lower48 = setdiff(unique(state.fips$state), c("Hawaii", "Alaska"))

myarea = merge(area, county.fips, by.x="area_fips", by.y="fips", all.x = T)
myarea$state_fips = substr(myarea$area_fips, 1, 2)
myarea = merge(myarea, mystatefips, by.x = "state_fips", by.y = "fips", all.x = T)
myarea = data.table(myarea)

dtfull2 = left_join(dtfull2, myarea)
dtfull2 = filter(dtfull2, state %in% lower48)

##save to disk
save(dtfull2, file = "c:\\data\\dtfull2.rda", compress = T)

## get only state-level data, and only avg_annual_pay and annual_avg_emplvl
d.state = filter(dtfull2, agglvl_code == 50)
d.state = select(d.state, state, avg_annual_pay, annual_avg_emplvl)

## descretize the pay and employment variables
d.state$wage = cut(d.state$avg_annual_pay, quantile(d.state$avg_annual_pay, c(seq(0, 0.8, by = 0.2), .9, .95, .99, 1)))
d.state$annual_avg_emplvl = as.integer(d.state$annual_avg_emplvl)
d.state$empquantile = cut(d.state$annual_avg_emplvl, quantile(d.state$annual_avg_emplvl, c(seq(0, .8, by=.2), 0.9, 0.95, 0.99, 1)))

## use meaningful names - get the list of quantile values
x = quantile(d.state$avg_annual_pay, c(seq(0, .8, by=.2), 0.9, 0.95, 0.99, 1))
## create names
xx = paste(round(x/1000), 'K', sep = '')
Labs = paste(xx[-length(xx)], xx[-1], sep='-')
## apply the labels to the data
levels(d.state$wage) = Labs

## do the same thing with emplyment level
x = quantile(d.state$annual_avg_emplvl, c(seq(0, .8, by=.2), 0.9, 0.95, 0.99, 1))
## create names
xx = ifelse(x > 1000, paste(round(x/1000), 'K', sep = ''), round(x))
Labs = paste(xx[-length(xx)], xx[-1], sep='-')
## apply the labels to the data
levels(d.state$empquantile) = Labs

## now do at the county level
# ## appropriate aggregation code = 70
 d.cty = filter(dtfull2, agglvl_code == 70) %>%
         select(state, county, abb, avg_annual_pay, annual_avg_emplvl) %>%
         mutate(wage = Discretize(avg_annual_pay), empquantile = Discretize(annual_avg_emplvl))


## starting the visualization part
state_df = map_data('state')
county_df = map_data('county')

transform_mapdata = function(x){
    names(x)[5:6] = c('state', 'county')
    for (u in c('state', 'county')){
        x[,u] = sapply(x[,u], simpleCap)
    }
    return (x)
}

state_df = transform_mapdata(state_df)
county_df = transform_mapdata(county_df)

chor = left_join(state_df, d.state, by='state')
ggplot(chor, aes(long, lat, group=group)) +
    geom_polygon(aes(fill=wage)) +
    geom_path(color='black', size = 0.2) +
    scale_fill_brewer(palette='PuRd') +
    theme(axis.text.x=element_blank(), axis.text.y=element_blank(),
          axis.ticks.x=element_blank(),
          axis.ticks.y=element_blank())

chor = left_join(county_df, d.cty)
ggplot(chor, aes(long, lat, group=group)) +
    geom_polygon(aes(fill=wage)) +
    geom_path(color='white', alpha=0.5, size = 0.2) +
    geom_polygon(data=state_df, color='black', fill=NA) +
    scale_fill_brewer(palette='PuRd') +
    labs(x='', y='', fill='Avg Annual Pay') +
    theme(axis.text.x=element_blank(), axis.text.y=element_blank(),
          axis.ticks.x=element_blank(),
          axis.ticks.y=element_blank())

