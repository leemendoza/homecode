########################################################################################
## WELLS.R
## Script used to select a random sample of Wells notices from those sent during a 
## specified time frame.  This file shows the code used to create the WELLS.RMD 
## markdown document. Remember, it's the code in the WELLS.RMD document that is 
## actually executed when you run the code below
## LMENDOZA
## 2015-01-26
########################################################################################

################################# RUN THIS CODE #################################
## create a name consisting of "Wells " + today's date
outname = paste("Wells ", as.character(Sys.Date()), sep = "")
setwd("C:/GitHub/HC")
knit2html("wells.Rmd", output = outname)






## include necessary libraries
require(XML)
require(plyr)

## change the working directory. Wells.Rmd needs to be in this folder
setwd("C:/GitHub/HC")
###############################################################
## start date of sample ------  MODIFY THIS!
beginDate = as.Date("2014-12-22")
## end date of sample --------  MODIFY THIS!
endDate = as.Date("2015-01-20")
###############################################################

## Wells Samples
### This document shows statistics of the adverse notices sent during the period between `r beginDate ` and `r endDate `.  A random sample of three percent of the letters sent for each program is selected and listed below.
#### Document created `r Sys.Date() `


    ### Notices per program, with sample size
    ### The sample size is determined by rounding up 3 percent of the number of letters sent in a program to the next highest integer

## this is the location of the Wells tracking data maintained by the regions
## and NFA
## external link
## URL = "https://dhhnet.dhh.louisiana.gov/departments/oaas/PO/_vti_bin/ListData.svc/WellsTracking"
## internal link
URL <- "http://dhhnet/departments/oaas/PO/_vti_bin/ListData.svc/WellsTracking"
dat = xmlParse(readLines(URL))

## get the individual list items
items = getNodeSet(dat, "//m:properties")

## convert to a data frame
df = xmlToDataFrame(items)

## clean up date data
df$DateLetterSent = as.Date(df$DateLetterSent)
df$Modified = as.Date(df$Modified)
df$Created = as.Date(df$Created)


## set the seed for the random number generator. This is important
## for reproducibility.  DO NOT MODIFY THIS VALUE.
set.seed(11223344)

## add a random number to each row. This random number will be used
## to order the items in the dataframe (resulting in random order), 
## and will be used to select random rows for each program
df$random = rnorm(nrow(df))
## sort the records in order of the random variable, in descending order
dfRandom = df[order(-df$random),]

## filter the sample by dates. This will select all columns for rows with the 
## DateLetterSent having a value between the beginDate and endDate (inclusive)
dateFiltered = dfRandom[which(dfRandom$DateLetterSent >= beginDate & dfRandom$DateLetterSent <= endDate), ]

## summary of letters sent per program
perProgram = ddply(dateFiltered, ~ProgramValue, summarise, letterCount = length(ProgramValue))

## determine the number of samples as 3% of the list, rounded up
perProgram$threePercent = perProgram$letterCount * 0.03
perProgram$sampleSize = as.integer(perProgram$threePercent) + 1

## create and clear a dataset for the samples
sample = NULL

## output
## kable(perProgram)


### The sample:
for (i in 1:nrow(perProgram)){
    ## programLetters = filter by program
    programLetters = dateFiltered[which(dateFiltered$ProgramValue == perProgram[i, "ProgramValue"]),]
    programSample = programLetters[1:perProgram[i, "sampleSize"],]
    sample = rbind(sample, data.frame(cbind(as.character(programSample$ClientLastName), 
                                            as.character(programSample$ClientFirstName), 
                                            as.character(programSample$SSN), 
                                            as.character(programSample$ProgramValue), 
                                            as.character(programSample$DateLetterSent))))
    
}
names(sample) = c("Last Name", "First Name", "SSN", "Program", "Date Letter Sent")
###kable(sample)


