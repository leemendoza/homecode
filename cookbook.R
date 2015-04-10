library(data.table)
library(plyr)
<<<<<<< HEAD
=======
<<<<<<< HEAD
>>>>>>> b4e4520dd100c3ef05e13b5f212746309c495bdb
library(dplyr)
library(stringr)
library(ggplot2)
library(maps)
library(bit64)
library(RColorBrewer)
library(choroplethr)

<<<<<<< HEAD
=======

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


>>>>>>> b4e4520dd100c3ef05e13b5f212746309c495bdb
simpleCap = function(x) {
    if(!is.na(x)) {
        s = strsplit(x, " ")[[1]]
        paste(toupper(substring(s, 1, 1)), substring(s, 2), sep = "", collapse = " ")
<<<<<<< HEAD
<<<<<<< HEAD
    } else (NA)        
=======
    } else (NA)       
>>>>>>> origin/master
=======
    } else (NA)       
>>>>>>> b4e4520dd100c3ef05e13b5f212746309c495bdb
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
<<<<<<< HEAD
dtfull2 = merge(dtfull2, ownership2, by="own_code", all.x = TRUE)
dtfull2 = merge(dtfull2, size2, by="size_code", all.x = TRUE)
=======
dtfull2 = merge(dtfull2, ownership, by="own_code", all.x = TRUE)
dtfull2$size_code = as.integer(dtfull2$size_code)
dtfull2 = merge(dtfull2, size, by="size_code", all.x = TRUE)
>>>>>>> origin/master
=======
dtfull2$own_code = as.integer(dtfull2$own_code)
dtfull2 = merge(dtfull2, ownership, by="own_code", all.x = TRUE)
dtfull2$size_code = as.integer(dtfull2$size_code)
dtfull2 = merge(dtfull2, size, by="size_code", all.x = TRUE)
>>>>>>> b4e4520dd100c3ef05e13b5f212746309c495bdb

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
<<<<<<< HEAD
=======

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

=======
library(ggplot2)
library(reshape2)

setwd("~/GitHub/HomeCode")
veh = read.csv("data\\vehicles.csv", stringsAsFactors = FALSE, sep = ",", na.strings = "")
dim(veh)
head(veh)
unique(veh$trany)
names(veh)
length(unique(veh$year))
first_year = min(veh$year)
last_year = max(veh$year)
barplot(table(veh$fuelType1))
veh$trany2 = ifelse(substr(veh$trany, 1, 4) == "Auto", "Auto", "Manual")

## split-apply-cmbine technique. We'll split the dataframe into groups by year, 
## apply mean function to specific variables, and combine the results into a new
## data frame

## ddply takes data, grouping variable, 'summarise' to tell the ddply function to create
## a new data frame, containing the remaining computations
mpgByYear = ddply(veh, ~year, 
                  summarise, 
                  avgMPG = mean(comb08), 
                  avgHwy = mean(highway08), 
                  avgCity = mean(city08))

## so now we'll plot the avgMPG against the year with a smoothed conditional mean
ggplot(mpgByYear, aes(year, avgMPG)) +
        geom_point() + 
        geom_smooth() +
        xlab("Year") + 
        ylab("Average MPG") +
        ggtitle("All cars")

## look at fueltype by year
fuelTypeByYear = ddply(veh, ~fuelType1 + year, 
                        summarise,
                       N = length(fuelType1))

## create a bar chart for such
qplot(data = fuelTypeByYear, 
      x = year, 
      y = N, 
      ylab = "Number of vehicles", 
      xlab = "Year",
      fill = fuelType1, 
      geom = "bar", 
      stat="identity", 
      position = "dodge")

## we should filter some of the fuel types
gasCars = subset(veh, fuelType1 %in% c("Regular Gasoline", "Premium Gasoline", "Midgrade Gasoline") )

mpgByYear_gas = ddply(gasCars, ~year, 
                  summarise, 
                  avgMPG = mean(comb08), 
                  avgHwy = mean(highway08), 
                  avgCity = mean(city08))

## so now we'll plot the avgMPG against the year with a smoothed conditional mean
ggplot(mpgByYear_gas, aes(year, avgMPG)) +
    geom_point() + 
    geom_smooth() +
    xlab("Year") + 
    ylab("Average MPG") +
    ggtitle("Gas cars")

## let's see the relationship between displacement and fuel efficiency
## convert from character to numeric so we can scatter plot
gasCars$displ = as.numeric(gasCars$displ)

ggplot(gasCars, aes(displ, comb08), ylim = c(0, 50)) + geom_point() + geom_smooth()

## now do we have more small cars now?
avgCarSize = ddply(gasCars, ~year, summarise, avgDispl = mean(displ))
ggplot(avgCarSize, aes(year, avgDispl)) + geom_point() + geom_smooth()

## get both displacement and mpg per year
avgDispMpg = ddply(gasCars, ~year, summarise, 
                   avgMPG = mean(comb08), 
                   avgDispl = mean(displ))

## see if there's a correlation
with(avgDispMpg, plot(avgDispl, avgMPG ))
head(avgDispMpg)

## melt this dataframe to long version
byYear2 = melt(avgDispMpg, id = "year")

## that created "year variable value", so lets do some subs on the levels of the variable
levels(byYear2$variable) = c("Average MPG", "Avg Displacement")

## create a panel plot. This will create a plot for each variable. the 'scales = 
## free_y' is important - this lets each variable use it's own scale for the y axis
ggplot(byYear2, aes(year, value)) +
    geom_point() +
    geom_smooth() + 
    facet_wrap(~variable, ncol = 1, scales = "free_y")

## are automatic or manual transmissions more efficient for four cylinder engines?
gasCars4 = subset(gasCars, cylinders == "4")
ggplot(gasCars4, aes(factor(year), comb08)) +
    geom_boxplot() + 
    facet_wrap(~trany2, ncol = 1) +
    theme(axis.text.x = element_text(angle = 45)) +
    labs(x = "Year", y = "MPG")

## look at the proportion of manual cars each year
ggplot(gasCars4, aes(factor(year), fill = factor(trany2))) +
    geom_bar(position = "fill") +
    labs(x = "Year", y = "Proportion of cars", fill = "Transmission") +
    theme(axis.text.x = element_text(angle = 45)) +
    geom_hline(yintercept = 0.5, linetype = 2)

## investigating the makes and models of the automobiles
carsMake = ddply(gasCars4, ~year, summarise, numberOfMakes = length(unique(make)))

ggplot(carsMake, aes(year, numberOfMakes)) +
    geom_point() +
    labs(x = "Year", y = "Number of available makes") +
    ggtitle("Four cylinder cars")

## let's look at efficiency for each manufacturer for each year
## this gets the car manufacturers for each year...
uniqMakes = dlply(gasCars4, ~year, function(x) unique(x$make))
## this gets the manufacturers in common for every year
commonMakes = Reduce(intersect, uniqMakes)

## get the fuel efficiency of these manufacturers
commonCars = subset(gasCars4, make %in% commonMakes)
## get year, make, and avg mileage
commonMpg = ddply(commonCars, ~year + make, summarise, avgMPG = mean(comb08))

## plot all that
ggplot(commonMpg, aes(year, avgMPG)) +
    geom_line() + 
    geom_smooth(method = "lm") +
    facet_wrap(~make, nrow = 3)
>>>>>>> origin/master
>>>>>>> b4e4520dd100c3ef05e13b5f212746309c495bdb
