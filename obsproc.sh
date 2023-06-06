#!/bin/bash
source ~/.bashrc

cd $work_dir
ln -sf ${wrfda_dir}/var/obsproc/src/obsproc.exe .
ln -sf ${wrfda_dir}/var/obsproc/msfc.tbl .
ln -sf ${wrf_dir}/var/obsproc/obserr.txt .
ln -sf ${sinop_dir}/grobs.${yyyy1}${mm1}${dd1}${cc} .
cat > namelist.obsproc << EOF
&record1
 obs_gts_filename = 'grobs.${yyyy1}${mm1}${dd1}${cc}',
 obs_err_filename = 'obserr.txt',
 gts_from_mmm_archive = .true.,
/

&record2
 time_window_min  = '${min_da}',
 time_analysis    = '${yyyy1}-${mm1}-${dd1cc}:00:00',
 time_window_max  = '${max_da}',
/

&record3
 max_number_of_obs        = 400000,
 fatal_if_exceed_max_obs  = .TRUE.,
/

&record4
 qc_test_vert_consistency = .TRUE.,
 qc_test_convective_adj   = .TRUE.,
 qc_test_above_lid        = .TRUE.,
 remove_above_lid         = .false.,
 domain_check_h           = .false.,
 Thining_SATOB            = .false.,
 Thining_SSMI             = .false.,
 Thining_QSCAT            = .false.,
 calc_psfc_from_qnh       = .true.,
/

&record5
 print_gts_read           = .TRUE.,
 print_gpspw_read         = .TRUE.,
 print_recoverp           = .TRUE.,
 print_duplicate_loc      = .TRUE.,
 print_duplicate_time     = .TRUE.,
 print_recoverh           = .TRUE.,
 print_qc_vert            = .TRUE.,
 print_qc_conv            = .TRUE.,
 print_qc_lid             = .TRUE.,
 print_uncomplete         = .TRUE.,
/

&record6
 ptop =  1000.0,
 base_pres       = 100000.0,
 base_temp       = 290.0,
 base_lapse      = 50.0,
 base_strat_temp = 215.0,
 base_tropo_pres = 20000.0
/

&record7
 IPROJ = 3,
 PHIC  = ${reflat},
 XLONC = ${reflon},
 TRUELAT1= ${truelat_1},
 TRUELAT2= ${truelat_2},
 MOAD_CEN_LAT = ${reflat},
 STANDARD_LON = ${standlon},
/

&record8
 IDD    =   1,
 MAXNES =   ${max_dom},
 NESTIX =   ${ewe_1}, ${ewe_2}, ${ewe_3},
 NESTJX =   ${esn_1}, ${esn_2}, ${esn_3},
 DIS    =   9,    3,   1,
 NUMC   =   1,    1,   2,
 NESTI  =   ${ipars_1}, ${ipars_2}, ${ipars_3},
 NESTJ  =   ${jpars_1}, ${jpars_2}, ${jpars_3},
 /

&record9
 PREPBUFR_OUTPUT_FILENAME = 'prepbufr_output_filename',
 PREPBUFR_TABLE_FILENAME = 'prepbufr_table_filename',
 OUTPUT_OB_FORMAT = 2
 use_for          = '3DVAR',
 num_slots_past   = 3,
 num_slots_ahead  = 3,
 write_synop = .true.,
 write_ship  = .false.,
 write_metar = .false.,
 write_buoy  = .false.,
 write_pilot = .false.,
 write_sound = .true.,
 write_amdar = .false.,
 write_satem = .false.,
 write_satob = .false.,
 write_airep = .false.,
 write_gpspw = .false.,
 write_gpsztd= .false.,
 write_gpsref= .false.,
 write_gpseph= .false.,
 write_ssmt1 = .false.,
 write_ssmt2 = .false.,
 write_ssmi  = .false.,
 write_tovs  = .false.,
 write_qscat = .false.,
 write_profl = .false.,
 write_bogus = .false.,
 write_airs  = .false.,
 /

&record10
 wind_sd        = .true.
 wind_sd_synop  = .true.
 wind_sd_sound  = .true.
/

EOF

cp namelist.obsproc temp/namelist.obsproc
#cp rsl.out.0000 temp/rsl.out.0000.obsproc
#cp rsl.error.0000 temp/rsl.error.0000.obsproc
time ./obsproc.exe

exit
