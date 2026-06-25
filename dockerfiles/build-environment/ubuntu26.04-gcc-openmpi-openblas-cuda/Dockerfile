# Multi-stage Dockerfile for ABINIT (MPI + OpenBLAS Configuration)
# Ubuntu 26.04 with GCC 15, OpenMPI 5, OpenBLAS, ScaLAPACK, FFTW3
#
# Build arguments:
#   ABINIT_REPO: Git repository URL for ABINIT source
#   ABINIT_BRANCH: Git branch or tag to checkout
#   RUN_TESTS: Whether to run test suite during build (yes/no)
#   TEST_SUITE: Which test suite to run (paral/v1/v2/etc)
#   MPI_IMPL: MPI implementation (openmpi/mpich)
#   NUM_MPI_PROCS: Number of MPI processes for testing

# =============================================================================
# Stage 1: Builder - Full build environment with MPI
# =============================================================================
FROM nvidia/cuda:13.3.0-devel-ubuntu26.04 AS builder

ARG ABINIT_REPO=https://github.com/abinit/abinit.git
ARG ABINIT_BRANCH=master
ARG GPU_ARCH=80
ARG RUN_TESTS=yes
ARG TEST_SUITE=paral
ARG MPI_IMPL=openmpi
ARG NUM_MPI_PROCS=4
ARG DEBIAN_FRONTEND=noninteractive

LABEL stage=builder
LABEL description="ABINIT builder stage with MPI and OpenBLAS on Ubuntu 26.04"

COPY install-deps.sh /tmp/install-deps.sh
RUN bash -c "source /tmp/install-deps.sh && \
    install_build_tools && \
    install_abinit_mandatory_deps && \
    install_mpi ${MPI_IMPL} && \
    install_optimized_linalg openblas && \
    install_python_testing && \
    cleanup_apt"

ENV FC=mpif90
ENV CC=mpicc
ENV CXX=mpic++
ENV MAKEFLAGS="-j$(nproc)"

ENV OMPI_ALLOW_RUN_AS_ROOT=1
ENV OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

WORKDIR /tmp/abinit-build

RUN echo "Cloning ABINIT from ${ABINIT_REPO} (branch: ${ABINIT_BRANCH})..." && \
     git clone --depth 1 --branch "${ABINIT_BRANCH}" "${ABINIT_REPO}" abinit-src && \
     cd abinit-src && \
     ABINIT_VERSION=$(cat .current_version 2>/dev/null || echo "unknown") && \
     echo "ABINIT Version: ${ABINIT_VERSION}" && \
     echo "${ABINIT_VERSION}" > /tmp/ABINIT_VERSION && \
     chmod -R u+w .

RUN cd abinit-src && \
    echo "Configuring ABINIT (MPI + OpenBLAS)..." && \
    if [ -x ./config/scripts/makemake ]; then \
      ./config/scripts/makemake; \
    elif [ -x ./autogen.sh ]; then \
      ./autogen.sh; \
    fi && \
    mkdir build && cd build && \
    ../configure \
        --prefix=/opt/abinit \
        --enable-mpi=yes \
        --enable-mpi-io=yes \
        --enable-openmp=yes \
        --enable-openmp-offload=yes \
        --with-cuda=/usr/local/cuda \
        --with-linalg=/usr/local \
        --with-linalg-flavor=openblas \
        --with-fft-flavor=fftw3-threads \
        --with-libxc=yes \
        --with-hdf5=yes \
        --with-netcdf=yes \
        --with-netcdf-fortran=yes \
        --with-optim-flavor=standard \
        --with-debug-flavor=basic \
        GPU_ARCH="${GPU_ARCH}" \
        FCFLAGS="-O2 -g -fopenmp -ffree-line-length-none -fallow-argument-mismatch" \
        CFLAGS="-O2 -g" \
        LINALG_LIBS="-lopenblas -lscalapack-openmpi -foffload-options=nvptx-none=-latomic" \
        FFTW3_LIBS="-lfftw3_threads -lfftw3f_threads -lfftw3 -lfftw3f" \
        > /tmp/configure.log 2>&1 && \
    echo "Configuration complete. See /tmp/configure.log for details."

RUN cd abinit-src/build && \
    echo "Building ABINIT with $(nproc) parallel jobs..." && \
    make -j$(nproc) > /tmp/build.log 2>&1 && \
    echo "Build complete. See /tmp/build.log for details."

RUN cd abinit-src/build && \
    echo "Installing ABINIT to /opt/abinit..." && \
    make install > /tmp/install.log 2>&1 && \
    echo "Installation complete."

RUN /opt/abinit/bin/abinit --version && \
    echo "ABINIT binaries installed successfully"

RUN mkdir -p /opt/abinit/tests && \
    cp -r /tmp/abinit-build/abinit-src/tests/Pspdir /opt/abinit/tests/ && \
    echo "Pseudopotentials copied"

RUN if [ "${RUN_TESTS}" = "yes" ]; then \
        echo "Running ABINIT test suite: ${TEST_SUITE} with ${NUM_MPI_PROCS} MPI processes..." && \
        cd /tmp/abinit-build/abinit-src/tests && \
        export PATH="/opt/abinit/bin:${PATH}" && \
        mkdir -p /opt/abinit/test-results && \
        ./runtests.py ${TEST_SUITE} -n${NUM_MPI_PROCS} -j2 2>&1 | tee /opt/abinit/test-results/test.log || \
        echo "Tests completed with some failures (check test.log for details)"; \
    else \
        echo "Skipping test suite (RUN_TESTS=${RUN_TESTS})"; \
    fi

RUN echo "Build Date: $(date -u)" > /opt/abinit/BUILD_INFO && \
    echo "ABINIT Version: $(cat /tmp/ABINIT_VERSION)" >> /opt/abinit/BUILD_INFO && \
    echo "ABINIT Repository: ${ABINIT_REPO}" >> /opt/abinit/BUILD_INFO && \
    echo "ABINIT Branch: ${ABINIT_BRANCH}" >> /opt/abinit/BUILD_INFO && \
    echo "Configuration: mpi-openblas" >> /opt/abinit/BUILD_INFO && \
    echo "MPI Implementation: ${MPI_IMPL}" >> /opt/abinit/BUILD_INFO && \
    echo "Compiler: GCC $(gcc --version | head -1)" >> /opt/abinit/BUILD_INFO && \
    echo "MPI Compiler: $(mpif90 --version | head -1)" >> /opt/abinit/BUILD_INFO && \
    echo "Linear Algebra: OpenBLAS + ScaLAPACK" >> /opt/abinit/BUILD_INFO && \
    echo "FFT: FFTW3 (threaded)" >> /opt/abinit/BUILD_INFO && \
    cat /opt/abinit/BUILD_INFO

# =============================================================================
# Stage 2: Runtime - MPI + OpenBLAS runtime environment
# =============================================================================
FROM nvidia/cuda:13.3.0-runtime-ubuntu26.04 AS runtime

ARG MPI_IMPL=openmpi
ARG DEBIAN_FRONTEND=noninteractive

LABEL maintainer="AbiDocker"
LABEL description="ABINIT - MPI + OpenBLAS Configuration on Ubuntu 26.04 (parallel calculations)"
LABEL org.opencontainers.image.title="ABINIT MPI + OpenBLAS (Ubuntu 26.04)"
LABEL org.opencontainers.image.description="ABINIT atomic-scale simulation software - MPI parallel build with OpenBLAS on Ubuntu 26.04, GCC 15, OpenMPI 5"
LABEL org.opencontainers.image.url="https://www.abinit.org"
LABEL org.opencontainers.image.documentation="https://docs.abinit.org"
LABEL org.opencontainers.image.source="https://github.com/abinit/abinit"

COPY install-deps.sh /tmp/install-deps.sh
RUN bash -c "source /tmp/install-deps.sh && \
    install_runtime_deps && \
    install_mpi ${MPI_IMPL} && \
    install_optimized_linalg openblas && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/*"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libopenblas0-openmp && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN if apt-get install -y --no-install-recommends \
        libscalapack-openmpi2.2 2>/dev/null; then \
        echo "ScaLAPACK installed successfully"; \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*; \
    else \
        echo "Warning: ScaLAPACK not available (expected on some platforms)"; \
    fi

COPY --from=builder /opt/abinit /opt/abinit
COPY --from=builder /tmp/ABINIT_VERSION /opt/abinit/VERSION

ENV PATH="/opt/abinit/bin:${PATH}"
ENV ABI_PSPDIR="/opt/abinit/tests/Pspdir"
ENV OMP_NUM_THREADS=1

ENV OMPI_ALLOW_RUN_AS_ROOT=1
ENV OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
ENV OMPI_MCA_btl_vader_single_copy_mechanism=none

WORKDIR /workspace

#RUN abinit --version && \
#    mpirun --version && \
#    echo "ABINIT with MPI is ready to use!"
#
#RUN cat /opt/abinit/BUILD_INFO
#
#CMD ["abinit", "--help"]
