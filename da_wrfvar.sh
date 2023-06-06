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
# da_wrfvar.exe
source ~/.bashrc

cd ${work_dir}

for nest in $(seq 1 ${max_dom});
do

if [[ -e ${radar_dir}/"${yyyy1}-${mm1}-${dd1}_${cc}_00_00.d0${max_dom}.ctl.ob.radar" ]]; then
   echo "radar file exist, include radar"
   ln -sf ${radar_dir}/${yyyy1}-${mm1}-${dd1}_${cc}_00_00.d0${nest}.ctl.ob.radar ./ob.radar
   radarobs=".true."
   radar_rv=".true."
   radar_rf=".true."
   radar_rhv=".false."
   radar_rqv=".true."
else
   echo "radar file does not exist, exclude radar"
   radarobs=".false."
   radar_rv=".false."
   radar_rf=".false."
   radar_rhv=".false."
   radar_rqv=".false."
fi

if [[ ! -f ${work_dir}/"obs_gts_"${yyyy1}-${mm1}-${dd1}_${cc}":00:00.3DVAR" ]]; then
   echo "sinop file does not exist, exclude sinop"
   synopobs=".false."
   soundobs=".false."
else
   echo "sinop file exist, include sinop"
   synopobs=".true."
   soundobs=".true."
   ln -sf ${work_dir}/obs_gts_${yyyy1}-${mm1}-${dd1}_${cc}":00:00.3DVAR" ${work_dir}/ob.ascii
fi

if [[ ! -f ${hima_dir}/${yyyy1}${mm1}${dd1}${cc}/NC_H09_${yyyy1}${mm1}${dd1}_${cc}00_R21_FLDK.02401_02401.nc ]]; then
   echo "satelite file does not exist, exclude satelite"
   ahiobs=".false."
else
   echo "satelite file exist, include satelite"
   ahiobs=".true."
   ln -sf ${hima_dir}/${yyyy1}${mm1}${dd1}${cc}/NC_H09_${yyyy1}${mm1}${dd1}_${cc}00_R21_FLDK.02401_02401.nc ./L1AHITBR
   ln -sf ${hima_dir}/${yyyy1}${mm1}${dd1}${cc}/NC_H09_${yyyy1}${mm1}${dd1}_${cc}00_L2CLP010_FLDK.02401_02401.nc ./L2AHICLP
fi

ln -sf ${wrfda_dir}/var/run/radiance_info  ./radiance_info
ln -sf ${wrfda_dir}/var/run/ahi_info  ./ahi_info
#ln -sf ${wrfda_dir}/var/run/crtm_coeffs_2.3.0 ./crtm_coeffs
ln -sf ${wrfda_dir}/var/run/VARBC.in  ./VARBC.in
ln -sf ${work_dir}/temp/wrfinput_d0${nest} ./fg
#ln -sf ${work_dir}/static/be.dat.cv5.d0${nest} ./be.dat
ln -sf ${work_dir}/static/be.dat.cv3 ./be.dat
ln -sf ${wrfda_dir}/run/LANDUSE.TBL ./LANDUSE.TBL
ln -sf ${wrfda_dir}/var/build/da_wrfvar.exe ./da_wrfvar.exe
######domain configuration########

if [ d0${nest} == "d01" ]; then
    WEST_EAST_GRID_NUMBER=${ewe_1}
    SOUTH_NORTH_GRID_NUMBER=${esn_1}
    RESOL=${dx_1}
fi

if [ d0${nest} == "d02" ]; then
    WEST_EAST_GRID_NUMBER=${ewe_2}
    SOUTH_NORTH_GRID_NUMBER=${esn_2}
    RESOL=${dx_2}
fi

if [ d0${nest} == "d03" ]; then
    WEST_EAST_GRID_NUMBER=${ewe_3}
    SOUTH_NORTH_GRID_NUMBER=${esn_3}
    RESOL=${dx_3}
fi

cat > namelist.input << EOF
&wrfvar1
var4d=false,
print_detail_grad=false,
/
&wrfvar2
 wind_sd                             = true,
 wind_stats_sd                       = true,
/
&wrfvar3
 ob_format                           = 2,
/
&wrfvar4
 thin_conv                           = .false.,
 use_synopobs                        = ${synopobs},
 use_shipsobs                        = .false.,
 use_metarobs                        = .false.,
 use_soundobs                        = ${soundobs},
 use_pilotobs                        = .false.,
 use_airepobs                        = .false.,
 use_geoamvobs                       = .false.,
 use_polaramvobs                     = .false.,
 use_bogusobs                        = .false.,
 use_buoyobs                         = .false.,
 use_profilerobs                     = .false.,
 use_satemobs                        = .false.,
 use_gpspwobs                        = .false.,
 use_gpsrefobs                       = .false.,
 use_ssmiretrievalobs                = .false.,
 use_ssmitbobs                       = .false.,
 use_ssmt1obs                        = .false.,
 use_ssmt2obs                        = .false.,
 use_qscatobs                        = .false.,
 use_radarobs                        = ${radarobs},
 use_radar_rv                        = ${radar_rv},
 use_radar_rf                        = ${radar_rf},
 radar_rf_opt                        = 2,
 use_radar_rhv                       = ${radar_rhv},
 use_radar_rqv                       = ${radar_rqv},
 use_ahiobs                          = ${ahiobs},
/
&wrfvar5
/
&wrfvar6
 max_ext_its                         = 1,
/
&wrfvar7
 cv_options                          = 3,
 cloud_cv_options                    = 0,
/
&wrfvar8
/
&wrfvar9
/
&wrfvar10
 test_transforms                     = false,
 test_gradient                       = false
/
&wrfvar11
/
&wrfvar12
/
&wrfvar13
/
&wrfvar14
rtminit_nsensor = 1,
rtminit_platform = 31,
rtminit_satid = 8,
rtminit_sensor = 56,
thinning_mesh = 60.0,
thinning = .true.,
qc_rad = .true.,
write_iv_rad_ascii = .false.,
write_oa_rad_ascii = .true.,
rtm_option = 2,
crtm_coef_path ="${wrfda_dir}/var/run/crtm_coeffs_2.3.0",
only_sea_rad = .false.,
use_varbc = .true.,
use_crtm_kmatrix = .true.,
varbc_nbgerr = 5000,
/
&wrfvar15
/
&wrfvar16
/
&wrfvar17
/
&wrfvar18
 analysis_date                       = "${yyyy1}-${mm1}-${dd1cc}:00:00.0000",
/
&wrfvar19
/
&wrfvar20
/
&wrfvar21
 time_window_min                     = "${min_da}",
/
&wrfvar22
 time_window_max                     = "${max_da}",
/
&time_control
run_days                 = ${length},
run_hours                = 0,
run_minutes              = 0,
run_seconds              = 0,
start_year               = ${yyyy1},     ${yyyy1},     ${yyyy1},
start_month              = ${mm1},       ${mm1},       ${mm1},
start_day                = ${dd1},       ${dd1},       ${dd1},
start_hour               = ${cc},        ${cc},        ${cc},
start_minute             = 00,       00,       00,
start_second             = 00,       00,       00,
end_year                 = ${yyyy2},     ${yyyy2},     ${yyyy2},
end_month                = ${mm2},       ${mm2},       ${mm2},
end_day                  = ${dd2},       ${dd2},       ${dd2},
end_hour                 = ${cc},        ${cc},        ${cc},
end_minute               = 00,       00,       00,
end_second               = 00,       00,       00,
force_use_old_data       = true,
/
&fdda
/
&domains
e_we                     = ${WEST_EAST_GRID_NUMBER},
e_sn                     = ${SOUTH_NORTH_GRID_NUMBER},
s_vert                   = 1,
e_vert                   = ${evert},
dx                       = ${RESOL},
dy                       = ${RESOL},
/
&dfi_control
/
&tc
/
&physics
mp_physics=6,
ra_lw_physics=4,
ra_sw_physics=4,
radt=9,
sf_sfclay_physics=91,
sf_surface_physics=2,
bl_pbl_physics=5,
cu_physics=16,
cudt=5,
num_soil_layers=4,
num_land_cat=28,
mp_zero_out=2,
co2tf=0,
/
&scm
/
&dynamics
/
&bdy_control
/
&grib2
/
&fire
/
&namelist_quilt
/
&perturbation
/
EOF

ml load mpi compiler

echo "############## DA_WRVAR.EXE ${nest} ###############"

time mpiexec.hydra -np 20 ./da_wrfvar.exe

cp namelist.input temp/namelist.dawrf${nest}
cp rsl.out.0000 temp/rsl.out.0000.dawrf${nest}
cp rsl.error.0000 temp/rsl.error.0000.dawrf${nest}
mv wrfvar_output ${work_dir}/temp/wrfinput"_d0${nest}.da"
done

exit 0
