#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

install_build_tools() {
    log_info "Installing build tools..."
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        gfortran \
        gcc \
        g++ \
        gcc-offload-nvptx \
        make \
        autoconf \
        automake \
        libtool \
        pkg-config \
        ca-certificates \
        wget \
        git
    log_info "Build tools installed successfully"
}

install_abinit_mandatory_deps() {
    log_info "Installing ABINIT mandatory dependencies..."
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libhdf5-dev \
        libnetcdf-dev \
        libnetcdff-dev \
        libxc-dev \
        libfftw3-dev \
        liblapack-dev \
        libblas-dev
    log_info "Mandatory dependencies installed successfully"
}

install_mpi() {
    local mpi_impl="${1:-openmpi}"
    log_info "Installing MPI implementation: ${mpi_impl}..."

    apt-get update
    if [ "${mpi_impl}" = "openmpi" ]; then
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            libopenmpi-dev \
            openmpi-bin
    elif [ "${mpi_impl}" = "mpich" ]; then
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            libmpich-dev \
            mpich
    else
        log_error "Unknown MPI implementation: ${mpi_impl}"
        return 1
    fi
    log_info "MPI installed successfully"
}

install_optimized_linalg() {
    local flavor="${1:-openblas}"
    log_info "Installing optimized linear algebra: ${flavor}..."

    apt-get update
    if [ "${flavor}" = "openblas" ]; then
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            libopenblas-dev \
            libopenblas-openmp-dev || true
        if apt-get install -y --no-install-recommends \
            libscalapack-mpi-dev 2>/dev/null; then
            log_info "ScaLAPACK installed successfully"
        else
            log_warn "ScaLAPACK not available, using LAPACK only (expected on some platforms)"
        fi
    else
        log_error "Unknown linalg flavor: ${flavor}"
        return 1
    fi
    log_info "Optimized linear algebra installed successfully"
}

install_python_testing() {
    log_info "Installing Python for test suite..."
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-numpy \
        python3-scipy \
        python3-yaml \
        python-is-python3
    log_info "Python testing dependencies installed successfully"
}

install_abinit_optional_deps() {
    log_info "Installing optional ABINIT dependencies..."
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libxml2-dev \
        libyaml-dev
    log_info "Optional dependencies installed successfully"
}

install_runtime_deps() {
    log_info "Installing runtime dependencies..."
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libhdf5-310 \
        libnetcdf22 \
        libnetcdff7 \
        libxc9 \
        libfftw3-single3 \
        libfftw3-double3 \
        liblapack3 \
        libblas3 \
        libgfortran-15-dev \
        libgomp-plugin-nvptx1 \
        libgomp1
    log_info "Runtime dependencies installed successfully"
}

cleanup_apt() {
    log_info "Cleaning up apt cache..."
    apt-get clean
    rm -rf /var/lib/apt/lists/*
    log_info "Cleanup complete"
}

cleanup_build_artifacts() {
    log_info "Cleaning up build artifacts..."
    apt-get clean
    rm -rf /var/lib/apt/lists/*
    rm -rf /tmp/*
    rm -rf /var/tmp/*
    find /usr/share/doc -type f -delete
    find /usr/share/man -type f -delete
    log_info "Build artifacts cleaned up"
}
