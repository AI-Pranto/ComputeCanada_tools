#!/bin/bash

# cluster name
CLUSTER_NAME=$(echo $CC_CLUSTER)

# Load modules based on cluster
if [[ "$CLUSTER_NAME" == "niagara" ]]; then
    echo "Detected Niagara cluster. Loading Niagara-specific modules..."
    module purge > /dev/null 2>&1
    module load NiaEnv/2022a
    module load gcc/11.2.0 openmpi hdf5-mpi/1.12.2 python/3.11.5 cmake
else
    echo "Detected non-Niagara cluster. Loading standard Compute Canada modules..."
    module load StdEnv/2020
    module load gcc/9.3.0
    module load boost/1.80.0 eigen/3.4.0 glpk/5.0 xdrfile/1.1.4 hdf5-mpi cmake
    module load python scipy-stack
    
    export EIGEN_INC=$EBROOTEIGEN/include
    export GLPK_DIR=$EBROOTGLPK
    export CPPFLAGS=${CPPFLAGS:+$CPPFLAGS }-I$EBROOTGENTOO/include/tirpc
fi

# Clone Moltres repository
cd $HOME
if [ ! -d "moltres" ]; then
    git clone https://github.com/arfc/moltres.git
else
    echo "Moltres repository already exists. Skipping clone."
fi
cd $HOME/moltres
git submodule update --init squirrel
git submodule update --init moose

# Build PETSc
MOOSE_JOBS=16 ./moose/scripts/update_and_rebuild_petsc.sh

# Set PETSc environment variables
export PETSC_DIR=$HOME/moltres/moose/petsc
export PETSC_ARCH=arch-moose
echo "export PETSC_DIR=$HOME/moltres/moose/petsc" >> $HOME/.bashrc
echo "export PETSC_ARCH=arch-moose" >> $HOME/.bashrc

source $HOME/.bashrc

# Build libMesh
MOOSE_JOBS=16 ./moose/scripts/update_and_rebuild_libmesh.sh

# Set libMesh environment variables
export LIBMESH_DIR=$HOME/moltres/moose/libmesh/installed
export MOOSE_DIR=$HOME/moltres/moose
echo "export LIBMESH_DIR=$HOME/moltres/moose/libmesh/installed" >> $HOME/.bashrc
echo "export MOOSE_DIR=$HOME/moltres/moose" >> $HOME/.bashrc

source $HOME/.bashrc

# Build Wasp
MOOSE_JOBS=16 ./moose/scripts/update_and_rebuild_wasp.sh

# Compile Moltres
make -j20 MAKEFLAGS=-j20

echo "Moltres installation complete."
