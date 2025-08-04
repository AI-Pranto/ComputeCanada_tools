#!/bin/bash
#SBATCH --job-name=dh             # job name
#SBATCH --nodes=2                 # node
#SBATCH --ntasks-per-node=2       # number of task per node
#SBATCH --cpus-per-task=20        # cpu-cores per task/process
#SBATCH --mem=20G                 # memory per node
#SBATCH --time=00:20:00          # total run time limit (HH:MM:SS)
#SBATCH --output=%x-%j.out        # output file name, %x = Job name, %j = jobid of the running job 
#SBATCH --error=%x-%j.err         # error file 
#SBATCH --account=rrg-piromh      # def-buijsa / def-piromh / rrg-piromh
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=abc@mcmaster.ca

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module purge > /dev/null 2>&1
module load python/3.11.5
module load hdf5-mpi/1.14.2

source $HOME/openmc_dev/bin/activate

python -u dh.py 2>&1 | tee -a runtime.log
