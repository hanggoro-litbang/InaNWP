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
# Credit to: Ajie Linarka                                    #
# 24 May 2023                                                #
# - add local ip address ftp://202.90.199.205                #
##############################################################
# download radar
source ~/.bashrc

cd ${radar_dir}
for nest in $(seq 1 ${max_dom});
do
scp litbangmet@182.16.248.241:/home/litbangmet/radar/pyscript/obradar/inanwp/out/${yyyy1}-${mm1}-${dd1}_${cc}_00_00.d0${nest}.ctl.ob.radar .
done


exit 0
