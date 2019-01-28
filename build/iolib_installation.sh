#!/bin/bash -l

#
# Sources for all libraries used in this script can be found at
# http://www2.mmm.ucar.edu/people/duda/files/mpas/sources/ 
#

module purge
export PATH=/glade/work/ssuresh/1810pgi/linux86-64/18.10/bin/:$PATH
export LD_LIBRARY_PATH=/glade/work/ssuresh/1810pgi/linux86-64/18.10/lib/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/glade/work/ssuresh/1810pgi/openmpi/lib/:$LD_LIBRARY_PATH
export PATH=/glade/work/ssuresh/1810pgi/openmpi/bin/:$PATH

#export PATH=/glade/u/apps/dav/opt/pgi/18.4/linux86-64/18.4//bin/:$PATH
#export LD_LIBRARY_PATH=/glade/u/apps/dav/opt/pgi/18.4/linux86-64/18.4//lib/:$LD_LIBRARY_PATH
#export LD_LIBRARY_PATH=/glade/u/apps/dav/opt/pgi/18.4/linux86-64/18.4/mpi/openmpi-2.1.2/lib/:$LD_LIBRARY_PATH
#export PATH=/glade/u/apps/dav/opt/pgi/18.4/linux86-64/18.4//mpi/openmpi-2.1.2/bin/:$PATH

# Where to find sources for libraries
export LIBSRC=/glade/work/ssuresh/1810pgi/pgi1810_lib/sources

# Where to install libraries
export LIBBASE=/glade/work/ssuresh/1810pgi/pgi1810_lib/libs-pgi1810/

# Compilers
export SERIAL_FC=pgf90
export SERIAL_F77=pgf90
export SERIAL_CC=pgcc
export SERIAL_CXX=pgc++
export MPI_FC=mpif90
export MPI_F77=mpif77
export MPI_CC=mpicc
export MPI_CXX=mpicxx


export CC=$SERIAL_CC
export CXX=$SERIAL_CXX
export F77=$SERIAL_F77
export FC=$SERIAL_FC
unset F90  # This seems to be set by default on NCAR's Cheyenne and is problematic
unset F90FLAGS

which mpif90

########################################
# zlib
########################################
tar xzvf ${LIBSRC}/zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure --prefix=${LIBBASE} --static
make
make install
cd ..
rm -rf zlib-1.2.11

########################################
# HDF5
########################################
tar xjvf ${LIBSRC}/hdf5-1.8.20.tar.bz2
cd hdf5-1.8.20
export FC=$MPI_FC
export CC=$MPI_CC
export CXX=$MPI_CXX
./configure --prefix=${LIBBASE} --enable-parallel --with-zlib=${LIBBASE} --disable-shared
make
make check
make install
cd ..
rm -rf hdf5-1.8.20

########################################
# Parallel-netCDF
########################################
tar xzvf ${LIBSRC}/parallel-netcdf-1.9.0.tar.gz
cd parallel-netcdf-1.9.0
export CC=$SERIAL_CC
export CXX=$SERIAL_CXX
export F77=$SERIAL_F77
export FC=$SERIAL_FC
export MPICC=$MPI_CC
export MPICXX=$MPI_CXX
export MPIF77=$MPI_F77
export MPIF90=$MPI_FC
### Will also need gcc in path
./configure --prefix=${LIBBASE}
make
make testing
make install
export PNETCDF=${LIBBASE}
cd ..
rm -rf parallel-netcdf-1.9.0

########################################
# netCDF (C library)
########################################
tar xzvf ${LIBSRC}/netcdf-4.6.1.tar.gz
cd netcdf-c-4.6.1
export CPPFLAGS="-I${LIBBASE}/include"
export LDFLAGS="-L${LIBBASE}/lib"
export LIBS="-lhdf5_hl -lhdf5 -lz -ldl"
export CC=$MPI_CC
./configure --prefix=${LIBBASE} --disable-dap --enable-netcdf4 --enable-pnetcdf --enable-cdf5 --enable-parallel-tests --disable-shared
make
make check
make install
export NETCDF=${LIBBASE}
cd ..
rm -rf netcdf-c-4.6.1

########################################
# netCDF (Fortran interface library)
########################################
tar xzvf ${LIBSRC}/netcdf-fortran-4.4.4.tar.gz
cd netcdf-fortran-4.4.4
export FC=$MPI_FC
export F77=$MPI_F77
export LIBS="-lnetcdf ${LIBS}"
./configure --prefix=${LIBBASE} --enable-parallel-tests --disable-shared
make
make check
make install
cd ..
rm -rf netcdf-fortran-4.4.4

########################################
# PIO
########################################
git clone https://github.com/NCAR/ParallelIO
cd ParallelIO
export PIOSRC=`pwd`
cd ..
mkdir pio
cd pio
export CC=$MPI_CC
export FC=$MPI_FC
cmake -DNetCDF_C_PATH=$NETCDF -DNetCDF_Fortran_PATH=$NETCDF -DPnetCDF_PATH=$PNETCDF -DCMAKE_INSTALL_PREFIX=$LIBBASE -DPIO_ENABLE_TIMING=OFF $PIOSRC
make
make install
cd ..
rm -rf pio ParallelIO
export PIO=$LIBBASE

########################################
# Other environment vars needed by MPAS
########################################
export MPAS_EXTERNAL_LIBS="-L${LIBBASE}/lib -lhdf5_hl -lhdf5 -ldl -lz"
export MPAS_EXTERNAL_INCLUDES="-I${LIBBASE}/include"
