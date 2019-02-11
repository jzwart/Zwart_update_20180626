### MFE Sensor Database Tutorial ### modified from dbTutorial_20170308.R 
# JAZ; 2017-09-07 

# Go into Box and follow file path Box > MFE > Database

# Save the following files into your working directory:
# (1) MFEsensordb_.db (MFE>Database>Current Sensor Database)
# (2) sensordbTable.R (MFE>Database>R Code)

source('/Users/Jake/Desktop/R functions/sensordbTable.R') # holds functions for parsing sensor DB 

sensordbTableList() # lists sensor DB tables 

### There is a lot of data so make sure you are parsing data tables as R  #####
######    will be slow if reading in huge amounts of data                #######

# examples of parsing tables 
d=sensordbTable(table = 'hobo_tchain_corr',lakeID = 'EL') # all temp chain data from EL (quite a lot of data by itself)

d=sensordbTable(table = 'hobo_tchain_corr',lakeID = 'EL',
                minDate = '2011-01-01 00:00',maxDate = '2012-01-01 00:00') # parsing by date and lake 

d=sensordbTable(table = 'hobo_tchain_corr',lakeID = 'EL',minDepth_m = 0, maxDepth_m = 2,
                minDate = '2014-01-01 00:00',maxDate = '2015-01-01 00:00') # parsing by date / lake / depth 

unique(d$depth_m) 

d=sensordbTable(table = 'hobo_tchain_corr',lakeID = 'EL',maxDepth_m = .5,
                minDate = '2014-01-01 00:00',maxDate = '2015-01-01 00:00') # parsing by date / lake / depth 

unique(d$depth_m)

d=sensordbTable(table = 'do_corr',lakeID = c('MO','HB'),minDate = '2014-01-01 00:00')


