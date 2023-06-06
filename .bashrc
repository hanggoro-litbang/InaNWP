# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/inanwp/libraries/zlib-1.2.9/lib:/home/inanwp/libraries/szip-2.1.1/lib:/home/inanwp/libraries/hdf5-1.12.0/lib:/home/inanwp/libraries/curl-7.72.0/lib:/home/inanwp/libraries/netcdf-4.7.4/lib:/home/inanwp/libraries/jpeg-9e/lib:/home/inanwp/libraries/libpng-1.6.37/lib:/home/inanwp/libraries/jasper-1.900.1/lib:/home/inanwp/libraries/bzip2-1.0.6/lib:/home/inanwp/libraries/pcre-8.40/lib:/opt/software/intel/oneapi/compiler/latest/linux/compiler/lib/intel64_lin:/usr/lib64:/home/inanwp/libraries/grads-2.2.1/supplibs/lib:/home/inanwp/libraries/grads-2.2.1/lib:
export PATH=$PATH:/home/inanwp/libraries/cmake-3.25.3/bin:/home/inanwp/libraries/curl-7.72.0/bin:/home/inanwp/libraries/R-4.3.0/bin:/home/inanwp/libraries/netcdf-4.7.4/bin:/home/inanwp/libraries/.anaconda3/bin:/home/inanwp/libraries/wrfpost/bin:/home/inanwp/libraries/grads-2.2.1/bin:
export CC=icc
export FC=ifort
export CXX=icpc
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.332.b09-1.el8_5.x86_64/jre
# WRF Profile
alias kescrp="cd /home/inanwp/WRF/.SCRIPT"
alias kewdir="cd /scratch/inanwp/WDIR"
alias runpython="/home/inanwp/libraries/.anaconda3/bin/python"
export main_dir=/home/inanwp/WRF
export data_dir=/scratch/inanwp
export scrp_dir=${main_dir}/.SCRIPT
export wrf_dir=${main_dir}/WRF-4.2
export wrfda_dir=${main_dir}/WRFDA-4.2
export wps_dir=${main_dir}/WPS-4.2
export geog_dir=/scratch/bmkg_4/WRF/GEOG
export inp_dir=${data_dir}/INPUT
export gfs_dir=${inp_dir}/GFS_0.25
export radar_dir=${inp_dir}/Asimilate/radar_data
export hima_dir=${inp_dir}/Asimilate/hima_data
export sinop_dir=${inp_dir}/Asimilate/sinop_data
export bin_dir=/home/inanwp/libraries/wrfpost/bin
export upp_dir=${main_dir}/UPPV4.1
#export out_dir=${data_dir}/OUTPUT
# GrADS
export GAUDPT=/home/inanwp/libraries/grads-2.2.1/udpt
export GADDIR=/home/inanwp/libraries/grads-2.2.1
export GASCRP=/home/inanwp/libraries/grads-2.2.1/script
