# Build Environment Dockerfiles

This directory contains Dockerfiles for building the software environment in which ABINIT can be built and run. These images provide the build environment but do NOT include ABINIT itself.

## Directory Structure

```
build-environment/
├── ubuntu22.04-gcc-netlib/   # Serial build environment (Ubuntu 22.04)
│   ├── Dockerfile
│   ├── install-deps.sh       # Ubuntu 22.04-specific dependencies
│   └── README.md
└── ubuntu22.04-gcc-openmpi-openblas/  # MPI build environment (Ubuntu 22.04)
    ├── Dockerfile
    ├── install-deps.sh       # Ubuntu 22.04-specific dependencies
    └── README.md
```

**Note**: Each build environment directory contains its own `install-deps.sh` script with OS-specific package versions. For example, `ubuntu22.04-gcc-netlib/install-deps.sh` contains package versions specific to Ubuntu 22.04.

## Available Build Environments

|           OS |     Compiler |     MPI |             Math Lib |                                        Directory |    Description |       Use Case |
|--------------|--------------|---------|----------------------|--------------------------------------------------|----------------|----------------|
| Ubuntu 22.04 | GCC/gfortran |      No |   Netlib BLAS/LAPACK |                        `ubuntu22.04-gcc-netlib/` | Minimal/Serial | Testing, CI/CD |
| Ubuntu 22.04 | GCC/gfortran | OpenMPI | OpenBLAS + ScaLAPACK |              `ubuntu22.04-gcc-openmpi-openblas/` |   MPI Parallel |     Production |
| Ubuntu 22.04 |    NVHPC SDK | OpenMPI |   Netlib + ScaLAPACK |       `ubuntu22.04-nvhpc-openmpi-netlib-cuda11/` |    NVIDIA GPUs |     Production |
| Ubuntu 24.04 |    NVHPC SDK | OpenMPI |   Netlib + ScaLAPACK |       `ubuntu24.04-nvhpc-openmpi-netlib-cuda12/` |    NVIDIA GPUs |     Production |
| Ubuntu 24.04 |    NVHPC SDK | OpenMPI |   Netlib + ScaLAPACK | `ubuntu24.04-nvhpc-openmpi-netlib-cuda13-cmake/` |    NVIDIA GPUs |     Production |


Note: recipes with NVHPC are based on images from [NVIDIA GPU Cloud (NGC)](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/nvhpc) which requires to create an account for accessing their Docker images.

## Experimental Build Environments

The following environments target configurations that aren't production ready yet, especially in regard of GPU usage.
They are useful for CI as most recent versions of ABINIT should compile in those and CPU tests should run as expected.

|           OS |     Compiler |     MPI |             Math Lib |                                        Directory |    Description |       Use Case |
|--------------|--------------|---------|----------------------|--------------------------------------------------|----------------|----------------|
| Ubuntu 24.04 |    LLVM AOMP | OpenMPI |             OpenBLAS |        `ubuntu24.04-llvm-openmpi-openblas-rocm/` |       AMD GPUs | Testing, CI/CD |
| Ubuntu 26.04 | GCC/gfortran | OpenMPI | OpenBLAS + ScaLAPACK |         `ubuntu26.04-gcc-openmpi-openblas-cuda/` |    NVIDIA GPUs | Testing, CI/CD |


## Image Naming Convention

Images follow the pattern: `abidocker/abienv:<os>-<compiler>-<mpi>-<mathlib>`

Examples:
- `abidocker/abienv:ubuntu22.04-gcc-netlib`
- `abidocker/abienv:ubuntu22.04-gcc-openmpi-openblas`

## Build All Environments

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

## Dependencies

Each build environment directory contains an `install-deps.sh` script with OS-specific package versions. Each script provides the following functions:

- `install_build_tools()` - Build essentials (gcc, gfortran, make, autoconf, etc.)
- `install_abinit_mandatory_deps()` - Required libraries (HDF5, NetCDF, LibXC, FFTW3)
- `install_mpi()` - MPI implementation (openmpi or mpich)
- `install_optimized_linalg()` - Optimized linear algebra (openblas)
- `install_python_testing()` - Python for test suite
- `install_runtime_deps()` - Runtime-only dependencies
- `cleanup_apt()` / `cleanup_build_artifacts()` - Image size optimization
