# ABINIT MPI + OpenBLAS Docker Configuration (Ubuntu 22.04)

This Docker configuration builds ABINIT with MPI support and optimized OpenBLAS libraries on Ubuntu 22.04, using NVHPC 24.9, OpenMPI 4 and CUDA 11.8.

## Configuration Details

**Build Type**: MPI + OpenBLAS + CUDA (parallel,GPU)
**Base Image**: Ubuntu 22.04
**Compilers**: NVHPC 24.9 with MPI wrappers (mpif90, mpicc, mpic++)
**MPI Implementation**: OpenMPI 4 (default) or MPICH
**Parallelization**: MPI + OpenMP hybrid, GPU (CUDA)
**Linear Algebra**: OpenBLAS
**FFT**: FFTW3 (threaded)
**Mandatory Libraries**: LibXC, HDF5, NetCDF C/Fortran

## Build Instructions

### Basic Build

From the project root directory:

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu22.04-nvhpc-openmpi-netlib-cuda11/Dockerfile \
  -t abidocker/abinit:ubuntu22-mpi-openblas-cuda11 \
  .
```

### Build from Specific ABINIT Version

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu22.04-nvhpc-openmpi-netlib-cuda11/Dockerfile \
  --build-arg ABINIT_BRANCH=10.6.7 \
  -t abidocker/abinit:10.6.7-ubuntu22-mpi-openblas-cuda11 \
  .
```

### Build Without Tests (Faster)

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu22.04-nvhpc-openmpi-netlib-cuda11/Dockerfile \
  --build-arg RUN_TESTS=no \
  -t abidocker/abinit:ubuntu22-mpi-openblas-cuda11-notests \
  .
```

## Usage Instructions

### Run with MPI (Single Node)

```bash
docker run --rm \
  -v $(pwd):/workspace \
  abidocker/abinit:ubuntu22-mpi-openblas-cuda11 \
  mpirun -np 4 abinit input.in
```

### Run with MPI + OpenMP Hybrid

```bash
docker run --rm \
  -e OMP_NUM_THREADS=2 \
  -v $(pwd):/workspace \
  abidocker/abinit:ubuntu22-mpi-openblas-cuda11 \
  mpirun -np 4 abinit input.in
```

### Interactive Shell

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  abidocker/abinit:ubuntu22-mpi-openblas-cuda11 \
  /bin/bash
```

### Check Versions

```bash
docker run --rm abidocker/abinit:ubuntu22-mpi-openblas-cuda11 abinit --version
docker run --rm abidocker/abinit:ubuntu22-mpi-openblas-cuda11 mpirun --version
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
