#!/bin/bash -l

### Job Name
#SBATCH --job-name rkhs

### Standard output and error
#SBATCH --output=./logs/%x.%j.out
#SBATCH --error=./logs/%x.%j.err

### Job resources, for mem use either
#SBATCH --partition=interactive
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=1
#SBATCH --mem=32000
###SBATCH --nodes=1
###SBATCH --ntasks-per-node=20
###SBATCH --cpus-per-task=2
###SBATCH --mem=85000
###SBATCH --time=0-07:59:00

### Initial working dir, abs or rel to where sbatch is called from
#SBATCH --chdir ./

### Wall clock limit (max is 24 hours):
#SBATCH --time=0-01:59:00

### Email notification
###SBATCH --mail-user=zekun.lou@mpsd.mpg.de
###SBATCH --mail-type=BEGIN,END,TIME_LIMIT_50,FAIL,ARRAY_TASKS

source /u/zklou/.env.salted.sh
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export MKL_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export NUMEXPR_NUM_THREADS=${SLURM_CPUS_PER_TASK}

cmd="python -m salted.rkhs_projector"
echo "$(date)"
echo "Running command: ${cmd}"
eval ${cmd}
wait

cmd="srun python -m salted.rkhs_vector"
echo "$(date)"
echo "Running command: ${cmd}"
eval ${cmd}
wait

echo "$(date)"
echo "All commands finished"
