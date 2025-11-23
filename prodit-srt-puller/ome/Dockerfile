# ===== Stage 1: build OME with NVENC (CUDA) =====
FROM nvidia/cuda:11.4.3-devel-ubuntu20.04 AS build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    tzdata \
    sudo \
    curl \
    git \
    nasm \
    tcl \
    autoconf \
    automake \
    libtool \
    zlib1g-dev \
    cmake \
    pkg-config \
    uuid-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

ARG OME_VERSION=v0.19.0
ARG STRIP=TRUE

ENV PREFIX=/opt/ovenmediaengine
ENV TEMP_DIR=/tmp/ome

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_REQUIRE_CUDA=cuda>=11.4
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,video,compat32

# Configure ldconfig to find CUDA/nvml stub libs
RUN echo "/usr/local/cuda-11.4/targets/x86_64-linux/lib/stubs" > /etc/ld.so.conf.d/000_cuda.conf && ldconfig

# Download OvenMediaEngine
RUN mkdir -p ${TEMP_DIR} && \
    cd ${TEMP_DIR} && \
    git clone --branch ${OME_VERSION} --single-branch --depth 1 https://github.com/AirenSoft/OvenMediaEngine .

# Install dependencies (with NVENC)
RUN ${TEMP_DIR}/misc/prerequisites.sh --enable-nvc

# Build OvenMediaEngine
RUN cd ${TEMP_DIR}/src && \
    make release -j$(nproc) && \
    if [ "$STRIP" = "TRUE" ] ; then strip ${TEMP_DIR}/src/bin/RELEASE/OvenMediaEngine ; fi

# Install into PREFIX
RUN cd ${TEMP_DIR}/src && \
    mkdir -p ${PREFIX}/bin/origin_conf && \
    mkdir -p ${PREFIX}/bin/edge_conf && \
    cp ./bin/RELEASE/OvenMediaEngine ${PREFIX}/bin/ && \
    cp ../misc/conf_examples/Origin.xml ${PREFIX}/bin/origin_conf/Server.xml && \
    cp ../misc/conf_examples/Logger.xml ${PREFIX}/bin/origin_conf/Logger.xml && \
    cp ../misc/conf_examples/Edge.xml ${PREFIX}/bin/edge_conf/Server.xml && \
    cp ../misc/conf_examples/Logger.xml ${PREFIX}/bin/edge_conf/Logger.xml && \
    rm -rf ${TEMP_DIR}

# ===== Stage 2: runtime =====
FROM nvidia/cuda:11.4.3-runtime-ubuntu20.04 AS release

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y tzdata sudo && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/ovenmediaengine/bin
EXPOSE 80/tcp 8080/tcp 8090/tcp 1935/tcp 3333/tcp 3334/tcp 4000-4005/udp 10000-10010/udp 9000/tcp 9998/udp 9999/udp

COPY --from=build /opt/ovenmediaengine /opt/ovenmediaengine

# Prepiši origin_conf/Server.xml našim (iz local repo-a)
COPY Server.xml /opt/ovenmediaengine/bin/origin_conf/Server.xml

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_REQUIRE_CUDA=cuda>=11.4
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,video,compat32

# Default run as Origin mode, using origin_conf
CMD ["/opt/ovenmediaengine/bin/OvenMediaEngine", "-c", "origin_conf"]
