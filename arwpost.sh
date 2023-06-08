#!/bin/bash
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
#                                                            #
##############################################################
# 15 March 2021 add script to reload GDS
# ARWPOST
source ~/.bashrc
###############################
cd ${work_dir}
ln -sf ${arw_dir}/src/ARWpost.exe .
cp -r ${arw_dir}/src .
ln -sf ${work_dir}/wrfprd/wrfout* .

for domain in $(seq 1 ${max_dom})
do

  if [ $domain -eq 1 ]; then
   interval=10800
  fi

  if [ $domain -eq 2 ]; then
   interval=10800
  fi
  
  if [ $domain -eq 3 ]; then
   interval=3600
  fi


#start_date = '$yyyy1-$mm1-$dd1cc:00:00',
#end_date   = '$yyyy2-$mm2-$dd2cc:00:00',
cat > namelist.ARWpost << EOF
&datetime
 start_date = '${yyyy1}-${mm1}-${dd1cc}:00:00',
 end_date   = '${yyyy2}-${mm2}-${dd2cc}:00:00',
 interval_seconds = ${interval},
 tacc = 300,
 debug_level = 0,
/

&io
 input_root_name = './wrfout_d0${domain}*'
 output_root_name = '${work_dir}/${yyyy1}${mm1}${dd1}${cc}-d0${domain}-${rtag}'
 plot = 'all_list'
 fields_file = '${work_dir}/static/arwpost.list'
 fields = 'height,geopt,theta,tc,tk,td,td2,rh,rh2,umet,vmet,pressure,u10m,v10m,wdir,wspd,wd10,ws10,slp,mcape,mcin,lcl,lfc,cape,cin,dbz,max_dbz,clfr'
 mercator_defs = .true.
 split_output = .false.
 frames_per_outfile = 2
/
! split_output = .false.
! split_output = .true.
! frames_per_outfile = 2


! plot = 'all'
! plot = 'list'
! plot = 'all_list'
! Below is a list of all available diagnostics
! fields = 'height,geopt,theta,tc,tk,td,td2,rh,rh2,umet,vmet,pressure,u10m,v10m,wdir,wspd,wd10,ws10,slp,mcape,mcin,lcl,lfc,cape,cin,dbz,max_dbz,clfr'


&interp
 interp_method = 1,
 interp_levels = 1000.,950.,900.,850.,800.,750.,700.,650.,600.,550.,500.,450.,400.,350.,300.,250.,200.,150.,100.,
 extrapolate = .true.
/
!extrapolate = .true.

! interp_method = 0,     ! 0 is model levels, -1 is nice height levels, 1 is user specified pressure/height

! interp_levels = 1000.,950.,900.,850.,800.,750.,700.,650.,600.,550.,500.,450.,400.,350.,300.,250.,200.,150.,100.,
! interp_levels = 0.25, 0.50, 0.75, 1.00, 2.00, 3.00, 4.00, 5.00, 6.00, 7.00, 8.00, 9.00, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0,

EOF
echo "create *.ctl for domain $domain"
./ARWpost.exe
rm namelist.ARWpost
done


mkdir -p ${out_dir}/${yyyy1}${mm1}${dd1}${cc}
cp ${yyyy1}${mm1}${dd1}${cc}-d0* ${out_dir}/${yyyy1}${mm1}${dd1}${cc}
exit 0
