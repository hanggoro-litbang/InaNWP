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
# download FTP
source ~/.bashrc

mkdir -p ${sinop_dir}/${yyyy1}${mm1}${dd1}${cc}
cd ${sinop_dir}/${yyyy1}${mm1}${dd1}${cc}

for file in $(curl -s -u timmodelnwp:model@bmkg ftp://172.19.3.235:1603/Data4Asimilasi/${cc}/ | grep ${yyyy1}${mm1}${dd1}${cc})
do
       if [ -e ${sinop_dir}/${yyyy1}${mm1}${dd1}${cc}/${file} ]; then
	       echo "File $file exist, skipping"
       else
	       curl -s -O -u timmodelnwp:model@bmkg ftp://172.19.3.235:1603/Data4Asimilasi/${cc}/${file}
       fi
done

exit 0
