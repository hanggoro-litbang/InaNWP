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
# kirim2 FTP
source ~/.bashrc

cd ${work_dir}/postprd
rm WRFPRS_*.tmp
for dom in $(seq 1 ${max_dom});
do
for i in $( ls WRFPRS_d0${dom}.* ); do cp $i $i.tmp; done
done

# The 3 variables below store server and login details
HOST="192.168.222.20"
USER="inanwpz"
PASSWORD="Inanwpz1234"
#HOST="ftp2.mfi.fr"
#USER="bmkg-data"
#PASSWORD="meteo_event"

# $1 is the first argument to the script
# We are using it as upload directory path
# If it is '.', file is uploaded to current directory.
#DESTINATION=$1
DESTINATION="."
#DESTINATION="INANWP"

# Rest of the arguments are a list of files to be uploaded.
# ${@:2} is an array of arguments without first one.
#ALL_FILES="${@:2}"


# FTP login and upload is explained in paragraph below
ftp -inv $HOST <<EOF
user $USER $PASSWORD
cd $DESTINATION
mput *.tmp
bye
EOF

for i in $( ls *.tmp ); do
ftp -inv $HOST <<EOF
user $USER $PASSWORD
cd $DESTINATION
rename ${i} ${i%.*}
bye
EOF
done
exit 0
