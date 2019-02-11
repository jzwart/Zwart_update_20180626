  ###*** Relational database integrity test - Sites/Samples and extra tables ***###
# January 2016 - Alex Ross

library(dplyr)

rm(list=ls())  #clear variables
setwd('/Users/ksaunde1/Documents/Current Database')#set wd to where .db file is
#setwd('/Users/Jake/Documents/Jake/Database/Test/' ) # JAZ dir 
# **Load 'dbTable' and 'dbTableList' functions (found at bottom of script)
#source("C:/Users/ksaunde1/Documents/Current Database/dbTable.R")
#source("C:/Users/ksaunde1/Documents/Current Database/dbTableList.R")

###***Important to go in order: Lake, Site, Sample, other tables.

###---###---### SITE TABLE UPDATE ###---###---###
# Step 1: Load existing 'SITES' table, and read in the 'SITES' portion of new data that's being pulled in (use Excel Template)
#site <-dbTable('SITES') # existing site data
site<- read.table("SITES.txt",header = FALSE,sep = '|',col.names = c("siteID","lakeID","siteName","lat","long","UTM","updateID")) #reads in most recent text file of SITES table
site_N <- read.csv("siteChlorophyll_2014to2016_20170519.csv", header=TRUE) # new data that is to be added to existing

# Step 2: Identify unique siteIDs that are not in current database
site_names <- unique(site$siteID) # unique site names from existing data
site_N_unique <- site_N[!site_N$siteID %in% site_names,] # ADD; New siteIDs that need to be added to SITES table
site_N_nonUnique <- site_N[site_N$siteID %in% site_names,] # DON'T ADD; siteIDs that are already in the SITES table (do a quick calculation on the dims of each table to make sure things lineup )

# Step 3: Copy new siteIDs to existing siteIDs and check one last time for duplicates
site_current<- rbind(site,unique(site_N_unique)) #combine data sets. If header names are different (typo/wrong table) this will not work
#Check dims again to make sure proper number of rows are in new table (original siteIDs + new unique IDs)
site_current[duplicated(site_current$siteID),] # Last duplicate check (no rows=no duplicates)

# SKIP Step 4: Additional check to make sure lakeID is in the lakes Table: copied from JAZ
lakes <- dbTable('lakes')
#lakes_n<- read.table("LAKES.txt",header = F,sep = '|',col.names = c("lakeID","lakeName","state","county","city","surfaceArea","maxDepth","lat","long","UTM","comments","updateID"))
lake_names<-unique(site_current$lakeID) #all unique lakeIDs are listed in sites table 
if(length(lake_names[!lake_names%in%lakes$lakeID])>0){ # checks if there are lakeIDs from the sites table not in the lakes table 
  print('Lakes listed in site table not in lakes table:') # if there are sites that need to be added or typos that need to be fixed do that first before writing new table
  lake_names[!lake_names%in%lakes$lakeID]
}else{
  print('All good') # proceed with writing new samples table 
}

# Step 5: Additional check to make sure updateID is in the UPDATE_METADATA Table
updates <- dbTable('update_metadata')
update_names<-unique(site_current$updateID)  
if(length(update_names[!update_names%in%updates$updateID])>0){ 
  print('updateID listed in site table not in update_metadata table:')
  update_names[!update_names%in%updates$updateID]
}else{
  print('All good') # proceed with writing new samples table 
}

# Step 5b: If mistakes are found write a csv of site_current; make fixes; bring back to R
write.csv(site_current, file="site_current_fix.csv", row.names=F)
site_current <- read.csv("site_current_fix.csv")

#Step 6: Update the "UPDATE_METADATA" csv in excel, bring it in to R to re-write your UPDATE_METADATA table
update_N <- read.csv("UPDATE_METADATA.csv", header = FALSE)


# Step 7: Overwrite new SITES table to database folder (using the same name as before)

outDir<-'/Users/ksaunde1/Documents/Current Database' #Will be unique for each user
#outDir<-'/Users/Jake/Documents/Jake/Database/Test/' 
#Sites Table
write.table(site_current,file.path(outDir,paste('SITES','.txt',sep='')),quote = F,sep = '|',row.names=F,
            col.names=F) # should be the same format that Access creates 
#Update Metadata Table
write.table(update_N,file.path(outDir,paste('UPDATE_METADATA','.txt',sep='')),quote = F,sep = '|',row.names=F,
            col.names=F)

###---###---### SAMPLE TABLE UPDATE ###---###---###
#sample <- dbTable('samples')   
sample<- read.table("SAMPLES.txt",header = FALSE,sep = '|') #reads in most recent text file of SAMPLES table
colnames(sample) <-c("siteID","sampleID","dateSample","dateTimeSample","depthClass","depthTop","depthBottom","crew","weather","comments","metadataID","updateID") 
sample_N <- read.csv("samplesPOC_20170529.csv", header=TRUE)

sample_names <- unique(sample$sampleID) # unique sample names from new data
sample_N_unique <- sample_N[!sample_N$sampleID %in% sample_names,] # ADD; New sampleIDs that need to be added to sampleS table
sample_N_nonUnique <- sample_N[sample_N$sampleID %in% sample_names,] # DON'T ADD; sampleIDs that are already in the sampleS table (do a quick calculation on the dims of each table to make sure things lineup )

sample$dateTimeSample = as.numeric(sample$dateTimeSample)

sample_current<- rbind(sample,unique(sample_N_unique)) #combine data sets. If header names are different (typo/wrong table) this will not work

sample_current[duplicated(sample_current$sampleID),] # Last duplicate check (no rows=no duplicates)

# additional check to make sure siteID is in the new sites table. JAZ
sample_sites<-unique(sample_current$siteID) #all unique sites listed in samples table 
if(length(sample_sites[!sample_sites%in%site_current$siteID])>0){ # checks if there are site names from the sample table not in the site names 
  print('Sites listed in sample table not in site table:') # if there are sites that need to be added, add those first. If there are mispellings in the samples table, fix them before writing new table 
  sample_sites[!sample_sites%in%site_current$siteID]
}else{
  print('All good') # proceed with writing new samples table 
}
#If changes need to be made, write csv --> fix, bring back into R
write.csv (sample_current, file= "sample_current_fix.csv", row.names=F) 
sample_current <- read.csv("sample_current_fix.csv", head=T) #Run through checks again

outDir<-'/Users/ksaunde1/Documents/Current Database' #Will be unique for each user
#outDir<-'/Users/Jake/Documents/Jake/Database/Test/' 
write.table(sample_current,file.path(outDir,paste('SAMPLES','.txt',sep='')),quote = F,sep = '|',row.names=F,
            col.names=F) # should be the same format that Access creates 

#Update Metadata Table
updates <- dbTable('update_metadata')
update_names<-unique(sample_current$updateID)  
if(length(update_names[!update_names%in%updates$updateID])>0){ 
  print('updateIDs listed in samples table not in update_metadata table:')
  update_names[!update_names%in%updates$updateID]
}else{
  print('All good') # proceed with writing new samples table 
}

#Update the "UPDATE_METADATA" csv in excel, bring it in to R to re-write your UPDATE_METADATA table
update_N <- read.csv("UPDATE_METADATA.csv")

outDir<-'/Users/ksaunde1/Documents/Current Database' #Will be unique for each user
write.table(update_N,file.path(outDir,paste('UPDATE_METADATA','.txt',sep='')),quote = F,sep = '|',row.names=F,
            col.names=F)

# ***If you need to replace sampleIDs from a whole table (including those IDs that currently in existing DB), use script 'replaceWholeDBtable.R'

###---###---### REMAINING TABLE UPDATES ###---###---###
tab <- dbTable('Chlorophyll') #Choose table you're looking to update
#tab<- read.table("CHLOROPHYLL.txt",header = FALSE,sep = '|' ) #reads in most recent text file of table you're looking to update
tab_N <- read.csv ('tableChlorophyll_2014to2016_20170519.csv', header=TRUE) # Pull in new table (make sure that csv is saved in working directory folder)
tab_current <- rbind(tab, tab_N)
# ****QUICK CHECKS FOR TYPOS/ERRORS -- 
(depth_check<- tab_N[!(tab_N$depthClass %in% tab$depthClass), ]) #Check depthClass spelling; fix if need be


(siteName_check <- head(tab_N[!(tab_N$siteName %in% tab$siteName), ])) #Check spelling; new siteNames may come up if a new site was just added
  
(depthOrder_check <- tab_current[(tab_current$depthTop > tab_current$depthBottom),])

#If errors update csv with proper information, bring back.****
write.csv(tab_current, file="tableChlorophyll2014to2016_fix.csv", row.names=F)
tab_current <- read.csv("tableChlorophyll2014to2016_fix.csv", header = TRUE)


# For DOC table sampleIDs should be repeated twice (each sample, n=2 replicates) 
# Check if there are any sampleIDs occuring >2
#(check <- as.data.frame(tab_current %>% count(sampleID) %>% filter(n > 2))) #this is from dplyr
# Problem with above, not in dataframe format so don't know exact rows where info copied. Can go back
# into excel to 'Find' where samples are duplicated, remove them and then bring the csv back into R.

# JAZ: could just concatinate sampleID and replicate number to new sampleID and check for duplicates 
# Make sure to change suffix for 'merged' to a value that's in current table 
if('replicate' %in% colnames(tab_current)){ #checks if there are replicated samples for the given sample table (should be true for DOC, GC data, and some others )
    tab_current$sampleID2<-paste(tab_current$sampleID,tab_current$replicate,sep='_')
    if(length(tab_current[duplicated(tab_current$sampleID2),1])>0){
      # print duplicated sampleIDs 
      duplicated<-tab_current[duplicated(tab_current$sampleID2),]
      existing<-tab_current[duplicated(tab_current$sampleID2,fromLast = T),]
      # duplicated samples could be that the replicate number was entered incorrectly (i.e. two replicate 1's when they really meant 1 and 2)
      merged<-merge(existing,duplicated,by='sampleID2')
      if(length(merged$sampleID2[merged$chl.x!=merged$chl.y])>0){
        print('WARNING: duplicated sampleIDs do not have same sample value')
        merged[merged$chl.x!=merged$chl.y,] # prints which values are different from each other =>  need to fix these (i.e. they're not data repeats, just their replicate number or sampleID is repeated )  
      }else{
        tab_current<-tab_current[!duplicated(tab_current$sampleID2),] # gets rid of duplicated samples if all samples had the same value 
        tab_current<-tab_current[,!colnames(tab_current) %in% c('sampleID2')] # gets rid of second sample id column that we created
      }
    }else{
      print('No duplicated sampleIDs')
      tab_current<-tab_current[,!colnames(tab_current) %in% c('sampleID2')] # gets rid of second sample id column that we created
    }
  }else{ #if table does not have replicate number, then check for duplicates based on sampleID 
    if(length(tab_current[duplicated(tab_current$sampleID),1])>0){
      # print duplicated sampleIDs 
      duplicated<-tab_current[duplicated(tab_current$sampleID),]
      existing<-tab_current[duplicated(tab_current$sampleID,fromLast = T),]
      # duplicated samples could be that the replicate number was entered incorrectly (i.e. two replicate 1's when they really meant 1 and 2)
      merged<-merge(existing,duplicated,by='sampleID')
      if(length(merged$sampleID[merged$chl.x!=merged$chl.y])>0){
        print('WARNING: duplicated sampleIDs do not have same sample value')
        merged[merged$chl.x!=merged$chl.y,] # prints which values are different from each other =>  need to fix these (i.e. they're not data repeats, just their replicate number or sampleID is repeated )  
      }else{
        tab_current<-tab_current[!duplicated(tab_current$sampleID),] # gets rid of duplicated samples if all samples had the same value 
      }
      
    }else{
      print('No duplicated sampleIDs')
    }
  }

#If duplicate issues write csv, make necessary adjustments and then bring back in
write.csv(tab_current, file="tab_current_fix.csv", row.names = F)
#Fix issues, bring back in and run ifelse function once more to make sure duplicates are taken care of
tab_current <- read.csv("tab_current_fix.csv")



#Check to make sure that other ID keys are in associated parent tables
# SampleID check
tab_sample<-unique(tab_current$sampleID) #all unique sampleIDs listed in table 
if(length(tab_sample[!tab_sample%in%sample_current$sampleID])>0){ # checks if tab table sampleIDs are in SAMPLES table
  print('SampleID listed in "tab" table not in SAMPLES table:') # if there are sites that need to be added, add those first. If there are mispellings in the tab table, fix them before writing new table 
  tab_sample[!tab_sample%in%sample_current$sampleID]
}else{
  print('All good') # proceed with writing new tab table 
}
#lakeID
tab_lake<-unique(tab_current$lakeID) #all unique lakeIDs listed in  table 
if(length(tab_lake[!tab_lake%in%lakes$lakeID])>0){ 
  print('lakeID listed in "tab" table not in LAKES table:') 
  tab_lake[!tab_lake%in%lakes$lakeID]
}else{
  print('All good') # proceed with writing new tab table 
}
#projectID
projects<- dbTable("projects")
tab_project<-unique(tab_current$projectID) #all unique project IDs in table 
if(length(tab_project[!tab_project%in%projects$projectID])>0){
  print('projectID listed in "tab" table not in PROJECTS table:') 
  tab_project[!tab_project%in%projects$projectID]
}else{
  print('All good') # proceed with writing new tab table 
}
#updateID
tab_update<-unique(tab_current$updateID) #all unique updateIDs listed in current table 
if(length(tab_update[!tab_update%in%updates$updateID])>0){
  print('updateID listed in "tab" table not in UPDATE_METADATA table:') 
  tab_update[!tab_update%in%updates$updateID]
}else{
  print('All good') # proceed with writing new tab table 
}

#metadataID
metadata<- dbTable("metadata")
tab_metadata<-unique(tab_current$metadataID) #all unique metadataIDs listed in current table 
if(length(tab_metadata[!tab_metadata%in%metadata$metadataID])>0){
  print('metadataID listed in "tab" table not in METADATA table:') 
  tab_metadata[!tab_metadata%in%metadata$metadataID]
}else{
  print('All good') # proceed with writing new tab table 
}



outDir<-'/Users/ksaunde1/Documents/Current Database' #Will be unique for each user
write.table(tab_current,file.path(outDir,paste('Chlorophyll','.txt',sep='')),quote = F,sep = '|',row.names=F,
            col.names=F) # Make sure to name file appropriately. If you don't change filename the wrong files will
                    # be overwritten

#Update the "UPDATE_METADATA" csv in excel, bring it in to R to re-write your UPDATE_METADATA table
update_N <- read.csv("UPDATE_METADATA.csv")

outDir<-'/Users/ksaunde1/Documents/Current Database' #Will be unique for each user
write.table(update_N,file.path(outDir,paste('UPDATE_METADATA','.txt',sep='')),quote = F,sep = '|',row.names=F,
            col.names=F)



###****** ASIDE ******###
###---###---### OTU RELATION TABLE UPDATE ###---###---###
# Any table that uses an otu (i.e., zoop abund, zoop length, benthic inverts, etc.)
# Check to make sure spelling is right; taxa is in OTU table
otu <- dbTable('OTU')
otu_N <- read.csv("tableOTU.20160224.csv", head=T)

otu_check <- read.csv("tableFISH_INFO2016.20170202.csv") # Table with OTU; otu code in this table(zoop lengths) is "taxa"

(name_check<- otu_check[!(otu_check$taxa %in% otu$otu), ]) 

outDir<-'/Users/alexross/Documents/McGill/Database/Data/MFE/Current' #Will be unique for each user
write.table(otu,file.path(outDir,paste('OTU','.txt',sep='')),quote = F,sep = '|',row.names=F,
            col.names=F)

#If incoming taxa data are not found in OTU a df will be populated with incompatable results
# This also includes mystery "spaces" at the end or beginning of taxa names (i.e., 
# "cyclopoid "; the third observation in populated dataset)
# If no errors, should be a df with zero observations

###---###---### METADATA TABLE UPDATE ###---###---###
meta <- dbTable('METADATA')
meta_check <- read.csv("tablePOC2016_20170424.csv")

(meta_check <- meta_check[!(meta_check$metadataID %in% meta$metadataID), ])
# Same as above -- no errors in metadataID will produce a df with 0 observations. If a metadataID is incorrectly
# entered or not entered at all the df will be populated with that row
###****** ASIDE OVER ******###

#*******************************************************************************************************#
### Updating metadata
write.csv(meta, file="metadata_fix.csv") # open csv, make updates/changes, bring back to R to write txt file

metadata_current <- read.csv("metadata_fix.csv")
write.table(metadata_current,file.path(outDir,paste('METADATA','.txt',sep='')),quote = F,sep = '|',row.names=F,
            col.names=F)

#*******************************************************************************************************#
### How to write a new table to be used in existing database

# In Excel, set up a spreadsheet w/ proper header, IDs, data, etc., bring this into R
updateMetadata <- read.csv("UPDATE_METADATA.csv") #writing the 'UPDATE_METADATA' table
# Now, write a text file into the same folder where other text files for the DB are located
outDir<-'/Users/alexross/Documents/McGill/Database/Data/MFE/Current' 
write.table(updateMetadata,file.path(outDir,paste('UPDATE_METADATA','.txt',sep='')),quote = F,sep = '|',row.names=F,
            col.names=F)



###*********************************************************************************###
###                      HOW TO WRITE NEW DB AFTER UPDATES                          ###
###*********************************************************************************###
# To write a new .db file that contains updated data (new and/or updated tables), 
# the next step involves SQLite. If any changes made to table headers, make sure the SQL script (text file) 
# code is up-to-date. This is especially true if you created a brand new data table. Run the 
# updated .sql script through Terminal (Mac) or Command Line (Windows), and voila! New DB object.
# Can then bring new DB back into R to query from
###*********************************************************************************###
###*********************************************************************************###

### With new database written load it back in and make sure that additions have been properly made
setwd('/Users/ksaunde1/Documents/Current Database')
dbTableList() # Make sure that dbname is changed in this function (and in dbTable)
NEW_site <- dbTable("SITES") #Contains proper dim for updated data. Lookinh in table, only additions that 
#were supposed to be made were
NEW_sample <- dbTable("SAMPLES") #Contains proper dim for updated data
NEW_tab <- dbTable("POC")






###---###---### Necessary Functions for Script ###---###---###
#Set working directory for where all text files are found
current <- file.path('/Users/ksaunde1/Documents/Current Database')

dbTable<-function(table,fpath=current,dbname='MFEdb_20170428.db',lakeID=c(),depthClass=c()){
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

dbTableList<-function(fpath=current,dbname='MFEdb_20170428.db'){
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

