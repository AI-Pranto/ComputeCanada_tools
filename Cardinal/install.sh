#!/bin/bash

# cluster name
CLUSTER_NAME=$(echo $CC_CLUSTER)

module purge > /dev/null 2>&1
module load StdEnv/2023
module load python/3.11.5 scipy-stack/2023b eigen/3.4.0 boost/1.85.0 petsc
    
export ENABLE_NEK=false
export ENABLE_DAGMC=yes
export ENABLE_DOUBLE_DOWN=yes

export LIBMESH_JOBS=8
export MOOSE_JOBS=8
export JOBS=8

export HDF5_DIR=$EBROOTHDF5
export HDF5_ROOT=$EBROOTHDF5

# Clone Cardinal repository
cd $HOME
if [ ! -d "cardinal" ]; then
    git clone https://github.com/neams-th-coe/cardinal.git
else
    echo "Cardinal repository already exists. Skipping clone."
fi

cd $HOME/cardinal
./scripts/get-dependencies.sh

# Build libMesh
./contrib/moose/scripts/update_and_rebuild_libmesh.sh --with-xdr-include=$EBROOTGENTOO/include/tirpc --with-glpk-include=$EBROOTGENTOO/include --with-eigen-include=$EBROOTEIGEN/include

# Set libMesh environment variables
echo "export LIBMESH_DIR=$HOME/cardinal/contrib/moose/libmesh/installed" >> $HOME/.bashrc
echo "export MOOSE_DIR=$HOME/cardinal_stdenv2023/cardinal/contrib/moose" >> $HOME/.bashrc
echo "export HDF5_ROOT=$EBROOTHDF5" >> $HOME/.bashrc
echo "export HDF5_DIR=$EBROOTHDF5" >> $HOME/.bashrc

source $HOME/.bashrc

# Build Wasp
./contrib/moose/scripts/update_and_rebuild_wasp.sh

# Compile Cardinal
make -j20 MAKEFLAGS=-j20

echo "Cardinal installation complete."
