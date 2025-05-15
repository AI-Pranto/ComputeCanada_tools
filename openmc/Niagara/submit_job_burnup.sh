#!/bin/bash
#SBATCH --job-name=burnup         # job name
#SBATCH --nodes=2                 # node
#SBATCH --ntasks-per-node=2       # number of task per node
#SBATCH --cpus-per-task=20        # cpu-cores per task/process
#SBATCH --time=00:20:00           # total run time limit (HH:MM:SS)
#SBATCH --output=%x-%j.out        # output file name, %x = Job name, %j = jobid of the running job 
#SBATCH --error=%x-%j.err         # error file 
#SBATCH --account=def-piromh      # def-buijsa / def-piromh / rrg-piromh
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=abc@mcmaster.ca

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module purge > /dev/null 2>&1
module load NiaEnv/2022a gcc/11.2.0 openmpi hdf5/1.12.3 python/3.11.5

source $HOME/openmc_dev/bin/activate

# MPI transport settings to resolve communication issues
export OMPI_MCA_btl=self,tcp

cd $SLURM_SUBMIT_DIR

srun python -m mpi4py run_depletion.py 2>&1 | tee -a runtime.log

