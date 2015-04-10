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
<<<<<<< HEAD
endDate = as.character(Sys.Date() + 60)


## connection to OPTS 
connOPTS < - odbcDriverConnect("Driver=SQL Server; Server=BHSF-BTR-W359; Database=ParticipantServices; Uid=dbuOPTSReadOnly; Pwd=dbuoptsro;")
## get the expiring PASARRs
sqlStr = paste("SELECT t_Person.perID AS 'OPTS ID', REPLACE(t_Person.SSN, '-', '') AS 'SSN', t_Person.nameLast + ', ' + t_Person.nameFirst AS 'Client', a.medicalEndDate AS 'Date Expiring', NFTypes.eligibilityType AS 'Type' FROM t_PASARR a INNER JOIN t_NursingFacilityEligibilityTypes NFTypes ON a.medicalEligibilityTypeID = NFTypes.eligibilityTypeID INNER JOIN t_Person ON a.personID = t_Person.perID WHERE NFTypes.eligibilityType = 'Hospital Exemption' AND a.medicalEndDate >= ", beginDate, " AND a.medicalEndDate < ", endDate, " ORDER BY a.medicalEndDate")
optsResult <- sqlQuery(connOPTS, sqlStr)
=======
endDate = as.character(Sys.Date())


## connection to OPTS 
connOPTS < - odbcDriverConnect("Driver=SQL Server; Server=xxx.xx.xxx.xx; Database=test_DB; Uid=my_ID; Pwd=my_PWD;")
## get the expiring PASARRs
optsResult <- sqlQuery(conn, "SELECT * FROM TableName")
>>>>>>> origin/master
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

