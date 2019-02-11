# moving dic_ch4 data and pco2 data to GC table in database
# JAZ, 2017-01-30 

gc<-dbTable('GC')
dic_ch4<-dbTable('dic_ch4')
pco2<-dbTable('pco2')
units<-dbTable('units')

# since we do not have the original standard curves readily available, we are leaving blank several columns in the GC 
# table when converting over pco2 and dic/ch4 tables  

pco2GC<-pco2 # creating pco2 converted GC table 
dic_ch4GC<-dic_ch4 # creatign dic_ch4 converted GC table 

colnames(dic_ch4GC)[grep('DIC',colnames(dic_ch4GC))]='CO2_uM' # changing name of DIC column to CO2_uM
colnames(dic_ch4GC)[grep('CH4',colnames(dic_ch4GC))]='CH4_uM' # changing name of CH4 column to CH4_uM
colnames(dic_ch4GC)[grep('GC_runName',colnames(dic_ch4GC))]='runName'

# creating columns that don't exist in dic_ch4 table 
dic_ch4GC$subsampleClass<-NA
dic_ch4GC$subsampleDateTime<-NA
dic_ch4GC$runDate<-NA
dic_ch4GC$replicate<-1 # looks like there was only one replicate per sample 
dic_ch4GC$CH4PeakArea<-NA
dic_ch4GC$CO2PeakArea<-NA
dic_ch4GC$CH4ppm<-NA
dic_ch4GC$CO2ppm<-NA
dic_ch4GC$runID<-NA

# order the colnames in the same order as the GC table 
colnames(gc)[!colnames(gc)%in%colnames(dic_ch4GC)] #making sure we aren't missing any columns in the GC table 

dic_ch4GC<-dic_ch4GC[colnames(gc)] # reordering columns according to gc table 
dic_ch4GC$sampleID<-dic_ch4$sampleID # adding back sample ID 
dic_ch4GC$flag<-dic_ch4$flag # adding back flag column 

write.table(dic_ch4GC,'/Users/Jake/Documents/Jake/Database/Database files/dic_ch4_convertedToGCtable.txt',sep = '\t',
            row.names=F,quote=F)


########################################3
pco2GC$pCO2_lake_uatm<-pco2$pCO2_lake_uatm # converting uatm to uM 
colnames(pco2GC)[grep('pCO2_lake_uatm',colnames(pco2GC))]='' # 



