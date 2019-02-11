###---###---### SAMPLE TABLE UPDATE ###---###---###

#***Only use this script if you need to remove all IDs from the existing database (for a given table) and upload a whole fresh set of sampleIDs
# The only reason this is likely to come up is if mistakes were made in the existing database that weren't corrected

sample <- dbTable('SAMPLES')    
sample_N <- read.csv("samplesBENTHIC_INVERTS.20160222.csv", header=TRUE)

# Pull out sampleIDs from BENTHIC_INVERTS that are currently in the SAMPLES table
ben_names <- unique(ben$sampleID)

# Remove sample IDs from existing SAMPLES table that match 'ben_names'
sample_exist <- sample[!sample$sampleID %in% ben_names,]
# sample (n=15197 obs.), sample_exist (n=14495 obs.). Therefore, 702 obs removed, and ben_names had 702 sampleIDs. 
# sample_exist is all sample IDs EXCEPT for those from BENTHIC_INVERTS
# can now add Nikkis update

sample_names <- unique(sample_exist$sampleID) # unique sample names from new data
sample_N_unique <- unique(sample_N[!sample_N$sampleID %in% sample_names,]) # ONLY USE IF OVERWRITING EXISITNG TABLES. **ADD; New sampleIDs that need to be added to sampleS table
sample_N_nonUnique <- sample_N[sample_N$sampleID %in% sample_names,] # DON'T ADD; sampleIDs that are already in the sampleS table (do a quick calculation on the dims of each table to make sure things lineup )

sample_current<- rbind(sample_exist,sample_N_unique) #combine data sets. If header names are different (typo/wrong table) this will not work

sample_current[duplicated(sample_current$sampleID),] # Last duplicate check (no rows=no duplicates)

# additional check to make sure siteID is in the new sites table. JAZ
sample_sites<-unique(sample_current$siteID) #all unique sites listed in samples table 
if(length(sample_sites[!sample_sites%in%site_current$siteID])>0){ # checks if there are site names from the sample table not in the site names 
  print('Sites listed in sample table not in site table:') # if there are sites that need to be added, add those first. If there are mispellings in the samples table, fix them before writing new table 
  sample_sites[!sample_sites%in%site_current$siteID]
}else{
  print('All good') # proceed with writing new samples table 
}
#write.csv (sample_current, file= "sample_current_fix.csv") #If changes need to be made, write csv --> fix, bring back into R
sample_current <- read.csv("sample_current_fix.csv", head=T) #Run through checks again

outDir<-'/Users/alexross/Documents/McGill/Database/Data/MFE/Current' #Will be unique for each user
#outDir<-'/Users/Jake/Documents/Jake/Database/Test/' 
write.table(sample_current,file.path(outDir,paste('SAMPLES','.txt',sep='')),quote = F,sep = '|',row.names=F,
            col.names=F) # should be the same format that Access creates 


#UPDATE_METADATA Table check
updates <- dbTable('update_metadata')
update_names<-unique(site_current$updateID)  
if(length(update_names[!update_names%in%updates$updateID])>0){ 
  print('Lakes listed in site table not in lakes table:')
  update_names[!update_names%in%updates$updateID]
}else{
  print('All good') # proceed with writing new samples table 
}

#Update the "UPDATE_METADATA" csv in excel, bring it in to R to re-write your UPDATE_METADATA table
update_N <- read.csv("UPDATE_METADATA.csv")

outDir<-'/Users/alexross/Documents/McGill/Database/Data/MFE/Current' #Will be unique for each user
write.table(update_N,file.path(outDir,paste('UPDATE_METADATA','.txt',sep='')),quote = F,sep = '|',row.names=F,
            col.names=F)