#!/bin/bash
#SBATCH --job-name=moltres        # job name
#SBATCH --nodes=5                 # node
#SBATCH --ntasks=5                # total number of task
#SBATCH --cpus-per-task=1         # cpu-cores per task/process
#SBATCH --mem=5G                  # total memory per node
#SBATCH --time=00:15:00           # total run time limit (HH:MM:SS)
#SBATCH --output=%x-%j.out        # output file name, %x = Job name, %j = jobid of the running job 
#SBATCH --error=%x-%j.err         # error file 
#SBATCH --account=def-piromh      # def-buijsa / def-piromh / rrg-piromh
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=abc@mcmaster.ca


module purge > /dev/null 2>&1

module load StdEnv/2020
module load gcc/9.3.0
module load boost/1.80.0 eigen/3.4.0 glpk/5.0 xdrfile/1.1.4 hdf5-mpi cmake
module load python scipy-stack

cd $SLURM_SUBMIT_DIR

mpirun -n $SLURM_NTASKS $HOME/moltres/moltres-opt -i cnb.i --split-mesh 200 --split-file cnb_mesh 2>&1 | tee -a moltres.log
