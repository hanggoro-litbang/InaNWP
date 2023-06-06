#!/bin/bash
##############################################################
# Copyright (c) 2020-2021, Fatkhuroyan                       #
# fatkhuroyan@bmkg.go.id                                     #
# download data himawari                                     #
# from jaxa to inanwp                                        #
##############################################################
# download FTP
source ~/.bashrc
mkdir -p ${hima_dir}/${yyyy1}${mm1}${dd1}${cc}
cd ${hima_dir}/${yyyy1}${mm1}${dd1}${cc}

       if [ -e ${hima_dir}/${yyyy1}${mm1}${dd1}${cc}/NC_H09_${yyyy1}${mm1}${dd1}_${cc}00_R21_FLDK.02401_02401.nc ]; then
               echo "File NC_H09_${yyyy1}${mm1}${dd1}_${cc}00_R21_FLDK.02401_02401.nc exist, skipping"
       else
               echo "Download Temperature Brightness"
               wget --user=izzaroyan_yahoo.com --password='SP+wari8' ftp://ftp.ptree.jaxa.jp/jma/netcdf/${yyyy1}${mm1}/${dd1}/NC_H09_${yyyy1}${mm1}${dd1}_${cc}00_R21_FLDK.02401_02401.nc
       fi

       if [ -e ${hima_dir}/${yyyy1}${mm1}${dd1}${cc}/NC_H09_${yyyy1}${mm1}${dd1}_${cc}00_L2CLP010_FLDK.02401_02401.nc ]; then
               echo "File NC_H09_${yyyy1}${mm1}${dd1}_${cc}00_L2CLP010_FLDK.02401_02401.nc exist, skipping"
       else
               echo "Download Cloud Product"
                wget --user=izzaroyan_yahoo.com --password='SP+wari8' ftp://ftp.ptree.jaxa.jp/pub/himawari/L2/CLP/010/${yyyy1}${mm1}/${dd1}/${cc}/NC_H09_${yyyy1}${mm1}${dd1}_${cc}00_L2CLP010_FLDK.02401_02401.nc
       fi
exit 0
