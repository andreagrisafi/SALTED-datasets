#!/bin/bash -l

### Job Name
#SBATCH --job-name run_aims_pred

### Standard output and error
###SBATCH --array=1-10
#SBATCH --output ./logs/%x.%A_%a.out
#SBATCH --error ./logs/%x.%A_%a.err

### Job resources, for mem use either
#SBATCH --partition=interactive
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem=32000
#SBATCH --time=0-01:59:00
###SBATCH --nodes=8
###SBATCH --ntasks-per-node=40
###SBATCH --mem=185000
###SBATCH --time=0-23:59:00

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


cal_idx=${SLURM_ARRAY_TASK_ID}
echo "SLURM_ARRAY_TASK_ID: ${SLURM_ARRAY_TASK_ID}"
echo "calculate number ${cal_idx}"

source /u/zklou/.env.aims.sh
export OMP_NUM_THREADS=1
ulimit -s unlimited

DATADIR=$(realpath ./qmdata/aims_pred_data)
# AIMS=/u/zklou/projects/aims/FHI-aims_clean/bin/aims.240507.compile_240524.scalapack.mpi.x

echo "data directory: ${DATADIR}"

# count geoms, files should end with .in
n=0
for file in "${DATADIR}"/geoms/*; do
	# should be a file, and file should end with .in
	if [[ -f "$file" && "$file" == *.in ]]; then
		((n++))
	fi
done
echo "number of total geoms: $n"

if [[ ${cal_idx} -gt $n ]]; then
    echo "calculate index ${cal_idx} is larger than number of geoms $n"
    exit 1
fi

task_dir=${DATADIR}/${SLURM_ARRAY_TASK_ID}

mkdir -p ${task_dir}
cp ${DATADIR}/../../control_read.in ${task_dir}/control.in
cp ${DATADIR}/geoms/${cal_idx}.in ${task_dir}/geometry.in

cd ${task_dir}
echo "pwd: $(pwd)"

if [[ -f "ri_restart_coeffs_predicted.out" ]]; then
	echo "ri_restart_coeffs_predicted.out exists"
	cp ri_restart_coeffs_predicted.out ri_restart_coeffs.out  # for debug rerun, use cp instead of mv
else
	echo "ri_restart_coeffs_predicted.out does not exist! please run salted.aims.move_data_in first"
	exit 1
fi

echo "run FHI-aims"
srun ${AIMS} > aims_predict.out

wait

mv rho_rebuilt_ri.out rho_ml.out
mv ri_restart_coeffs.out ri_restart_coeffs_ml.out
