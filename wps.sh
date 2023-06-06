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
# WPS
source ~/.bashrc
#################################
cd ${work_dir}
ln -sf ${wps_dir}/ungrib/Variable_Tables/Vtable.GFS Vtable
ln -sf ${wps_dir}/ungrib/src/ungrib.exe .
ln -sf ${wps_dir}/metgrid/src/metgrid.exe .
ln -sf ${work_dir}/static/*.TBL .
cp ${work_dir}/static/link_grib.csh .
ln -sf ${work_dir}/static/geo_em*.nc .
./link_grib.csh ${gfs_dir}/${stanggal}${cc}/gfs.t"${cc}"z.pgrb2.0p25.f*

cat > namelist.wps << EOF
&share
 wrf_core = 'ARW',
 max_dom = ${max_dom},
 start_date = '${yyyy1}-${mm1}-${dd1cc}:00:00', '${yyyy1}-${mm1}-${dd1cc}:00:00', '${yyyy1}-${mm1}-${dd1cc}:00:00',
 end_date   = '${yyyy2}-${mm2}-${dd2cc}:00:00', '${yyyy2}-${mm2}-${dd2cc}:00:00', '${yyyy2}-${mm2}-${dd2cc}:00:00',
 interval_seconds = ${inter_sec},
 io_form_geogrid = 2,
 opt_output_from_geogrid_path = '${work_dir}',
 debug_level = 0,
/

&geogrid
 parent_id         = 1,1,2,
 parent_grid_ratio = 1,3,3,
 i_parent_start    = ${ipars_1},${ipars_2},${ipars_3},
 j_parent_start    = ${jpars_1},${jpars_2},${jpars_3},
 e_we              = ${ewe_1},${ewe_2},${ewe_3},
 e_sn              = ${esn_1},${esn_2},${esn_3},
 geog_data_res     = '5m','2m','30s',
 dx                = 9000,
 dy                = 9000,
 map_proj          =  'mercator',
 ref_lat           = ${reflat},
 ref_lon           = ${reflon},
 truelat1          = ${truelat_1},
 truelat2          = ${truelat_2},
 stand_lon         = ${standlon},
 geog_data_path    = '${geog_dir}',
 opt_geogrid_tbl_path = '${work_dir}',
 ref_x             = ${refx},
 ref_y             = ${refy},
/

&ungrib
 out_format = 'WPS',
 prefix = 'FILE',
/

&metgrid
 fg_name          = 'FILE',
 io_form_metgrid  = 2,
 opt_output_from_metgrid_path = '${work_dir}/wpsprd',
 opt_metgrid_tbl_path = '${work_dir}',
/

&mod_levs
 press_pa = 201300 , 200100 , 100000 ,
             95000 ,  90000 ,
             85000 ,  80000 ,
             75000 ,  70000 ,
             65000 ,  60000 ,
             55000 ,  50000 ,
             45000 ,  40000 ,
             35000 ,  30000 ,
             25000 ,  20000 ,
             15000 ,  10000 ,
              5000 ,   1000
 /

EOF

#OPENMPI
ulimit -s unlimited
time ./ungrib.exe
ml load compiler mpi
time mpiexec.hydra -np 20 ./metgrid.exe
exit
