#!/usr/bin/env Rscript
##############################################################
# Copyright (c) 2020-2021, Wido Hanggoro                     #
# wido_hanggoro@yahoo.com                                    #
# All rights reserved                                        #
# Redistribution and use in source and binary forms, with or #
# without modification, are permitted provided that the      #
# following conditions are met:                              #
# 1. Redistributions of source code must retain the above    #
#    copyright notice, this list of conditions and the       #
#    following disclaimer.                                   #
# 2. Redistributions in binary form must reproduce the above #
#    copyright notice, this list of conditions and the       #
#    following disclaimer in the documentation and/or other  #
#    materials provided with the distribution                #
# 3. Damage, loss, or disruption caused by the use of this   #
#    script beyond the author's responsibility               #
# Credit to: Donaldi S.P., Husein, N., Dian, H.              #
##############################################################


rm(list=ls()) #clear all variables
cat("\014") #clear console screen or press Ctrl+L in console

# take variable from bash script
args <- commandArgs(trailingOnly = TRUE)

requiredPackages = c('readr') #check necessary libraries
for(p in requiredPackages){
  if(!require(p,character.only = TRUE)) install.packages(p)
  library(p,character.only = TRUE)
}

wdir<-'/scratch/inanwp/INPUT/Asimilate/'
setwd(wdir)

#listing file input (mungkin bisa juga list all *.csv file)
datalist<-list.files(path=paste0('sinop_data/',args[1],'/'),pattern = '\\.csv$')

loop_line<-1
empty_val<- -888888.00000
qc_val<-0
end_val<- -777777.00000

for (filename in datalist) {
  #read file input
  header<-read_csv(paste0('sinop_data/',args[1],'/',filename),n_max = 1, col_types = cols(DATE_TIME=col_character()))
  data<-read_csv(paste0('sinop_data/',args[1],'/',filename),skip = 2)
  #hapus row satuan yang ada pada dataframe
  #data<-data[-1,]
  #data<-data[,-9:-11]
  #header modif
  check_code<-substr(header$CODE,4,6)
  if(check_code == "12"){
    header$CODE<-"FM-12  SYNOP" #change FM CODE Style
    is_sound<-"F"
  }
  if(check_code == "35"){
    header$CODE<-"FM-35  TEMP" #change FM CODE Style
    is_sound<-"T"

  }

  YYYY<-substr(header$DATE_TIME,1,4)
  MM<-substr(header$DATE_TIME,6,7)
  DD<-substr(header$DATE_TIME,9,10)
  hh<-substr(header$DATE_TIME,12,13)
  mm<-substr(header$DATE_TIME,15,16)
  ss<-"00"
  header$DATE_TIME<-paste0(YYYY,MM,DD,hh,mm,ss) # change date sytle
  #header$SEA_LEVEL_PRESSURE<-as.numeric(header$SEA_LEVEL_PRESSURE)*100 #convert mb to Pa
  header$SEA_LEVEL_PRESSURE<-as.numeric(ifelse(header[9] == empty_val, empty_val, (header[9])*100)) #convert mb to Pa
  #header$SURFACE_PRESSURE<-as.numeric(header$SURFACE_PRESSURE)*100 #convert mb to Pa
  header$SURFACE_PRESSURE<-as.numeric(ifelse(header[10] == empty_val, empty_val, (header[10])*100)) #convert mb to Pa

  #data modif
  data$PRES<-as.numeric(ifelse(data$PRES == empty_val, empty_val, (data$PRES)*100)) #convert mb to Pa
  data$HGHT<-as.numeric(data$HGHT)
  data$TEMP<-as.numeric(ifelse(data$TEMP == empty_val, empty_val,(data$TEMP)+273.15)) #convert degC to degK
  data$DWPT<-as.numeric(ifelse(data$DWPT == empty_val, empty_val,(data$DWPT)+273.15)) #convert degC to degK
  data$WSPEED<-as.numeric(ifelse(data$WSPEED == empty_val, empty_val,(data$WSPEED)*0.514444)) # convert knot to m/s
  data$WDRCT<-as.numeric(data$WDRCT)
  data$UWND<-as.numeric(ifelse(data$UWND == empty_val, empty_val,(data$UWND)*0.514444)) # convert knot to m/s
  data$VWND<-as.numeric(ifelse(data$VWND == empty_val, empty_val,(data$VWND)*0.514444)) # convert knot to m/s
  data$RELH<-as.numeric(data$RELH)
  data$THICKNESS<-as.numeric(data$THICKNESS)


  data_line<-{}
  for (i in 1:nrow(data)) {
    data_line[i]<-paste0(sprintf("%13.5f",ifelse(is.na(data$PRES[i]) ,empty_val,data$PRES[i])), #pressure (pa)
                        sprintf("%7d",qc_val), #QC
                        sprintf("%13.5f",ifelse(is.na(data$HGHT[i]) ,empty_val,data$HGHT[i])), # height (m)
                        sprintf("%7d",qc_val), #QC
                        sprintf("%13.5f",ifelse(is.na(data$TEMP[i]) ,empty_val,data$TEMP[i])), #Temp (K)
                        sprintf("%7d",qc_val), #QC
                        sprintf("%13.5f",ifelse(is.na(data$DWPT[i]) ,empty_val,data$DWPT[i])), #Dew point (K)
                        sprintf("%7d",qc_val), #QC
                        sprintf("%13.5f",ifelse(is.na(data$WSPEED[i]) ,empty_val,data$WSPEED[i])), #wind speed (m/s)
                        sprintf("%7d",qc_val), #QC
                        sprintf("%13.5f",ifelse(is.na(data$WDRCT[i]) ,empty_val,data$WDRCT[i])), #wind dir (deg)
                        sprintf("%7d",qc_val), #QC
                        sprintf("%13.5f",ifelse(is.na(data$UWND[i]) ,empty_val,data$UWND[i])), #u wind (m/s)
                        sprintf("%7d",qc_val), #QC
                        sprintf("%13.5f",ifelse(is.na(data$VWND[i]) ,empty_val,data$VWND[i])), #v wind (m/s)
                        sprintf("%7d",qc_val), #QC
                        sprintf("%13.5f",ifelse(is.na(data$RELH[i]) ,empty_val,data$RELH[i])), #RH (%)
                        sprintf("%7d",qc_val), #QC
                        sprintf("%13.5f",ifelse(is.na(data$THICKNESS[i]) ,empty_val,data$THICKNESS[i])), #Thickness (m)
                        sprintf("%7d",qc_val) #QC
    )
  }

  #End Record
  end_line<- paste0(sprintf("%13.5f", end_val),
                   sprintf("%7d", qc_val), #QC
                   sprintf("%13.5f",end_val),
                   sprintf("%7d",qc_val), #QC
                   sprintf("%13.5f",empty_val),
                   sprintf("%7d",qc_val), #QC
                   sprintf("%13.5f",empty_val),
                   sprintf("%7d",qc_val), #QC
                   sprintf("%13.5f",empty_val),
                   sprintf("%7d",qc_val), #QC
                   sprintf("%13.5f",empty_val),
                   sprintf("%7d",qc_val), #QC
                   sprintf("%13.5f",empty_val),
                   sprintf("%7d",qc_val), #QC
                   sprintf("%13.5f",empty_val),
                   sprintf("%7d",qc_val), #QC
                   sprintf("%13.5f",empty_val),
                   sprintf("%7d",qc_val), #QC
                   sprintf("%13.5f",empty_val),
                   sprintf("%7d",qc_val) #QC
  )


  if (length(data_line) != 0)
  {
    allength <- length(data_line)
    data_line[allength + 1] <- end_line
  }

  #three_tail
  tail_line<-paste0(sprintf("%7d",floor(runif(1)*100)),
                    sprintf("%7d",qc_val),
                    sprintf("%7d",qc_val))

  if (length(data_line) != 0)
  {
    allength1 <- length(data_line)
    data_line[allength1 + 1] <- tail_line
  }

  #header
  #create little R header
  head_line<-paste0(sprintf("%20.5f",as.numeric(header$LAT)), #27 Nov 2021 header LAT changed to string / add as.numeric()
                sprintf("%20.5f",as.numeric(header$LON)),
                sprintf("%-40s",header$ID),
                sprintf("%-40s", substr(header$STA_NAME,1,40)),
                sprintf("%-40s", header$CODE),
                sprintf("%-40s", substr(header$SOURCE,1,40)),
                sprintf("%20.5f", header$ELEVATION),
                sprintf("%10d",empty_val), #valid field
                sprintf("%10d",empty_val), #num errors
                sprintf("%10d",empty_val), #num warnings
                sprintf("%10d",floor(runif(1)*100)), #sequence number
                sprintf("%10d", empty_val), #num duplicates
                sprintf("%10s",is_sound), #is sounding
                sprintf("%10s","F"), #is bogus
                sprintf("%10s","F"), #discard
                sprintf("%10d",empty_val), #unix time
                sprintf("%10d",empty_val), #julian day
                sprintf("%20s",header$DATE_TIME), #date
                sprintf("%13.5f",ifelse(is.na(header$SEA_LEVEL_PRESSURE) == T, empty_val, header$SEA_LEVEL_PRESSURE)), #SLP opt
                sprintf("%7d",qc_val), #QC
                sprintf("%13.5f",empty_val), #Ref Pressure
                sprintf("%7d",qc_val), #QC
                sprintf("%13.5f",empty_val), #Ground temp
                sprintf("%7d",qc_val), #QC
                sprintf("%13.5f",empty_val), #SST
                sprintf("%7d",qc_val), #QC
                sprintf("%13.5f",ifelse(is.na(header$SURFACE_PRESSURE) == T, empty_val, header$SURFACE_PRESSURE)), #SFC Pressure opt
                sprintf("%7d",qc_val), #QC
                sprintf("%13.5f",empty_val), #Precip
                sprintf("%7d",qc_val), #QC
                sprintf("%13.5f",empty_val), #Daily Max T
                sprintf("%7d",qc_val), #QC
                sprintf("%13.5f",empty_val), #Daily Min T
                sprintf("%7d",qc_val), #QC
                sprintf("%13.5f",empty_val), #Night Min T
                sprintf("%7d",qc_val), #QC
                sprintf("%13.5f",empty_val), #3hr press change
                sprintf("%7d",qc_val), #QC
                sprintf("%13.5f",empty_val), #24hr press change
                sprintf("%7d",qc_val), #QC
                sprintf("%13.5f",empty_val), #cloud cover
                sprintf("%7d",qc_val), #QC
                sprintf("%13.5f",empty_val), #ceiling
                sprintf("%7d",qc_val), #QC
                sprintf("%13.5f",empty_val), #precip water opt
                sprintf("%7d",qc_val) #QC
  )

  if (length(data_line) != 0)
  {
    head_line[2:(1+length(data_line))] <- data_line
  }
  if (loop_line == 1){
    #print("HEADER")
    line_all<-head_line
  }
  else{
    nn<-length(line_all)
    line_all[(nn+1):(nn+length(head_line))]<-head_line
    #print("GABUNG")
  }
  loop_line<-loop_line+1
}

outfname <- paste(wdir,'/sinop_data/','grobs.',args[1],sep = '')
writeLines(line_all,outfname)
print(paste0(length(datalist)," files had successfully converted"))
