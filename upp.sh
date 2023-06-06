#!/bin/bash
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
# UPP
source ~/.bashrc

cd ${work_dir}
ln -sf ${scrp_dir}/run_unipost_inanwp . 

for dom in $(seq 1 ${max_dom});
do
if [ ${dom} -eq 1 ]; then
   export upp_step=3
   export upp_dom=d01
fi

if [ ${dom} -eq 2 ]; then
   export upp_step=3
   export upp_dom=d02
fi

if [ ${dom} -eq 3 ]; then
   export upp_step=1
   export upp_dom=d03
fi
############create grads file#################################################
###### Domain 01 ##############
ml load mpi compiler
./run_unipost_inanwp

done

cd postprd
# domain 1
#cat WRFPRS_d01.* > ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d01_"${rtag}.grb
#g2ctl.pl -verf ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d01_"${rtag}.grb > ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d01_"${rtag}.ctl
#gribmap -i ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d01_"${rtag}.ctl
g2ctl.pl -verf WRFPRS_d01.%f2 > ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d01_"${rtag}.ctl
gribmap -i ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d01_"${rtag}.ctl

# domain 2
#cat WRFPRS_d02.* > ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d02_"${rtag}.grb
#g2ctl.pl -verf ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d02_"${rtag}.grb > ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d02_"${rtag}.ctl
#gribmap -i ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d02_"${rtag}.ctl
g2ctl.pl -verf WRFPRS_d02.%f2 > ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d02_"${rtag}.ctl
gribmap -i ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d02_"${rtag}.ctl

# domain 3
#cat WRFPRS_d03.[012][0123456789] > ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d03_"${rtag}1.grb
#cat WRFPRS_d03.[345][0123456789] > ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d03_"${rtag}2.grb
#cat WRFPRS_d03.[67][0123456789] > ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d03_"${rtag}3.grb
#g2ctl.pl -verf ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d03_"${rtag}.grb > ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d03_"${rtag}.ctl
#gribmap -i ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d03_"${rtag}.ctl
g2ctl.pl -verf WRFPRS_d03.%f2 > ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d03_"${rtag}.ctl
gribmap -i ${yyyy1}${mm1}${dd1}${cc}"_arw_wrfout_d03_"${rtag}.ctl


rm unipost_d0* *.bin copygb_hwrf.txt fort.* itag *.dat post* params_grib2_tbl_new
cp WRFPRS_* ${yyyy1}${mm1}${dd1}${cc}_arw_wrfout_* ${out_dir}/${yyyy1}${mm1}${dd1}${cc}
exit 0
