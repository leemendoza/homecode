library(plyr)
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


