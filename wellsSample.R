
# 1) How would I know, from looking at the MDS-HC, that a person was denied?
# 2) Can see adls and RUG categories on each MDS-HC, and can calculate the budget 
#     for each MDS-HC based on the RUG. This doesn't tell me about the actual 
#     amount of services. For a particular budget cap, services may have been decreased from
#     one year to the next. In cases where the budget WAS decreased due to a different RUG
#     category, actual services could have remained the same from year to year.
#     


library(RODBC)
library(data.table)
library(xlsx)
library(plyr)
library(lubridate)

itWasADenial = function (ID){
    
    ## get connection
    telesyshandle <- odbcDriverConnect('driver={SQL Server};server=BHSF-BTR-W324; database=TSData; Uid=mdshcuser; Pwd=test;')
    ## get data set
    system.time(mdshcs <- sqlQuery(telesyshandle, mdshcSearchStr))
    
    ## close the database connection
    close(telesyshandle)
    ## close connection
}

startReportPeriod = as.Date("2014-09-01")
endReportPeriod = startReportPeriod
month(endReportPeriod) = month(endReportPeriod) + 1 ## plus one month

## get all waiver clients from clink that have not been closed
waiverSearchStr = "SELECT [PROGRAM], [LNAME], [FNAME], [MI], [SSN], [DOB] FROM [KPoche].[SAS_CLINKClients] WHERE [TERMDATE] IS NULL"

## get connection
clinkhandle <- odbcDriverConnect('driver={SQL Server};server=BHSF-BTR-W324; database=SRI_OAAS; Uid=dbuSRI_OAAS; Pwd=dbusrioaas;')
## get data set
system.time(waivers <- sqlQuery(clinkhandle, waiverSearchStr))

## close the database connection
close(clinkhandle)

## separate ADHC and CCW
adhc = waivers[which(waivers$PROGRAM == "ADHC"),]
ccw = waivers[which(waivers$PROGRAM == "OAASCCW"),]

## get all MDSHCs for all clients for the past 3 years, ordered by SSN, then assessment date DESC
mdshcSearchStr = paste("SELECT [ADL]
,[RUG]
,[BUDGET] = 
    CASE
WHEN [RUG] = 1.21 THEN 32904
WHEN [RUG] = 1.12 THEN 27429
WHEN [RUG] = 1.11 THEN 27429
WHEN [RUG] = 2.13 THEN 39445
WHEN [RUG] = 2.12 THEN 35277
WHEN [RUG] = 2.11 THEN 35277
WHEN [RUG] = 3.12 THEN 35277
WHEN [RUG] = 3.11 THEN 32904
WHEN [RUG] = 4.31 THEN 32904
WHEN [RUG] = 4.21 THEN 27429
WHEN [RUG] = 4.12 THEN 20011
WHEN [RUG] = 4.11 THEN 20011
WHEN [RUG] = 5.21 THEN 27429
WHEN [RUG] = 5.12 THEN 20011
WHEN [RUG] = 5.11 THEN 12811
WHEN [RUG] = 6.21 THEN 27429
WHEN [RUG] = 6.12 THEN 20011
WHEN [RUG] = 6.11 THEN 12811
WHEN [RUG] = 7.41 THEN 32904
WHEN [RUG] = 7.31 THEN 27429
WHEN [RUG] = 7.21 THEN 22916
WHEN [RUG] = 7.12 THEN 19237
WHEN [RUG] = 7.11 THEN 10244
ELSE 0
END
,[A_1]	AS [ARD]
,[A_2] AS [INIT]
,[AA_1_a] AS [FNAME]
,[AA_1_b] AS [LNAME]
,[AA_1_c] AS [MI]
,[AA_3_a] AS [SSN]
FROM [TSData].[dbo].[IR_MDSHC_A]
WHERE Deleted = 0
AND RUG IS NOT NULL
AND [A_1] >= DATEADD(year, -3, GETDATE()) AND [AA_3_a] IS NOT NULL
AND [AA_3_a] != \'\'
ORDER BY [AA_3_a], [A_1] DESC", sep = "")

## get connection
telesyshandle <- odbcDriverConnect('driver={SQL Server};server=BHSF-BTR-W324; database=TSData; Uid=mdshcuser; Pwd=test;')
## get data set
system.time(mdshcs <- sqlQuery(telesyshandle, mdshcSearchStr))

## close the database connection
close(telesyshandle)
## close connection


## for each CCW client
for(i in 1:nrow(ccw))
    ##for(i in 1:10)
{
    ## subset the MDSs by CCW client SSN
    mdsSet = subset(mdshcs, SSN == ccw[i, "SSN"])
    
    ## if the most recent MDSHC falls within the reporting period
    if (mdsSet[1, "ARD"] >= startRepPeriod && mdsSet[1, "ARD"] <= endRepPeriod) {
        ## if the most recent was a denial, add to list
        
        ## figure out how to determine if a denial
        ## get the notebook and look for LOC not met etc
        
        ## could it be a decrease?  We'll need at least 2 to know for sure
        
        
    }
    
}
## subset the MDSHCs
## if the most recent MDSHC falls within the reporting period
## if the most recent was a denial, add to list

## else get most recent MDSHC and compare to previous

## if previous RUG had a higher allocation, add to list

## next client

## get sample of resulting rows
## round up
## sampCount = ceiling(nrow(df) * 0.03)

## df[sample(nrow(df), sampCount), ]
## save list
