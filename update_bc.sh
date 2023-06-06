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
# 4. Mulai memakai CV5 sejak 2021070200 By Royan             #
# 5. Mulai WRF_Solar &AFWA sejak 2021070400 By Royan         #
##############################################################
# update bc
source ~/.bashrc

cd ${work_dir}

ln -sf ${wrfda_dir}/var/build/da_update_bc.exe .
ln -sf ${work_dir}/static/parame.in .
cp ${work_dir}/temp/wrfbdy_d01 .
cp ${work_dir}/temp/wrfinput_d01.da ./wrfvar_output
cp ${work_dir}/temp/wrfinput_d01 ./wrfinput_d01

./da_update_bc.exe
rm wrfinput_d01
mv wrfvar_output wrfinput_d01
if [[ ${max_dom} == 3 ]]; then
   cp ${work_dir}/temp/wrfinput_d02.da ./wrfinput_d02
   cp ${work_dir}/temp/wrfinput_d03.da ./wrfinput_d03
fi

if [[ ${max_dom} == 2 ]]; then
   cp ${work_dir}/temp/wrfinput_d02.da ./wrfinput_d02
fi


exit 0
