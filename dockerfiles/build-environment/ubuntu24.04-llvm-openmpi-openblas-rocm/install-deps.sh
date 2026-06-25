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
        make \
        autoconf \
        automake \
        libtool \
        pkg-config \
        ca-certificates \
        wget \
        zlib1g-dev \
        libxml2-dev \
        libatomic1 \
        libquadmath0 \
        rsh-redone-client \
        vim \
        git
    if [ $? -eq 0 ]; then log_info "Build tools installed successfully"; else exit 666; fi
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

install_runtime_deps() {
    log_info "Installing runtime dependencies..."
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libatomic1 \
        libquadmath0 \
        rsh-redone-client
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
