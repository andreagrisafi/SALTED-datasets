#!/bin/bash -l

### Job Name
#SBATCH --job-name dcpt

### Standard output and error
#SBATCH --output=./logs/%x.%j.out
#SBATCH --error=./logs/%x.%j.err

### Job resources, for mem use either
#SBATCH --partition=interactive
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=2
#SBATCH --mem=32000
#SBATCH --time=0-01:59:00
###SBATCH --nodes=1
###SBATCH --ntasks-per-node=4
###SBATCH --cpus-per-task=10
###SBATCH --mem=185000
###SBATCH --time=0-01:59:00


### Initial working dir, abs or rel to where sbatch is called from
#SBATCH --chdir ./

### Wall clock limit (max is 24 hours):

### Email notification
###SBATCH --mail-user=zekun.lou@mpsd.mpg.de
###SBATCH --mail-type=BEGIN,END,TIME_LIMIT_50,FAIL,ARRAY_TASKS

source /u/zklou/.env.salted.sh
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export MKL_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export NUMEXPR_NUM_THREADS=${SLURM_CPUS_PER_TASK}

cmd="python -m salted.initialize"
echo "$(date)"
echo "Running command: ${cmd}"
eval ${cmd}
wait

cmd="python -m salted.sparse_selection"
echo "$(date)"
echo "Running command: ${cmd}"
eval ${cmd}
wait

cmd="srun python -m salted.sparse_descriptor"
echo "$(date)"
echo "Running command: ${cmd}"
eval ${cmd}
wait

echo "$(date)"
echo "All commands finished"
