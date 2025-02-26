#!/bin/bash

# options
OPENMC_VERSION="develop"     # develop, v0.15.0, v0.14.0, v0.13.3 etc.
DATA_LIBRARY="endfb-vii.1"   # endfb-vii.1,or endfb-viii.0
INSTALL_DIR="$HOME/code"

# Data library URL and cross sections file path
if [[ "$DATA_LIBRARY" == "endfb-vii.1" ]]; then
  DATA_URL="https://anl.box.com/shared/static/9igk353zpy8fn9ttvtrqgzvw1vtejoz6.xz"
  CROSS_SECTIONS_DIR="endfb-vii.1-hdf5"
elif [[ "$DATA_LIBRARY" == "endfb-viii.0" ]]; then
  DATA_URL="https://anl.box.com/shared/static/uhbxlrx7hvxqw27psymfbhi7bx7s6u6a.xz"
  CROSS_SECTIONS_DIR="endfb-viii.0-hdf5"
else
  echo "Invalid DATA_LIBRARY specified. Use 'endfb-vii.1' or 'endfb-viii.0'."
  exit 1
fi

# Load required modules
module purge > /dev/null 2>&1
module load python/3.11.5 hdf5-mpi/1.14.2 cmake

# Clone openmc repo
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"
git clone https://github.com/openmc-dev/openmc.git --single-branch -b "$OPENMC_VERSION"

# Build and install
mkdir -p openmc/build && cd openmc/build
cmake -DCMAKE_C_COMPILER=mpicc \
      -DCMAKE_CXX_COMPILER=mpicxx \
      -DHDF5_PREFER_PARALLEL=on \
      -DOPENMC_USE_MPI=ON \
      -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
      ../

make -j 8 install

echo 'export PATH=$PATH:'"$INSTALL_DIR/bin" >> "$HOME/.bashrc"

# Set up virtual environment
cd "$INSTALL_DIR"/openmc
python -m venv $INSTALL_DIR/openmc_dev
source $INSTALL_DIR/openmc_dev/bin/activate
pip install msgpack packaging "cython<3.0" "numpy<2.0"
MPICC="mpicc" pip install --no-cache-dir --no-binary=mpi4py mpi4py
HDF5_MPI="ON" CC=mpicc pip install --no-cache-dir --no-build-isolation --no-deps --no-binary=h5py h5py
pip install .

# search for cross_sections.xml file
CROSS_SECTIONS_FILE=$(basename "$(find $HOME -name "cross_sections.xml" 2>/dev/null | head -n 1)")

if [[ -n "$CROSS_SECTIONS_FILE" ]]; then
  echo "Found existing cross_sections.xml file."
  echo "Skipping data library installation."
else
  # Download and install data library
  CROSS_SECTIONS_FILE="$INSTALL_DIR/$CROSS_SECTIONS_DIR/cross_sections.xml"
  echo "Downloading and extracting $DATA_LIBRARY data library..."
  wget -q -O - "$DATA_URL" | tar -C "$INSTALL_DIR" -xJ

  echo "export OPENMC_CROSS_SECTIONS=$CROSS_SECTIONS_FILE" >> "$HOME/.bashrc"
  echo "Data library installed and OPENMC_CROSS_SECTIONS env variable added to .bashrc."
fi

echo "OpenMC installation complete."
