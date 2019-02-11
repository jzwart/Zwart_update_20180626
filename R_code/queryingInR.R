### Querying data from one, or multiple tables ###

#Load database, look at tables
dbTableList() #fucntion found at bottom of script

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

#Plot
#...

#etc., etc.

###---###---###---###---###---###---###---###---###---###---
###---###---###---###--- Functions ###---###---###---###---
###---###---###---###---###---###---###---###---###---###---

#Change 'dbLocation' to your local file.path to where your .db exists
dbLocation <-file.path('/Users/alexross/Documents/McGill/Database/Data/MFE/temp')

dbTableList<-function(fpath=dbLocation,dbname='MFEdb_20170202.db'){
  #set file path to the location of the database (defaults to Alex's database location - update this
  #so that it will automate to whatever computer a user is at)
  library(RSQLite)
  drv=SQLite() #create driver object
  con=dbConnect(drv,dbname=file.path(fpath,dbname)) #open database connection    
  #list tables in database
  tables=dbListTables(con) 
  return(tables)
}

dbTableList() # function defaults to querying the whole database for table



dbTable<-function(table,fpath=dbLocation,dbname='MFEdb_20170202.db',lakeID=c(),depthClass=c()){
  #set file path to the location of the database (defaults to my database location)
  table=as.character(table)
  library(RSQLite)
  drv=SQLite() #create driver object
  con=dbConnect(drv,dbname=file.path(fpath,dbname)) #open database connection
  #query an entire table
  table<-dbGetQuery(con,paste("SELECT * FROM", table)) #note that capitalization doesn't matter so LAKES=lakes
  if(!is.null(lakeID)){
    table<-table[table$lakeID%in%lakeID,]
  }
  if(!is.null(depthClass)){
    table<-table[table$depthClass%in%depthClass,]
  }
  return(table)
}


