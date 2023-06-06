#!/bin/bash
##############################################################
# Copyright (c) 2020-2023, Wido Hanggoro                     #
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
# 23 May 2023                                                #
# - add cc selection automatically by hourdate               #            
# - delete all rm command on each script, replaced           #
#   by clean.sh                                              #
# - add domain setting on master script                      #
# - make clean look                                          #
# - split real, wrfvar, and wrf.exe processes                #
# - use upp instead arwpost                                  #
##############################################################
# START OF USER CONFIGURATION ##########################
source ~/.bashrc
dom=inanwp
work_dir=/scratch/inanwp/WDIR/${dom}
out_dir=${data_dir}/OUTPUT
sdate=`date +"%Y%m%d"`
edate=${sdate}
length=3
step=3
max_dom=3
ewe_1=621
esn_1=312
ewe_2=607
esn_2=298
ewe_3=457
esn_3=346
evert=33
ipars_1=1
jpars_1=1
ipars_2=99
jpars_2=52
ipars_3=122
jpars_3=117
dx_1=9000
dx_2=3000
dx_3=1000
dy_1=9000
dy_2=3000
dy_3=1000
reflat=-2.613
reflon=118.815
truelat_1=-2.613
truelat_2=0
standlon=118.815
refx=310.5
refy=156.0
nprocx=44
nprocy=28
niot=2
niog=8
# END OF USER CONFIGURATION ############################
date=${sdate}
export dom work_dir out_dir length step max_dom
export ewe_1 esn_1 ewe_2 esn_2 ewe_3 esn_3 evert
export ipars_1 jpars_1 ipars_2 jpars_2 ipars_3 jpars_3
export dx_1 dx_2 dx_3 dy_1 dy_2 dy_3
export reflat reflon truelat_1 truelat_2 standlon
export nprocx nprocy niot niog
export lengthhour=$(expr 24 '*' ${length})
export inter_sec=$(expr ${step} '*' 3600)
export stanggal=$date
# pengaturan cc otomatis by hourdate
hdate=`date +"%H"`
if [ ${hdate} -gt 0 -a ${hdate} -le 6 ]; then
        export cc=00
elif [ ${hdate} -gt 6 -a ${hdate} -le 12 ]; then
        export cc=06
elif [ ${hdate} -gt 12 -a ${hdate} -le 18 ]; then
        export cc=12
else
        export cc=18
fi
# pengaturan waktu untuk check file pada wps.sh
if [[ ${lengthhour} -lt "10" ]]; then
        dtag="f00${lengthhour}"
fi
if [[ ${lengthhour} -ge 10 ]] && [[ ${waktu} -lt 100 ]]; then
        dtag="f0${lengthhour}"
fi
if [[ ${lengthhour} -ge 100 ]]; then
        dtag="f${lengthhour}"
fi
# pengaturan ccmin dan ccmax pada modul wrfda
export yyyy1=`echo ${date} |cut -c1-4`
export mm1=`echo ${date} |cut -c5-6`
export dd1=`echo ${date} |cut -c7-8`
export dd1cc=${dd1}"_"${cc}
fdate=`${wrfda_dir}/var/da/da_advance_time.exe ${sdate}${cc} ${length}d`
export yyyy2=`echo ${fdate} |cut -c1-4`
export mm2=`echo ${fdate} |cut -c5-6`
export dd2=`echo ${fdate} |cut -c7-8`
export dd2cc=${dd2}"_"$cc
export ydate=`${wrfda_dir}/var/da/da_advance_time.exe ${sdate}${cc} -1d`
export min_da=`${wrfda_dir}/var/da/da_advance_time.exe ${sdate}${cc} -1h -w`
export max_da=`${wrfda_dir}/var/da/da_advance_time.exe ${sdate}${cc} 1h -w`
touch ${work_dir}/temp/README
echo "${yyyy1}${mm1}${dd1}${cc}" > ${work_dir}/temp/README
# start of script
while [[ ${date} -le ${edate} ]]
do
echo "############################################################################################"
echo "                                   ${yyyy1}${mm1}${dd1}${cc}                                "
echo "############################################################################################"
time ${scrp_dir}/clean.sh
# download local observation
echo "step 1 download local observation data"
time ${scrp_dir}/download_ftp.sh

# create little R format
echo "step 2 create little R format"
time ${scrp_dir}/csv2littleR.R ${yyyy1}${mm1}${dd1}${cc}

# download radar data
echo "step 3 download radar data"
time ${scrp_dir}/download_radar.sh

# run obsproc
echo "step 4 run obsproc"
time ${scrp_dir}/obsproc.sh

# download satelite data
echo "step 5 download himawari"
time ${scrp_dir}/download_hima.sh

# download initial condition data
echo "step 6 download initial condition data"
if [ -e "${gfs_dir}/${yyyy1}${mm1}${dd1}${cc}/gfs.t${cc}z.pgrb2.0p25.${dtag}" ]; then
        echo "File GFS ${yyyy1}${mm1}${dd1}${cc} exist, skipping"
else
	skipe=on
        time ${scrp_dir}/download_gfs0.25_master.sh gfilter
fi

# run WPS
echo "step 7 run Pre-processing WPS"
time ${scrp_dir}/wps.sh

# run WRF or WRFDA
echo "step 8 run WRF or WRFDA"
if [[ ! -f ${work_dir}/"obs_gts_"${yyyy1}-${mm1}-${dd1}_${cc}":00:00.3DVAR" && ! -f ${radar_dir}/"${yyyy1}-${mm1}-${dd1}_${cc}_00_00.d0${max_dom}.ctl.ob.radar" && ! -f ${hima_dir}/${yyyy1}${mm1}${dd1}${cc}/NC_H09_${yyyy1}${mm1}${dd1}_${cc}00_R21_FLDK.02401_02401.nc ]]; then
      echo "Assimilation data does not exist, Run WRF"
      export rtag=inanwp
      time ${scrp_dir}/real.sh
      sbatch -W ${scrp_dir}/wrf.sh
      sbatch -W ${scrp_dir}/plot_inanwp.sh ${yyyy1} ${mm1} ${dd1} ${cc}		# added by den
      # time ${scrp_dir}/upload.sh 										# added by den
      wait
else
      echo " Sinop or radar data or satelite data exist, Run WRFDA"
      export rtag=inanwp
      time ${scrp_dir}/real.sh
      time ${scrp_dir}/da_wrfvar.sh
      time ${scrp_dir}/update_bc.sh
      sbatch -W ${scrp_dir}/wrf.sh
      sbatch -W ${scrp_dir}/plot_inanwp.sh ${yyyy1} ${mm1} ${dd1} ${cc}		# added by den
      # time ${scrp_dir}/upload.sh 										# added by den
      wait
fi
echo "step 9 run Post-processing WRF-UPP"
time ${scrp_dir}/upp.sh
echo "step 10 kirim-kirim"
${scrp_dir}/kirim.sh

date=`date -u +"%Y%m%d" -d "+24 hours ${datestring}"`
done
