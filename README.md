# AbiDocker

## Goals

This project is to build Docker images for ABINIT.

- **build-environment/**: Dockerfiles for the software environment in which ABINIT can be built and run. Does NOT include ABINIT source code or build process.
- **with-abinit/**: Dockerfiles with ABINIT installed (built from specific git versions/branches).
- **abibuildbotworker/**: Dockerfiles for making AbiBuildbot workers for the AbiBuildbot CI system.

Large language models (LLMs) are used to generate Dockerfiles for the above three goals. The agent skills are designed to generate Dockerfiles, where template Dockerfiles are used as example inputs, and instructions are given to generate Dockerfiles for each goal.

## Naming Convention

Docker images follow the pattern:
- Build environment: `abidocker/abienv:<os>-<compiler>-<mpi>-<mathlib>`
- ABINIT installed: `abidocker/abinit:<os>-<compiler>-<mpi>-<mathlib>-<version>`
- AbiBuildbot worker: `abidocker/abibuildbotworker:<os>-<compiler>-<mpi>-<mathlib>`

## Directory Structure

```
dockerfiles/
├── build-environment/                    # Software environments for building/running ABINIT
│   ├── ubuntu22.04-gcc-netlib/         # Serial build (no MPI)
│   │   ├── Dockerfile
│   │   ├── install-deps.sh             # Ubuntu 22.04 dependencies
│   │   └── README.md
│   ├── ubuntu22.04-gcc-openmpi-openblas/  # MPI build with OpenBLAS
│   │   ├── Dockerfile
│   │   ├── install-deps.sh             # Ubuntu 22.04 dependencies
│   │   └── README.md
│   ├── ubuntu26.04-gcc-openmpi-openblas/  # MPI build with OpenBLAS
│   │   ├── Dockerfile
│   │   ├── install-deps.sh             # Ubuntu 26.04 dependencies
│   │   └── README.md
│   ├── ubuntu22.04-nvhpc-openmpi-netlib-cuda11/  # MPI build with CUDA 11
│   │   ├── Dockerfile
│   │   ├── install-deps.sh             # Ubuntu 22.04 dependencies
│   │   └── README.md
│   ├── ubuntu24.04-nvhpc-openmpi-netlib-cuda12/  # MPI build with CUDA 12
│   │   ├── Dockerfile
│   │   ├── install-deps.sh             # Ubuntu 24.04 dependencies
│   │   └── README.md
│   ├── ubuntu24.04-nvhpc-openmpi-netlib-cuda13-cmake/  # MPI build with CUDA 13 (CMake buildsystem)
│   │   ├── Dockerfile
│   │   ├── install-deps.sh             # Ubuntu 24.04 dependencies
│   │   └── README.md
│   └── ubuntu26.04-intel-oneapi-mkl/   # MPI build with Intel oneAPI and MKL
│       ├── Dockerfile
│       ├── install-deps.sh             # Ubuntu 26.04 Intel oneAPI dependencies
│       └── README.md
├── with-abinit/                        # ABINIT pre-installed images
│   └── README.md                       # Template and documentation
└── abibuildbotworker/                  # AbiBuildbot CI worker images
    ├── README.md                       # Template and documentation
    ├── ubuntu22.04-gcc-openmpi-openblas/  # MPI worker with OpenBLAS
    ├── ubuntu26.04-gcc-openmpi-openblas/  # MPI worker with OpenBLAS
    └── ubuntu26.04-intel-oneapi-mkl/   # MPI worker with Intel oneAPI and MKL
```

## The List of Dockerfiles

### Build Environments

Software environments for building and running ABINIT (without ABINIT pre-installed).

| OS | Compiler | MPI | Math Lib | FFTW | LibXC | HDF5 | NetCDF | Directory | Description | Status |
|----|----------|-----|----------|------|-------|------|--------|-----------|-------------|--------|
| Ubuntu 22.04 | GCC | None | Netlib BLAS/LAPACK | FFTW3 | Yes | Yes | Yes (Fortran) | `build-environment/ubuntu22.04-gcc-netlib/` | Minimal serial build environment with basic libraries | Available |
| Ubuntu 22.04 | GCC | OpenMPI 4.x | OpenBLAS + ScaLAPACK | FFTW3 | Yes | Yes | Yes (Fortran) | `build-environment/ubuntu22.04-gcc-openmpi-openblas/` | MPI parallel build with optimized linear algebra | Available |
| Ubuntu 26.04 | GCC | OpenMPI 5.x | OpenBLAS + ScaLAPACK | FFTW3 | Yes | Yes | Yes (Fortran) | `build-environment/ubuntu26.04-gcc-openmpi-openblas/` | MPI parallel build with current Ubuntu GCC/OpenMPI packages | Available |
| Ubuntu 26.04 | Intel oneAPI | Intel MPI | Intel oneMKL | DFTI (MKL) | Yes | Yes | Yes (Fortran) | `build-environment/ubuntu26.04-intel-oneapi-mkl/` | MPI parallel build with Intel ifx, Intel MPI, and MKL | Available |
| Ubuntu 22.04 | NVHPC SDK | OpenMPI | Netlib + ScaLAPACK + CUDA 11 | FFTW3 | Yes | Yes | Yes (Fortran) | `build-environment/ubuntu22.04-nvhpc-openmpi-netlib-cuda11/` | MPI parallel build targeting NVIDIA GPUs | Available |
| Ubuntu 24.04 | NVHPC SDK | OpenMPI | Netlib + ScaLAPACK + CUDA 12 | FFTW3 | Yes | Yes | Yes (Fortran) | `build-environment/ubuntu24.04-nvhpc-openmpi-netlib-cuda12/` | MPI parallel build targeting NVIDIA GPUs | Available |
| Ubuntu 24.04 | NVHPC SDK | OpenMPI | Netlib + ScaLAPACK + CUDA 13 | FFTW3 | Yes | Yes | Yes (Fortran) | `build-environment/ubuntu24.04-nvhpc-openmpi-netlib-cuda13-cmake/` | MPI parallel build targeting NVIDIA GPUs | Available |

#### Build Environment Details

**ubuntu22.04-gcc-netlib**
- **Image tag**: `abidocker/abienv:ubuntu22.04-gcc-netlib`
- **Parallelization**: OpenMP only (no MPI)
- **Build time**: ~20-30 minutes
- **Image size**: ~500 MB - 1 GB (runtime)

**ubuntu22.04-gcc-openmpi-openblas**
- **Image tag**: `abidocker/abienv:ubuntu22.04-gcc-openmpi-openblas`
- **Parallelization**: MPI + OpenMP hybrid
- **Build time**: ~25-40 minutes
- **Image size**: ~1.5 - 2 GB (runtime)

**ubuntu26.04-gcc-openmpi-openblas**
- **Image tag**: `abidocker/abienv:ubuntu26.04-gcc-openmpi-openblas`
- **Parallelization**: MPI + OpenMP hybrid
- **Build time**: ~25-40 minutes
- **Image size**: ~1.5 - 2 GB (runtime)

**ubuntu26.04-intel-oneapi-mkl**
- **Image tag**: `abidocker/abienv:ubuntu26.04-intel-oneapi-mkl`
- **Parallelization**: MPI + OpenMP hybrid
- **Build time**: ~40-60 minutes
- **Image size**: ~3 - 4 GB (runtime)

**ubuntu22.04-nvhpc-openmpi-netlib-cuda11**
- **Image tag**: `abidocker/abienv:ubuntu22.04-nvhpc-openmpi-netlib-cuda11`
- **Parallelization**: MPI + OpenMP + GPU
- **Build time**: ~30-40 minutes
- **Image size**: ~5 GB (runtime)

**ubuntu24.04-nvhpc-openmpi-netlib-cuda12**
- **Image tag**: `abidocker/abienv:ubuntu24.04-nvhpc-openmpi-netlib-cuda12`
- **Parallelization**: MPI + OpenMP + GPU
- **Build time**: ~30-40 minutes
- **Image size**: ~5 GB (runtime)

**ubuntu24.04-nvhpc-openmpi-netlib-cuda13-cmake**
- **Image tag**: `abidocker/abienv:ubuntu24.04-nvhpc-openmpi-netlib-cuda13`
- **Parallelization**: MPI + OpenMP + GPU
- **Build time**: ~30-40 minutes
- **Image size**: ~5 GB (runtime)

### With-ABINIT

Docker images with ABINIT pre-installed. Each configuration specifies the build environment used and the ABINIT version.

#### Configuration Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ABINIT_REPO` | Git repository URL | `https://github.com/abinit/abinit.git` |
| `ABINIT_BRANCH` | Git branch or tag | `master` |
| `RUN_TESTS` | Run test suite during build | `yes` |
| `TEST_SUITE` | Test suite name (`fast`, `v1`, `paral`, etc.) | Config-dependent |
| `MPI_IMPL` | MPI implementation (`openmpi`, `mpich`) | Config-dependent |

#### Available Configurations

| OS | Compiler | MPI | Math Lib | ABINIT Version | Directory | Description | Status |
|----|----------|-----|----------|---------------|-----------|-------------|--------|
| - | - | - | - | - | `with-abinit/` | (TODO: Add configurations) | - |

### AbiBuildbot Workers

Docker images for running AbiBuildbot CI workers. Includes build environment + worker tools (Python, Git, Docker CLI, Buildbot worker runtime).

#### What's Included

| Component | Description |
|-----------|-------------|
| Build Environment | Based on build-environment configurations |
| Python | Python 3.x for worker operation |
| Git | Git client for repository operations |
| Docker | Docker CLI for host Docker socket access when mounted |
| Worker protocol | Direct Buildbot worker protocol runtime |
| AbiBuildbot | Provided at runtime through mounted checkouts or configuration |

#### Available Configurations

| OS | Compiler | MPI | Math Lib | Directory | Description | Status |
|----|----------|-----|----------|-----------|-------------|--------|
| Ubuntu 22.04 | GCC | OpenMPI 4.x | OpenBLAS + ScaLAPACK | `abibuildbotworker/ubuntu22.04-gcc-openmpi-openblas/` | MPI worker with Buildbot runtime tooling | Available |
| Ubuntu 26.04 | GCC | OpenMPI 5.x | OpenBLAS + ScaLAPACK | `abibuildbotworker/ubuntu26.04-gcc-openmpi-openblas/` | MPI worker with current Ubuntu GCC/OpenMPI packages | Available |
| Ubuntu 26.04 | Intel oneAPI | Intel MPI | Intel oneMKL | `abibuildbotworker/ubuntu26.04-intel-oneapi-mkl/` | MPI worker with Intel ifx, Intel MPI, and MKL | Available |

## SKILLS

The skills for generating Dockerfiles include instructions, knowledge, and templates for generating Dockerfiles for the software environment.

During development of the Dockerfiles, the generated files may not be perfect and may need improvement. This can be done by:
1. Running the Dockerfiles
2. Checking for errors during build or run
3. Using error messages as feedback to improve the Dockerfiles
4. Iterating with the agent to improve the files

Improved Dockerfiles can then be used as templates for the next generation.

## Documentation

- [Build Environment Overview](dockerfiles/build-environment/README.md)
- [With-ABINIT Overview](dockerfiles/with-abinit/README.md)
- [AbiBuildbot Worker Overview](dockerfiles/abibuildbotworker/README.md)

## Quick Start

### Build a Build Environment

```bash
# Serial build environment
docker build \
  -f dockerfiles/build-environment/ubuntu22.04-gcc-netlib/Dockerfile \
  -t abidocker/abienv:ubuntu22.04-gcc-netlib \
  dockerfiles/build-environment/ubuntu22.04-gcc-netlib

# MPI build environment
docker build \
  -f dockerfiles/build-environment/ubuntu22.04-gcc-openmpi-openblas/Dockerfile \
  -t abidocker/abienv:ubuntu22.04-gcc-openmpi-openblas \
  dockerfiles/build-environment/ubuntu22.04-gcc-openmpi-openblas
```

### Build ABINIT with a Build Environment

```bash
# Using the MPI build environment
docker build \
  -f dockerfiles/build-environment/ubuntu22.04-gcc-openmpi-openblas/Dockerfile \
  --build-arg ABINIT_BRANCH=9.10.3 \
  -t abidocker/abinit:ubuntu22.04-gcc-openmpi-openblas-9.10.3 \
  dockerfiles/build-environment/ubuntu22.04-gcc-openmpi-openblas
```

### Run ABINIT

```bash
# Serial run
docker run --rm -v $(pwd):/workspace abidocker/abienv:ubuntu22.04-gcc-netlib abinit input.in

# Parallel run
docker run --rm -v $(pwd):/workspace abidocker/abienv:ubuntu22.04-gcc-openmpi-openblas \
  mpirun -np 4 abinit input.in
```
