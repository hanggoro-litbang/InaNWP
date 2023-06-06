#!/bin/bash
source ~/.bashrc

user='litbangweb'
host='202.90.199.54'
destdir='/opt/lampp/htdocs/wrf/latest/GFS0.25deg+Ground+Radar+Sat/'
archivedir='/opt/lampp/htdocs/wrf/archive/GFS0.25deg+Ground+Radar+Sat/'

dir='/scratch/inanwp/PRODUCT/GFS0.25deg+Ground+Radar+Sat/*'
folders=$(ls -dt1 $dir | head -n 1)
echo $folders

# execute command in webserver
echo 'moving from latest to archive in webserver'
ssh -p 22 $user@$host mv $destdir/* $archivedir	 	# revised by den
echo 'copying new folder to latest'
scp -r $folders $user@$host:$destdir				 	# revised by den

