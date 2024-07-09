#!/bin/bash -l

### Job Name
#SBATCH --job-name pred

### Standard output and error
#SBATCH --output=./logs/%x.%j.out
#SBATCH --error=./logs/%x.%j.err

### Job resources, for mem use either
#SBATCH --partition=interactive
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=1
#SBATCH --mem=32000
#SBATCH --time=0-01:59:00
###SBATCH --nodes=2
###SBATCH --ntasks-per-node=5
###SBATCH --cpus-per-task=8
###SBATCH --mem=185000
###SBATCH --time=0-01:59:00

### Initial working dir, abs or rel to where sbatch is called from
#SBATCH --chdir ./

### Email notification
###SBATCH --mail-user=zekun.lou@mpsd.mpg.de
###SBATCH --mail-type=BEGIN,END,TIME_LIMIT_50,FAIL,ARRAY_TASKS

source /u/zklou/.env.salted.sh
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export MKL_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export NUMEXPR_NUM_THREADS=${SLURM_CPUS_PER_TASK}

srun python -m salted.prediction
srun python -m salted.aims.move_data_in