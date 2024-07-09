#!/bin/bash -l

### Job Name
#SBATCH --job-name gen_trainset

### Standard output and error
###SBATCH --array=1-4
#SBATCH --output ./logs/%x.%A_%a.out
#SBATCH --error ./logs/%x.%A_%a.err

### Job resources, for mem use either
#SBATCH --partition=interactive
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem=32000
#SBATCH --time=0-01:59:00
###SBATCH --nodes=4
###SBATCH --ntasks-per-node=40
###SBATCH --mem=85000
###SBATCH --time=0-07:59:00

### Initial working dir, abs or rel to where sbatch is called from
#SBATCH --chdir ./

### Email notification
###SBATCH --mail-user=zekun.lou@mpsd.mpg.de
###SBATCH --mail-type=BEGIN,END,TIME_LIMIT_50,FAIL,ARRAY_TASKS

# check slurm settings
echo "SLURM_JOB_NAME: ${SLURM_JOB_NAME}"
echo "SLURM_ARRAY_JOB_ID: ${SLURM_ARRAY_JOB_ID}"
echo "SLURM_ARRAY_TASK_ID: ${SLURM_ARRAY_TASK_ID}"
echo "SLURM_JOB_ID: ${SLURM_JOB_ID}"
echo "SLURM_JOB_PARTITION: ${SLURM_JOB_PARTITION}"
echo "SLURM_JOB_NODELIST: ${SLURM_JOB_NODELIST}"
echo "SLURM_MEM_PER_NODE: ${SLURM_MEM_PER_NODE}"
if [[ -z ${SLURM_ARRAY_TASK_ID} ]]; then
    echo "SLURM_ARRAY_TASK_ID is empty"
    SLURM_MY_ID=${SLURM_JOB_ID}
else
    SLURM_MY_ID=${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}
fi
echo "SLURM_MY_ID: ${SLURM_MY_ID}"

if [[ -z ${SLURM_ARRAY_TASK_ID} ]]; then
    echo "SLURM_ARRAY_TASK_ID is empty, set to 1"
    SLURM_ARRAY_TASK_ID=1
fi

# ${SLURM_ARRAY_TASK_ID} starts from 1
EXPAND_COEFF=25  # N calculations in one job
echo "EXPAND_COEFF: ${EXPAND_COEFF}"

# first calculation
# e.g. if SLURM_ARRAY_TASK_ID=3, then (3-1)*8+1=17, 3*8=24, idx=17..24
_CAL_START_IDX=$(((${SLURM_ARRAY_TASK_ID}-1)*${EXPAND_COEFF}+1))
_CAL_END_IDX=$((${SLURM_ARRAY_TASK_ID}*${EXPAND_COEFF}))
CAL_IDXES=$(seq ${_CAL_START_IDX} ${_CAL_END_IDX})  # first calculation



# # # calculate DNF calculations
# CAL_IDXES=(494 )  # this should be a list
# # DNF_list=(151 157 176 230 285 301 314 448 454)  # cnt=???
# # # slice the array
# # _CAL_START_IDX=$(((${SLURM_ARRAY_TASK_ID}-1)*${EXPAND_COEFF}))  # array starts from 1
# # CAL_IDXES=${DNF_list[@]:${_CAL_START_IDX}:${EXPAND_COEFF}}

echo "CAL_IDXES: ${CAL_IDXES}"


######## RUN AIMS ################################

source /u/zklou/.env.aims.sh
export OMP_NUM_THREADS=1
ulimit -s unlimited

ROOTDIR=$(realpath ./)
DATADIR=$(realpath ./)/qmdata/aims_pred_data  # for generating prediction dataset targets
# DATADIR=$(realpath ./)/qmdata/data  # for generating training dataset
# AIMS=/u/zklou/projects/aims/FHI-aims_clean/bin/aims.240507.compile_240524.scalapack.mpi.x
echo "root directory: ${ROOTDIR}"
echo "data directory: ${DATADIR}"
echo "aims binary: ${AIMS}"

# count geoms, files should end with .in
TOTAL_GEOMS=0
for file in ${DATADIR}/geoms/*; do
    # should be a file, and file should end with .in
    if [[ -f "$file" && "$file" == *.in ]]; then
        ((TOTAL_GEOMS++))
    fi
done
echo "number of total geoms: ${TOTAL_GEOMS}"


for cal_idx in ${CAL_IDXES}; do
    echo -e "\n\n\n\n"

    cd ${ROOTDIR}
    echo "calculate number ${cal_idx}"

    if [[ ${cal_idx} -gt ${TOTAL_GEOMS} ]]; then
        echo "calculate index ${cal_idx} is larger than number of geoms ${TOTAL_GEOMS}"
        continue
    fi

    mkdir -p ${DATADIR}/${cal_idx}
    cp ${ROOTDIR}/control.in ${DATADIR}/${cal_idx}/control.in
    cp ${DATADIR}/geoms/${cal_idx}.in ${DATADIR}/${cal_idx}/geometry.in
    cd ${DATADIR}/${cal_idx}
    echo "cwd: $(pwd)"

    echo "run aims"
    srun ${AIMS} > aims.out

    if [[ -f rho_rebuilt_ri.out ]]; then
        mv rho_rebuilt_ri.out rho_df.out
    else
        echo "WARNING: rho_rebuilt_ri.out does not exist"
    fi

    if [[ -f ri_restart_coeffs.out ]]; then
        mv ri_restart_coeffs.out ri_restart_coeffs_df.out
    else
        echo "WARNING: ri_restart_coeffs.out does not exist"
    fi

    if [[ $(grep -c "Have a nice day" aims.out) -eq 0 ]]; then
        echo "ERROR!!!!!! ${cal_idx}: not finished"
    fi
done

