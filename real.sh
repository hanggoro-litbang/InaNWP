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
# real.exe
source ~/.bashrc

cd ${work_dir}
ln -sf ${wrf_dir}/run/*.TBL .
ln -sf ${wrf_dir}/run/RRTM* .
ln -sf ${wrf_dir}/run/ozone* .
ln -sf ${wrf_dir}/run/aerosol* .
ln -sf ${wrf_dir}/main/*.exe .
ln -sf ${work_dir}/wpsprd/met_em* .

cat > namelist.input << EOF
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
interval_seconds         = ${inter_sec},
input_from_file          = .true.,   .true.,   .true.,
history_interval         = 180,       180,       60,
frames_per_outfile       = 1000,     1000,     1000,
restart                  = .false.,
restart_interval         = 360,
io_form_history          = 2,
io_form_restart          = 2,
io_form_input            = 2,
io_form_boundary         = 2,
debug_level              = 0,
!iofields_filename = '${work_dir}/static/my_file_d01.txt', '${work_dir}/static/my_file_d02.txt','${work_dir}/static/my_file_d03.txt',
!ignore_iofields_warning  = .true.,
nwp_diagnostics = 1,
/

&domains
 time_step                = 45,
 time_step_fract_num      = 0,
 time_step_fract_den      = 1,
 max_dom                  = ${max_dom},
 use_adaptive_time_step   = .true.,
 step_to_output_time      = .true.,
 target_cfl               = 1.2, 1.2, 1.2,
 max_step_increase_pct    = 5, 51, 51,
 starting_time_step       = -1
 e_we                     = ${ewe_1},${ewe_2},${ewe_3},
 e_sn                     = ${esn_1},${esn_2},${esn_3}, 
 e_vert                   = ${evert},${evert},${evert},
 p_top_requested          = 5000,
 num_metgrid_levels       = 34,
 num_metgrid_soil_levels  = 4,
 dx                       = ${dx_1},     ${dx_2},     ${dx_3},
 dy                       = ${dy_1},     ${dy_2},     ${dy_3},
 grid_id                  = 1,        2,        3,
 parent_id                = 1,        1,        2,
 i_parent_start           = ${ipars_1},${ipars_2},${ipars_3},
 j_parent_start           = ${jpars_1},${jpars_2},${jpars_3},
 parent_grid_ratio        = 1,        3,        3,
 parent_time_step_ratio   = 1,        3,        3,
 feedback                 = 1,
 smooth_option            = 0,
 nproc_x                  = -1,
 nproc_y                  = -1,
/

&physics
 physics_suite            = 'tropical'
!mp_physics               = 6,        6,        6,
 cu_physics               = 16,      16,        0,
 bl_pbl_physics           = 5,        5,        5,
 radt                     = 9,
 bldt                     = 0,        0,        0,
 cudt                     = 5,        5,        5,
 isfflx		          = 1,
 ifsnow           	  = 0,
 icloud                   = 1,
 num_soil_layers          = 4,
 num_land_cat             = 28,
 sf_urban_physics         = 0,        0,	0,
 maxiens                  = 1,
 maxens                   = 3,
 maxens2                  = 3,
 maxens3                  = 16,
 ensdim                   = 144,
bl_mynn_tkeadvect         = .true.,
cu_rad_feedback           = .false.,
bl_mynn_edmf              = 1,
shcu_physics              = 0,
aer_opt                   = 1,
swint_opt                 = 2,
usemonalb                 = .true.,
do_radar_ref              = 1,
/

&fdda
/

&dynamics
hybrid_opt               = 2,
w_damping                = 0,
diff_opt                 = 1,
km_opt                   = 4,
diff_6th_opt             = 0,        0,        0,
diff_6th_factor          = 0.12,     0.12,     0.12,
base_temp                = 290.,
damp_opt                 = 0,
zdamp                    = 5000.,    5000.,    5000.,
dampcoef                 = 0.2,      0.2,      0.2,
khdif                    = 0,        0,        0,
kvdif                    = 0,        0,        0,
non_hydrostatic          = .true.,   .true.,   .true.,
moist_adv_opt            = 1,        1,        1,
scalar_adv_opt           = 1,        1,        1,
/

&bdy_control
spec_bdy_width           = 5,
spec_zone                = 1,
relax_zone               = 4,
specified                = .true.,  .false.,  .false.,
nested                   = .false.,   .true.,   .true.,
/

&grib2
/

&namelist_quilt
nio_tasks_per_group      = 0,
nio_groups               = 1,
/

&diags
solar_diagnostics = 1,
/

&afwa
afwa_diag_opt  = 1,
!afwa_ptype_opt = 1,
!afwa_vil_opt = 1,
!afwa_radar_opt = 1,
afwa_severe_opt = 1,
!afwa_icing_opt = 1,
!afwa_vis_opt = 1,
!afwa_cloud_opt = 1,
!afwa_therm_opt = 1,
!afwa_turb_opt = 1,
!afwa_buoy_opt = 1,
!afwa_ptype_ccn_tmp = 264.15,
!afwa_ptype_tot_melt = 50,
!progn = 1,
/
EOF

ml load mpi compiler
time mpiexec.hydra -np 20 ./real.exe

cp namelist.input temp/namelist.realexe
cp rsl.out.0000 temp/rsl.out.0000.realexe
cp rsl.error.0000 temp/rsl.error.0000.realexe
cp wrfbdy_d01 wrfinput_d0* temp

exit 0
