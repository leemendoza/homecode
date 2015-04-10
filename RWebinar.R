## R data wrangling webinar : Garrett Grolemund 2015-01-14
## garrett@rstudio.com
## @StatGarrett
## bit.ly/wrangling-webinar

two packages
tidyr, dplyr
cheat sheets at rstudio.com/resources/cheatsheets

tbl - just like a data frame, but looks better in the console
library(dplyr)
tbl_df(diamonds)
tbl_df(airquality)
airquality

pipe operator %>%
    
    diamonds$x %>% mean()
uses LHS as first arugment in the RHS

easier to work with data when each variable is in one column (tidy data)
each observation is in its own row
each type of observation in its own table

tidyr - reshapes the layout of the tables
gather() and spread()

country, year, n

use the gather function
library(tidyr)
gather(cases, "year", "n", 2:4)
data frame to reshape, name of new key column, name of new value column, 

city, size, amount -> city, large, small

spread()
key, value
spread(df, key col, value col)

gather() <-> spread()

unite() and separate()

separate splits a col by a char string operator
separate(storms, date, sep="-")
unite() does the opposite

====================================
dplyr
====================================
library(dplyr)

install.packages("nycflights")
select(), filter(), mutate(), summarise()

## get a subset of columns
select(storms, storm, pressure)
negative sign gives all but negative col

filter() - filters rows

mutate() - returns a data frame to add derived columns to a data frame
mutate(storms, ratio = pressure/wind, inverse = ratio^-1)

summarise() - takes a vector and returns a single value

arrange() - rearrange rows according to the value of a column
arrange(storms, desc(wind), date) ## ordered by wind (desc), then by date

pipe operator

storms %>% filter(wind >= 50) %>% ## first filters
    select(storm, pressure)     ## then selects storm and pressure

just say 'then' when you see pipe

ctrl + shift + m

pollution %>% group_by(city) %>% summarize(mean = mean(amount), sum = sum(amount), n = n())


summarising changes to a larger unit of analysis


joining data (combine multiple data sets)
dplyr::bind_cols(df1, df2)
dplyr::bind_rows(df1, df2)
dplyr::setdiff, union, intersect

left_join(songs, artists, by = "name")
#order in left df is preserved
#if missing from right, value is NA

inner_join - if there is a row in the left that is not in the right, it's excluded. only includes
when the row appears in both data frames

semi_join - removes rows from the lhs df, when they do not appear in the rhs df
anti_join is the opposite, showing which rows would be dropped from the lhs df

data camp!!!
datacamp.com/tracks/rstudio-track

intro to data science with R


dim(hflights)

































