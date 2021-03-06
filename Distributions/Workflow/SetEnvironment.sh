#!/bin/bash

export WEAKLIB_MACHINE=$1

if [[ $WEAKLIB_MACHINE == titan* ]]; then

  echo
  echo "INFO: Setting environment for" $WEAKLIB_MACHINE

  source ${MODULESHOME}/init/bash

  module unload fftw cray-hdf5 cray-petsc silo subversion
  module unload pgi gcc cce pathscale
  module unload PrgEnv-pgi PrgEnv-gnu PrgEnv-cray PrgEnv-pathscale PrgEnv-intel

elif [[ $WEAKLIB_MACHINE == darter* ]]; then

  echo
  echo "INFO: Setting environment for" $WEAKLIB_MACHINE

  module unload fftw cray-hdf5 cray-petsc
  module unload pgi gcc cce intel
  module unload PrgEnv-pgi PrgEnv-gnu PrgEnv-cray PrgEnv-intel

elif [[ $WEAKLIB_MACHINE == beacon* ]]; then

  echo
  echo "INFO: Setting environment for" $WEAKLIB_MACHINE

  module unload pgi gcc cce intel
  module unload PE-gnu PE-intel

elif [[ $WEAKLIB_MACHINE == sn1987b* ]]; then

  echo
  echo "INFO: Setting environment for" $WEAKLIB_MACHINE

elif [[ $WEAKLIB_MACHINE == ranchu* ]]; then

  echo
  echo "INFO: Setting environment for" $WEAKLIB_MACHINE

elif [[ $WEAKLIB_MACHINE == ranchuair* ]]; then

  echo
  echo "INFO: Setting environment for" $WEAKLIB_MACHINE

elif [[ $WEAKLIB_MACHINE == sjdunham* ]]; then

echo
echo "INFO: Setting environment for" $WEAKLIB_MACHINE

fi


if [[ $WEAKLIB_MACHINE == titan_gnu ]]; then

  echo

  module load PrgEnv-gnu
  module load cray-hdf5
  module load subversion

elif [[ $WEAKLIB_MACHINE == titan_cray ]]; then

  echo

  module load PrgEnv-cray
  module load cray-hdf5
  module load subversion

elif [[ $WEAKLIB_MACHINE == titan_pgi ]]; then

  echo

  module load PrgEnv-pgi
  module load cray-hdf5
  module load subversion

elif [[ $WEAKLIB_MACHINE == darter_gnu ]]; then

  echo

  module load PrgEnv-gnu
  module load cray-hdf5

elif [[ $WEAKLIB_MACHINE == darter_cray ]]; then

  echo

  module load PrgEnv-cray
  module load cray-hdf5

elif [[ $WEAKLIB_MACHINE == beacon_intel ]]; then

  echo

  module load PE-intel
  module load hdf5/1.8.14

elif [[ $WEAKLIB_MACHINE == sn1987b ]]; then

  echo

elif [[ $WEAKLIB_MACHINE == ranchu ]]; then

  echo

elif [[ $WEAKLIB_MACHINE == ranchuair ]]; then

  echo

elif [[ $WEAKLIB_MACHINE == sjdunham ]]; then

echo

else

  echo "  WARNING: Unknown machine " $WEAKLIB_MACHINE

fi
