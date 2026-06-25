# ABINIT MPI + OpenBLAS Docker Configuration (Ubuntu 26.04)

This Docker configuration builds ABINIT with MPI support and optimized OpenBLAS libraries on Ubuntu 26.04, using GCC 15, OpenMPI 5 and CUDA 13.

## Configuration Details

**Build Type**: MPI + OpenBLAS (parallel)
**Base Image**: Ubuntu 26.04
**Compilers**: GCC 15 with MPI wrappers (mpif90, mpicc, mpic++)
**MPI Implementation**: OpenMPI 5 (default) or MPICH
**Parallelization**: MPI + OpenMP hybrid, CUDA (experiemental)
**Linear Algebra**: OpenBLAS + ScaLAPACK
**FFT**: FFTW3 (threaded)
**Mandatory Libraries**: LibXC, HDF5, NetCDF C/Fortran

## Differences from Ubuntu 22.04

- GCC 15 (was GCC 11)
- OpenMPI 5 (was OpenMPI 4)
- Explicit FFTW3 threaded libraries required (`FFTW3_LIBS="-lfftw3_threads -lfftw3f_threads -lfftw3 -lfftw3f"`)
- Updated runtime library package names (e.g. `libhdf5-310`, `libnetcdf22`, `libgfortran-15-dev`)

## Build Instructions

### Basic Build

From the project root directory:

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu26.04-gcc-openmpi-openblas-cuda/Dockerfile \
  -t abidocker/abinit:ubuntu26-mpi-openblas-cuda13 \
  .
```

### Build from Specific ABINIT Version

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu26.04-gcc-openmpi-openblas-cuda/Dockerfile \
  --build-arg ABINIT_BRANCH=10.6.7 \
  -t abidocker/abinit:10.6.7-ubuntu26-mpi \
  .
```

### Build Without Tests (Faster)

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu26.04-gcc-openmpi-openblas-cuda/Dockerfile \
  --build-arg RUN_TESTS=no \
  -t abidocker/abinit:ubuntu26-mpi-openblas-cuda13-notests \
  .
```

## Usage Instructions

### Run with MPI (Single Node)

```bash
docker run --rm \
  -v $(pwd):/workspace \
  abidocker/abinit:ubuntu26-mpi-openblas-cuda13 \
  mpirun -np 4 abinit input.in
```

### Run with MPI + OpenMP Hybrid

```bash
docker run --rm \
  -e OMP_NUM_THREADS=2 \
  -v $(pwd):/workspace \
  abidocker/abinit:ubuntu26-mpi-openblas-cuda13 \
  mpirun -np 4 abinit input.in
```

### Interactive Shell

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  abidocker/abinit:ubuntu26-mpi-openblas-cuda13 \
  /bin/bash
```

### Check Versions

```bash
docker run --rm abidocker/abinit:ubuntu26-mpi-openblas-cuda13 abinit --version
docker run --rm abidocker/abinit:ubuntu26-mpi-openblas-cuda13 mpirun --version
```

## Build Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `ABINIT_REPO` | `https://github.com/abinit/abinit.git` | Git repository URL |
| `ABINIT_BRANCH` | `master` | Git branch or tag to checkout |
| `RUN_TESTS` | `yes` | Run test suite during build (`yes`/`no`) |
| `TEST_SUITE` | `paral` | Test suite name (`paral`/`v1`/`v2`/etc) |
| `MPI_IMPL` | `openmpi` | MPI implementation (`openmpi`/`mpich`) |
| `NUM_MPI_PROCS` | `4` | Number of MPI processes for testing |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PATH` | `/opt/abinit/bin:$PATH` | Includes ABINIT binaries |
| `ABI_PSPDIR` | `/opt/abinit/tests/Pspdir` | Pseudopotential directory |
| `OMP_NUM_THREADS` | `1` | OpenMP thread count |
| `OMPI_ALLOW_RUN_AS_ROOT` | `1` | Allow MPI as root (Docker) |
| `OMPI_MCA_btl_vader_single_copy_mechanism` | `none` | Fix OpenMPI in containers |
