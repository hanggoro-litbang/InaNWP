#!/bin/sh
##############################################################
# Copyright (c) 2016-2018, Wido Hanggoro                     #
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
##############################################################
##
## 16 Juni 2019
## This is new download script
## Due to old server serve strange data
## 09 Feb 2021 Bind all download script from various server
source ~/.bashrc
#########
#yyyy1=2021
#mm1=02
#dd1=10
#cc=12
#lengthhour=3
##########
########## Domain Selection for grib filter #############
ll=80   #left
rl=160  #right
tl=20    #top
bl=-30  #bottom
###########
gfilter_server="https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?"
nccf_server="https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/"
para_server="https://para.nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/para/"
ems_server="https://soostrc.comet.ucar.edu/data/grib/gfsp25/"
#########
mkdir -p ${gfs_dir}/${yyyy1}${mm1}${dd1}${cc}
cd ${gfs_dir}/${yyyy1}${mm1}${dd1}${cc}
########### https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25_1hr.pl?file=gfs.t12z.pgrb2.0p25.f000&leftlon=97&rightlon=122&toplat=1&bottomlat=-16&dir=%2Fgfs.20210208%2F12
if [[ $1 == "gfilter" ]]
then
  echo "download from nomads grib filter server"
  for fhr in `seq 0 ${step} ${lengthhour}`
  do
    if [[ ${fhr} -lt "10" ]]; then
      wget -O gfs.t${cc}z.pgrb2.0p25.f00${fhr} -nc "${gfilter_server}file=gfs.t${cc}z.pgrb2.0p25.f00${fhr}&all_lev=on&all_var=on&subregion=&leftlon=${ll}&rightlon=${rl}&toplat=${tl}&bottomlat=${bl}&dir=%2Fgfs.${yyyy1}${mm1}${dd1}%2F${cc}%2Fatmos"
    elif [[ ${fhr} -ge "10" ]] && [[ ${fhr} -lt "100" ]]; then
      wget -O gfs.t${cc}z.pgrb2.0p25.f0${fhr} -nc "${gfilter_server}file=gfs.t${cc}z.pgrb2.0p25.f0${fhr}&all_lev=on&all_var=on&subregion=&leftlon=${ll}&rightlon=${rl}&toplat=${tl}&bottomlat=${bl}&dir=%2Fgfs.${yyyy1}${mm1}${dd1}%2F${cc}%2Fatmos"
    else
      wget -O gfs.t${cc}z.pgrb2.0p25.f${fhr} -nc "${gfilter_server}file=gfs.t${cc}z.pgrb2.0p25.f${fhr}&all_lev=on&all_var=on&subregion=&leftlon=${ll}&rightlon=${rl}&toplat=${tl}&bottomlat=${bl}&dir=%2Fgfs.${yyyy1}${mm1}${dd1}%2F${cc}%2Fatmos"
    fi
  sleep 1
  done
elif [[ $1 == "nccf" ]]
then
  echo "download from nomads nccf server"
  for fhr in `seq 0 ${step} ${lengthhour}`
  do
    if [[ ${fhr} -lt "10" ]]; then
      wget -O gfs.t${cc}z.pgrb2.0p25.f00${fhr} -nc "${nccf_server}gfs.${yyyy1}${mm1}${dd1}/${cc}/gfs.t${cc}z.pgrb2.0p25.f00${fhr}"
    elif [[ ${fhr} -ge "10" ]] && [[ ${fhr} -lt "100" ]]; then
      wget -O gfs.t${cc}z.pgrb2.0p25.f0${fhr} -nc "${nccf_server}gfs.${yyyy1}${mm1}${dd1}/${cc}/gfs.t${cc}z.pgrb2.0p25.f0${fhr}"
    else
      wget -O gfs.t${cc}z.pgrb2.0p25.f${fhr} -nc "${nccf_server}gfs.${yyyy1}${mm1}${dd1}/${cc}/gfs.t${cc}z.pgrb2.0p25.f${fhr}"
    fi
  sleep 1
  done
elif [[ $1 == "para" ]]
then
  echo "download from nomads para server"
  for fhr in `seq 0 ${step} ${lengthhour}`
  do
    if [[ ${fhr} -lt "10" ]]; then
      wget -O gfs.t${cc}z.pgrb2.0p25.f00${fhr} -nc "${para_server}gfs.${yyyy1}${mm1}${dd1}/${cc}/atmos/gfs.t${cc}z.pgrb2.0p25.f00${fhr}"
    elif [[ ${fhr} -ge "10" ]] && [[ ${fhr} -lt "100" ]]; then
      wget -O gfs.t${cc}z.pgrb2.0p25.f0${fhr} -nc "${para_server}gfs.${yyyy1}${mm1}${dd1}/${cc}/atmos/gfs.t${cc}z.pgrb2.0p25.f0${fhr}"
    else
      wget -O gfs.t${cc}z.pgrb2.0p25.f${fhr} -nc "${para_server}gfs.${yyyy1}${mm1}${dd1}/${cc}/atmos/gfs.t${cc}z.pgrb2.0p25.f${fhr}"
    fi
  sleep 1
  done
elif [[ $1 == "ems" ]]
then
  echo "download from ems server"
  yyems=`echo ${yyyy1} |cut -c3-4`
  # http://soostrc.comet.ucar.edu/data/grib/gfsp25/20210208/grib.t12z/21020812.gfs.t12z.0p25.pgrb2f000
  for fhr in `seq 0 ${step} ${lengthhour}`
  do
    if [[ ${fhr} -lt "10" ]]; then
      wget -O gfs.t${cc}z.pgrb2.0p25.f00${fhr} -nc "${ems_server}${yyyy1}${mm1}${dd1}/grib.t${cc}z/${yyems}${mm1}${dd1}${cc}.gfs.t${cc}z.0p25.pgrb2f00${fhr}"
    elif [[ ${fhr} -ge "10" ]] && [[ ${fhr} -lt "100" ]]; then
      wget -O gfs.t${cc}z.pgrb2.0p25.f0${fhr} -nc "${ems_server}${yyyy1}${mm1}${dd1}/grib.t${cc}z/${yyems}${mm1}${dd1}${cc}.gfs.t${cc}z.0p25.pgrb2f0${fhr}"
    else
      wget -O gfs.t${cc}z.pgrb2.0p25.f${fhr} -nc "${ems_server}${yyyy1}${mm1}${dd1}/grib.t${cc}z/${yyems}${mm1}${dd1}${cc}.gfs.t${cc}z.0p25.pgrb2f${fhr}"
    fi
  sleep 1
  done
else
  echo "no choice ? ems server then"
  for fhr in `seq 0 ${step} ${lengthhour}`
  do
    if [[ ${fhr} -lt "10" ]]; then
      wget -O gfs.t${cc}z.pgrb2.0p25.f00${fhr} -nc "${ems_server}${yyyy1}${mm1}${dd1}/grib.t${cc}z/${yyems}${mm1}${dd1}${cc}.gfs.t${cc}z.0p25.pgrb2f00${fhr}"
    elif [[ ${fhr} -ge "10" ]] && [[ ${fhr} -lt "100" ]]; then
      wget -O gfs.t${cc}z.pgrb2.0p25.f0${fhr} -nc "${ems_server}${yyyy1}${mm1}${dd1}/grib.t${cc}z/${yyems}${mm1}${dd1}${cc}.gfs.t${cc}z.0p25.pgrb2f0${fhr}"
    else
      wget -O gfs.t${cc}z.pgrb2.0p25.f${fhr} -nc "${ems_server}${yyyy1}${mm1}${dd1}/grib.t${cc}z/${yyems}${mm1}${dd1}${cc}.gfs.t${cc}z.0p25.pgrb2f${fhr}"
    fi
  sleep 1
  done
fi
