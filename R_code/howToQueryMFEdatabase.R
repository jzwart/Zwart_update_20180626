# JAZ; 2015-11-30 
# examples of querying MFE database using a simple R function 'dbTable' 

# if you don't know the list of tables in the database, use 'dbTableList' to  give a list of the tables: 
dbTableList()

# load in entire data table; 
#  default fpath and dbname may need to be changed if different from function default 

doc<-dbTable(table = 'DOC') # queries entire DOC table; includes all lakes and sites 
boxplot(doc$DOC)

doc<-dbTable('DOC',lakeID = 'EL') # only queries DOC from lakeID = 'EL' ; includes all sites 
boxplot(doc$DOC)

doc<-dbTable('DOC',lakeID = c('EL','WL'),depthClass = c('PML','Hypo'))  # only queries DOC from EL and WL, at PML and Hypo depth classes 
boxplot(doc$DOC~doc$lakeID) # boxplot based on lake ID 

zoops<-dbTable('zoops_abund_biomass',lakeID = 'EL',depthClass = 'tow') # note that the table name does not have to be capitalized 
boxplot(zoops$abundance_num_m3~zoops$taxa)

# if you have a different file path than the default and a different dbName, then do the following: 
fpath<-file.path('/Users/Jake/Documents/Jake/Database/') # or wherever your database file is 
dbname<-'M2Mdb_041614.db'
doc<-dbTable('DOC',fpath = fpath,dbname = dbname)


