#!/bin/bash
#SBATCH --job-name=wrf_inanwp       #passed by script
#SBATCH --nodes=13                #passed by script
#SBATCH --ntasks-per-node=96
#SBATCH --time=72:00:00
#SBATCH --output=wrf_inanwp.log #passed by script
#SBATCH --export=ALL

source ~/.bashrc

cd ${work_dir}
set -x

date

which mpiexec
which mpirun

# set -x
env | grep SLURM

ulimit -c unlimited
ulimit -a
##limit memoryuse unlimited
##limit stacksize unlimited

# OpenMP settings
export OMP_NUM_THREADS=1
export FI_PROVIDER=mlx
export I_MPI_OFI_PROVIDER=mlx
export I_MPI_FABRICS=shm:ofi
export I_MPI_SHM=clx_avx2
export I_MPI_FALLBACK=0
export I_MPI_HYDRA_IFACE=ib0
export I_MPI_HYDRA_PMI_CONNECT=alltoall
export FI_MLX_TLS=dc,dc_x,shm,self # or replace FI_MLX_TLS by UCX_TLS
export I_MPI_HYDRA_BRANCH_COUNT=4
export I_MPI_MALLOC=1
export I_MPI_SHM_HEAP=1

export KMP_AFFINITY=verbose # do not use : ,granularity=fine,compact #

# Disable Slurm CPU binding
export SLURM_CPU_BIND=NONE

cp temp/namelist.realexe namelist.input

perl -pi -e "s/nproc_x                  = -1,/nproc_x                  = ${nprocx},/" namelist.input
perl -pi -e "s/nproc_y                  = -1,/nproc_y                  = ${nprocy},/" namelist.input
perl -pi -e "s/nio_tasks_per_group      = 0,/nio_tasks_per_group      = ${niot},/" namelist.input
perl -pi -e "s/nio_groups               = 1,/nio_groups               = ${niog},/" namelist.input

nodeset -e $SLURM_NODELIST | tr ' ' '\n' > ./hostfile.${SLURM_JOBID}

ml load mpi compiler
time mpiexec.hydra -bootstrap slurm -np 1248 -ppn 96 -hostfile ./hostfile.${SLURM_JOBID} ./wrf.exe

cp namelist.input temp/namelist.wrfexe
cp rsl.out.0000 temp/rsl.out.0000.wrfexe
cp rsl.error.0000 temp/rsl.error.0000.wrfexe

mv wrfout_* ${work_dir}/wrfprd
cp wrfinput_d0* ${work_dir}/rstprd
cp wrfbdy_d01 ${work_dir}/rstprd
mv wrfrst_* ${work_dir}/rstprd
mkdir -p ${out_dir}/${yyyy1}${mm1}${dd1}${cc}
cp ${work_dir}/wrfprd/wrfout_* ${out_dir}/${yyyy1}${mm1}${dd1}${cc}
