# Multi-stage Dockerfile for ABINIT (MPI + OpenBLAS Configuration)
# Ubuntu 24.04 with LLVM AOMP 23.0, OpenMPI 4, OpenBLAS, FFTW3
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
FROM rocm/dev-ubuntu-24.04:7.2.4-complete AS builder

ARG ABINIT_REPO=https://github.com/abinit/abinit.git
ARG ABINIT_BRANCH=master
ARG GPU_ARCH=gfx90a
ARG RUN_TESTS=yes
ARG TEST_SUITE=paral
ARG MPI_IMPL=openmpi
ARG NUM_MPI_PROCS=4
ARG DEBIAN_FRONTEND=noninteractive
ARG FALLBACKS=/opt/fallbacks
ARG OPT_FLAGS="-O2"

LABEL stage=builder
LABEL description="ABINIT builder stage with MPI and OpenBLAS on Ubuntu 24.04"

COPY install-deps.sh /tmp/install-deps.sh
RUN bash -c "source /tmp/install-deps.sh && \
    install_build_tools && \
    install_python_testing && \
    cleanup_apt"


# Install AOMP - an experimental AMD LLVM fork
RUN mkdir /opt/aomp && cd /opt/aomp \
    && wget https://github.com/ROCm/aomp/releases/download/rel_23.0-0/aomp-23.0-0.tar.gz \
    && tar -xf aomp-23.0-0.tar.gz \
    && rm aomp-23.0-0.tar.gz

ENV FC=/opt/aomp/aomp_23.0-0/bin/amdflang
ENV CC=/opt/aomp/aomp_23.0-0/bin/amdclang
ENV CXX=/opt/aomp/aomp_23.0-0/bin/amdclang++
ENV MAKEFLAGS="-j$(nproc)"
ENV PKG_CONFIG_PATH=/usr/local/lib/openmpi/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:$PKG_CONFIG_PATH
ENV PATH=/usr/local/openmpi/bin:/usr/local/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/openmpi/lib:/usr/local/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=${FALLBACKS}/libxc/default/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=${FALLBACKS}/hdf5/default/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=${FALLBACKS}/netcdf4/default/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=${FALLBACKS}/netcdf4_fortran/default/lib:$LD_LIBRARY_PATH


ENV OMPI_ALLOW_RUN_AS_ROOT=1
ENV OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

WORKDIR /tmp/abinit-build


# OpenMPI
RUN wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.8.tar.gz

RUN tar xf openmpi-4.1.8.tar.gz && cd openmpi-4.1.8 \
    && ./configure CC=/opt/aomp/aomp_23.0-0/bin/amdclang FC=/opt/aomp/aomp_23.0-0/bin/amdflang CXX=/opt/aomp/aomp_23.0-0/bin/amdclang++ CFLAGS="-fPIC" FCFLAGS="-fPIC" CXXFLAGS="-fPIC" \
    --prefix=/usr/local/openmpi --enable-mpi-fortran \
    && make -j$(nproc) && make install && cd .. && rm -rf openmpi-4.1.8.tar.gz openmpi-4.1.8


# FFTW
RUN mkdir -p /var/tmp

RUN wget --progress=bar:force:noscroll --show-progress -P /var/tmp https://www.fftw.org/fftw-3.3.11.tar.gz

RUN tar -x -f /var/tmp/fftw-3.3.11.tar.gz -C /var/tmp -z

RUN cd /var/tmp/fftw-3.3.11 && \
    ./configure \
    CFLAGS="${OPT_FLAGS}" \
    CXXFLAGS="${OPT_FLAGS}" \
    FCFLAGS="${OPT_FLAGS}" FFLAGS="${OPT_FLAGS}" \
    LDFLAGS=-Wl,--as-needed \
    --prefix=/usr/local --enable-avx --enable-avx2 --enable-openmp --enable-shared --enable-sse2 --enable-threads --enable-float

RUN cd /var/tmp/fftw-3.3.11 && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    make distclean

RUN cd /var/tmp/fftw-3.3.11 && \
    ./configure \
    CFLAGS="${OPT_FLAGS}" \
    CXXFLAGS="${OPT_FLAGS}" \
    FCFLAGS="${OPT_FLAGS}" FFLAGS="${OPT_FLAGS}" \
    LDFLAGS=-Wl,--as-needed \
    --prefix=/usr/local --enable-avx --enable-avx2 --enable-openmp --enable-shared --enable-sse2 --enable-threads

RUN cd /var/tmp/fftw-3.3.11 && \
    make -j$(nproc) && \
    make -j$(nproc) install && \
    rm -rf /var/tmp/fftw-3.3.11 /var/tmp/fftw-3.3.11.tar.gz



# OpenBLAS
RUN wget --progress=bar:force:noscroll --show-progress -P /var/tmp https://github.com/OpenMathLib/OpenBLAS/releases/download/v0.3.33/OpenBLAS-0.3.33.tar.gz

RUN tar -x -f /var/tmp/OpenBLAS-0.3.33.tar.gz -C /var/tmp -z
RUN cd /var/tmp/OpenBLAS-0.3.33 && \
    make DYNAMIC_ARCH=1 NO_AFFINITY=1 NUM_THREADS=$(nproc) \
    CFLAGS="${OPT_FLAGS}"  \
    CXXFLAGS="${OPT_FLAGS}"  \
    FCFLAGS="${OPT_FLAGS}"  \
    FFLAGS="${OPT_FLAGS}"  \
    && make PREFIX=/usr/local install
RUN rm -rf /var/tmp/OpenBLAS-0.3.33 /var/tmp/OpenBLAS-0.3.33.tar.gz



ENV OMPI_FC=/opt/aomp/aomp_23.0-0/bin/amdflang
ENV OMPI_CC=/opt/aomp/aomp_23.0-0/bin/amdclang
ENV OMPI_CXX=/opt/aomp/aomp_23.0-0/bin/amdclang++
ENV CC=mpicc
ENV CXX=mpic++
ENV FC=mpifort

RUN echo "Cloning ABINIT from ${ABINIT_REPO} (branch: ${ABINIT_BRANCH})..." && \
     git clone --depth 1 --branch "${ABINIT_BRANCH}" "${ABINIT_REPO}" abinit-src && \
     cd abinit-src && \
     ABINIT_VERSION=$(cat .current_version 2>/dev/null || echo "unknown") && \
     echo "ABINIT Version: ${ABINIT_VERSION}" && \
     echo "${ABINIT_VERSION}" > /tmp/ABINIT_VERSION && \
     chmod -R u+w .

RUN cd abinit-src && \
    echo "Preparing ABINIT (MPI + OpenBLAS)..." && \
    if [ -x ./config/scripts/makemake ]; then \
      ./config/scripts/makemake; \
    elif [ -x ./autogen.sh ]; then \
      ./autogen.sh; \
    fi

## install fallbacks (HDF5, netCDF and libXC)
RUN tar xf abinit-src/fallbacks/abinit-fallbacks-*.tar.gz && \
    mv abinit-fallbacks* abinit-fallbacks  && \
    cd abinit-fallbacks \
    && ./autogen.sh \
    && ./configure CC=mpicc FC=mpifort CXX=mpic++ LDFLAGS=-lz LIBS="-lz" \
      --disable-linalg --disable-atompaw --disable-bigdft \
      --disable-wannier90 --disable-xmlf90 --disable-libpsml \
      --prefix=${FALLBACKS}

RUN cd abinit-fallbacks && \
    make -j$(nproc) && make install && cd .. && rm -rf abinit-fallbacks

RUN cd abinit-src && \
    echo "Configuring ABINIT (MPI + OpenBLAS)..." && \
    mkdir build && cd build && \
    ../configure \
        --prefix=/opt/abinit \
        --enable-mpi=yes \
        --enable-mpi-io=yes \
        --enable-openmp=yes \
        --enable-openmp-offload=yes \
        --with-rocm=/opt/rocm \
        --with-linalg=/usr/local \
        --with-linalg-flavor=openblas \
        --with-fft-flavor=fftw3-threads \
        --with-libxc=${FALLBACKS}/libxc/default \
        --with-hdf5=${FALLBACKS}/hdf5/default \
        --with-netcdf=${FALLBACKS}/netcdf4/default \
        --with-netcdf-fortran=${FALLBACKS}/netcdf4_fortran/default \
        --with-optim-flavor=safe \
        --with-debug-flavor=basic \
        GPU_ARCH="${GPU_ARCH}" \
        FCFLAGS_EXTRA="${OPT_FLAGS} -g " \
        CFLAGS_EXTRA="${OPT_FLAGS} -g" \
        LINALG_LIBS="-L/usr/local/lib -lopenblas" \
        FFTW3_LIBS="-L/usr/local/lib -lfftw3_threads -lfftw3f_threads -lfftw3 -lfftw3f" \
        > /tmp/configure.log 2>&1 && \
    echo "Configuration complete. See /tmp/configure.log for details."

RUN cd abinit-src/build && \
    echo "Building ABINIT with $(nproc) parallel jobs..." && \
    make -j$(nproc) | tee /tmp/build.log 2>&1 && \
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
FROM rocm/dev-ubuntu-24.04:7.2.4 AS runtime

ARG MPI_IMPL=openmpi
ARG DEBIAN_FRONTEND=noninteractive
ARG FALLBACKS=/opt/fallbacks

LABEL maintainer="AbiDocker"
LABEL description="ABINIT - MPI + OpenBLAS Configuration on Ubuntu 24.04 (parallel calculations)"
LABEL org.opencontainers.image.title="ABINIT MPI + OpenBLAS (Ubuntu 24.04)"
LABEL org.opencontainers.image.description="ABINIT atomic-scale simulation software - MPI parallel build with OpenBLAS on Ubuntu 24.04, AOMP 23.0, OpenMPI 4"
LABEL org.opencontainers.image.url="https://www.abinit.org"
LABEL org.opencontainers.image.documentation="https://docs.abinit.org"
LABEL org.opencontainers.image.source="https://github.com/abinit/abinit"

COPY install-deps.sh /tmp/install-deps.sh
RUN bash -c "source /tmp/install-deps.sh && \
    install_runtime_deps && \
    cleanup_apt"

COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/openmpi /usr/local/openmpi
COPY --from=builder ${FALLBACKS}/libxc/default/lib           ${FALLBACKS}/libxc/default/lib
COPY --from=builder ${FALLBACKS}/hdf5/default/lib            ${FALLBACKS}/hdf5/default/lib
COPY --from=builder ${FALLBACKS}/netcdf4/default/lib         ${FALLBACKS}/netcdf4/default/lib
COPY --from=builder ${FALLBACKS}/netcdf4_fortran/default/lib ${FALLBACKS}/netcdf4_fortran/default/lib
COPY --from=builder /opt/abinit /opt/abinit
COPY --from=builder /tmp/abinit-build/abinit-src/build/config.h /opt/abinit/
COPY --from=builder /opt/rocm/lib /opt/rocm/lib
COPY --from=builder /opt/aomp/aomp_23.0-0/lib/llvm/lib/lib* /opt/aomp/aomp_23.0-0/lib/llvm/lib/
COPY --from=builder /tmp/ABINIT_VERSION /opt/abinit/VERSION


ENV PATH=/opt/abinit/bin:/usr/local/openmpi/bin:${PATH}
ENV LD_LIBRARY_PATH=/opt/aomp/aomp_23.0-0/lib/llvm/lib/:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/local/openmpi/lib:/usr/local/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=${FALLBACKS}/libxc/default/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=${FALLBACKS}/hdf5/default/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=${FALLBACKS}/netcdf4/default/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=${FALLBACKS}/netcdf4_fortran/default/lib:$LD_LIBRARY_PATH
ENV ABI_PSPDIR="/opt/abinit/tests/Pspdir"
ENV OMP_NUM_THREADS=1

ENV OMPI_ALLOW_RUN_AS_ROOT=1
ENV OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
ENV OMPI_MCA_btl_vader_single_copy_mechanism=none

WORKDIR /workspace

RUN abinit --version && \
    mpirun --version && \
    echo "ABINIT with MPI is ready to use!"

RUN cat /opt/abinit/BUILD_INFO

CMD ["abinit", "--help"]
