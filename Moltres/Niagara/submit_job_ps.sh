#!/bin/bash
#SBATCH --job-name=moltres        # job name
#SBATCH --nodes=5                 # node
#SBATCH --ntasks=5                # total number of task
#SBATCH --cpus-per-task=1         # cpu-cores per task/process
#SBATCH --time=00:15:00           # total run time limit (HH:MM:SS)
#SBATCH --output=%x-%j.out        # output file name, %x = Job name, %j = jobid of the running job 
#SBATCH --error=%x-%j.err         # error file 
#SBATCH --account=def-piromh      # def-buijsa / def-piromh / rrg-piromh
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=abc@mcmaster.ca


module purge > /dev/null 2>&1
module load NiaEnv/2022a gcc/11.2.0 openmpi hdf5/1.12.3 python/3.11.5

source ~/openmc_dev/bin/activate

mpirun -n $SLURM_NTASKS $HOME/moltres/moltres-opt -i cnb.i --split-mesh 200 --split-file cnb_mesh 2>&1 | tee -a moltres.log

