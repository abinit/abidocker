# ABINIT MPI + OpenBLAS Docker Configuration (Ubuntu 24.04)

This Docker configuration builds ABINIT with MPI support and optimized OpenBLAS libraries on Ubuntu 24.04, using NVHPC 26.3, OpenMPI 4 and CUDA 13.1.

## Configuration Details

**Build Type**: MPI + netlib + CUDA (parallel,GPU)
**Base Image**: Ubuntu 24.04
**Compilers**: NVHPC 26.3 with MPI wrappers (mpif90, mpicc, mpic++)
**MPI Implementation**: OpenMPI 4 (default) or MPICH
**Parallelization**: MPI + OpenMP hybrid, GPU (CUDA)
**Linear Algebra**: Netlib (NVHPC provided)
**FFT**: FFTW3 (threaded)
**Mandatory Libraries**: LibXC, HDF5, NetCDF C/Fortran

## Build Instructions

### Basic Build

From the project root directory:

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu24.04-nvhpc-openmpi-netlib-cuda13-cmake/Dockerfile \
  -t abidocker/abinit:ubuntu24-mpi-openblas-cuda13 \
  .
```

### Build from Specific ABINIT Version

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu24.04-nvhpc-openmpi-netlib-cuda13-cmake/Dockerfile \
  --build-arg ABINIT_BRANCH=10.6.7 \
  -t abidocker/abinit:10.6.7-ubuntu24-mpi \
  .
```

### Build Without Tests (Faster)

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu24.04-nvhpc-openmpi-netlib-cuda13-cmake/Dockerfile \
  --build-arg RUN_TESTS=no \
  -t abidocker/abinit:ubuntu24-mpi-openblas-cuda13-notests \
  .
```

## Usage Instructions

### Run with MPI (Single Node)

```bash
docker run --rm \
  -v $(pwd):/workspace \
  abidocker/abinit:ubuntu24-mpi-openblas-cuda13 \
  mpirun -np 4 abinit input.in
```

### Run with MPI + OpenMP Hybrid

```bash
docker run --rm \
  -e OMP_NUM_THREADS=2 \
  -v $(pwd):/workspace \
  abidocker/abinit:ubuntu24-mpi-openblas-cuda13 \
  mpirun -np 4 abinit input.in
```

### Interactive Shell

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  abidocker/abinit:ubuntu24-mpi-openblas-cuda13 \
  /bin/bash
```

### Check Versions

```bash
docker run --rm abidocker/abinit:ubuntu24-mpi-openblas-cuda13 abinit --version
docker run --rm abidocker/abinit:ubuntu24-mpi-openblas-cuda13 mpirun --version
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
