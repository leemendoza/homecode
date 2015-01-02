####################################################################
## Expiring PASARRs
##
##
####################################################################

## useful info
## Sys.Date() will return today as YYYY-MM-DD
##
## database connection library
if(!require(RODBC)){install.packages("RODBC")}
library(RODBC)
## microsoft Excel library
if(!require(xlsReadWrite)){install.packages("WriteXLS")}
library(WriteXLS)
## data table library
if(!require(data.table)){install.packages("data.table")}

## dates for the sql statement - change as needed
beginDate = as.character(Sys.Date())
endDate = as.character(Sys.Date())


## connection to OPTS 
connOPTS < - odbcDriverConnect("Driver=SQL Server; Server=xxx.xx.xxx.xx; Database=test_DB; Uid=my_ID; Pwd=my_PWD;")
## get the expiring PASARRs
optsResult <- sqlQuery(conn, "SELECT * FROM TableName")
odbcClose(connOPTS)
dim(optsResult)

## connection to MDS 
connMDS < - odbcDriverConnect("Driver=SQL Server; Server=xxx.xx.xxx.xx; Database=test_DB; Uid=my_ID; Pwd=my_PWD;")
## get the expiring PASARRs
mdsResult <- sqlQuery(conn, "SELECT * FROM TableName")
odbcClose(connMDS)
dim(mdsResult)



dtOPTS<-data.table(connOPTS,  key="SSN") 
dtMDS<-data.table(connMDS, key="SSN")

dtPASARR<-dtOPTS[dtMDS]

