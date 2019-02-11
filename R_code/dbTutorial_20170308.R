### MFE Database Tutorial ###
# March 8, 2017

# Go into Box and open file that 'DatabaseManagementInstructions_UsingR20160216.docx' 
# that's follows file path Box > MFE > Database

# Read section starting on Page 4 "Using Database in R". Follow instructions

# Save the following files into your working directory:
# (1) MFEdb_20170202.db (MFE>Database>Current Database)
# (2) dbTableList.R (MFE>Database>R Code)
# (3) dbTable.R (MFE>Database>R Code)

setwd('/Users/solomonlab/Documents/database') #set working directory
#Will need to open up following two source file and change the following fields in the function: dbName, fPath
source('dbTableList.R') 
source('dbTable.R')
library(RSQLite)

# Look at the different tables in the database
dbTableList()

# Choose tables that will be sampled from
samples <- dbTable('SAMPLES')
sites <- dbTable('SITES')
fish_samples <-dbTable('FISH_SAMPLES')
fish_info <- dbTable ('FISH_INFO')
fish_diets <- dbTable ('FISH_DIETS')
chl <-dbTable("CHLOROPHYLL")
doc <-dbTable("DOC")

### Querying from one table
# Using JAZ dbTables script (function 'dbTable' found at bottom of script)
query1<- dbTable("DOC")
query1a<- dbTable('DOC',lakeID = 'EL')
query1b<- dbTable('DOC', lakeID = c('EL','WL'))
query1c<- dbTable('DOC', lakeID = c('EL','WL'), depthClass = "Surface")
# for querying by dates, min and max date must be in standard unambiguous format (i.e. YYYY-MM-DD HH:MM); if not, 
#   you can optionally pass the date format in what ever format you want
poc<-dbTable('poc',lakeID = c('EL','WL'),depthClass = 'PML',
             minDate = '2012-01-01 00:00',maxDate = '2012-07-21 00:00') # grab everything between min and max date
poc<-dbTable('poc',lakeID = c('EL','WL'),depthClass = 'PML',
             minDate = '2012-01-01 00:00') # grab everything later than min date 
poc<-dbTable('poc',lakeID = c('EL','WL'),depthClass = 'PML',
            maxDate = '2012-08-21 00:00') # grab everything earlier than max date
poc<-dbTable('poc',lakeID = c('EL','WL'),depthClass = 'PML',
             minDate = '01-12/01 00:00',maxDate = '08-12/01 00:00',dateFormat = '%m-%y/%d %H:%M') # grab everything between min and max date with different date format 


### Querying from two tables
a <- fish_samples # Change placeholders ('a','b') based on tables you're wishing to query
b <- fish_info
query2a <- merge(a, b,by="sampleID")
# identify the columns (i.e., fields) you want to subset for your query
query2b <- merge(a[,c('siteID','sampleID')], b[,c('sampleID','fishID','species','fishLength','fishWeight')],by="sampleID")

### Querying from three tables
# Query when each table is linked by a common relational identifier
a <- samples # Change placeholders ('a','b',c) based on tables you're wishing to query
b <- chl
c <- doc
query3a<-merge(merge(a[,c('sampleID','depthClass')], b[,c('sampleID','lakeID','siteName','chl')]),
               c[,c('sampleID','DOC')], by="sampleID")

#Query when relational identifers are not common between each table
a <- fish_samples # Change placeholders ('a','b',c) based on tables you're wishing to query
b <- fish_info
c <- fish_diets
query3b <- merge(merge(a[,c('siteID','sampleID')], b[,c('sampleID','fishID','species','fishLength'
                                                        ,'fishWeight')], by="sampleID"),c[,c('fishID','dietItem','dietItemCount')], by="fishID")

#subset data as desired
lmb <- query2b[query2b$species=="largemouth_bass",]

#sort data as desired
lmb_size<-lmb[order(lmb$fishLength),] #by one field
lmb_size_wt<-lmb[order(lmb$fishLength, lmb$fishWeight),] #by one field and then another

#average data by site
(lmb_sizeAvg <-tapply(lmb$fishLength,lmb$siteID,mean))
plot(lmb_sizeAvg)
(lmb_sizeAvgSort<-lmb_sizeAvg[order(lmb_sizeAvg$fishLength, lmb_sizeAvg$fishWeight),])

# Common problems with the current database setup
# data structure: Eve