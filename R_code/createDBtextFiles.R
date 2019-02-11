

tables<-dbTableList()

outDir<-'/Users/Jake/Documents/Jake/Database/Temp/'

for(i in 1:length(tables)){ # loop through tables and write to text files 
  cur<-dbTable(tables[i])
  write.table(cur,file.path(outDir,paste(tables[i],'.txt',sep='')),quote = F,sep = '|',row.names=F,
              col.names=F) # should be the same format that Access creates 
  
}

