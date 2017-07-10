# Wildfly server with additional configurations

FROM ubuntu:16.04

MAINTAINER Lucas Russo

# User root user to install software
USER root

# Install missing dependencies
RUN echo nameserver 10.0.0.71 >> /etc/resolv.conf && \
        apt-get update && apt-get install -y \
        wget \
        git \
        sudo \
        net-tools \
    && rm -rf /var/lib/apt/lists/*

# Setup git, only for applying patches
RUN git config --global user.email "epics-dev-docker@epics-dev-docker.com"
RUN git config --global user.name "EPICS_DEV Docker"

# Create build directory
RUN mkdir -p /build

# Copy compilation scripts to build directory
COPY setup.sh \
        env-vars.sh \
        download-install-app.sh \
        /build/

# Change to build directory
WORKDIR /build

# Compile application
RUN echo nameserver 10.0.0.71 >> /etc/resolv.conf && \
    /build/setup.sh && \
# Cleanup
    rm -rf /var/lib/apt/lists/* && \
    cd /build/epics-dev && \
    git clean -fdx

# Change to root directory
WORKDIR /

# Expose default EPICS v3 ports
EXPOSE 5064/udp
EXPOSE 5064/tcp
EXPOSE 5065/udp
EXPOSE 5065/tcp
# Expose default EPICS v4
EXPOSE 5075/udp
EXPOSE 5075/tcp
EXPOSE 5076/udp
EXPOSE 5076/tcp

# Environment variables from installed bash.bashrc.local
ENV EPICS_HOST_ARCH=linux-x86_64 \
    EPICS_FOLDER=/opt/epics \
    EPICS_BASE=${EPICS_FOLDER}/base \
    EPICS_V4=${EPICS_FOLDER}/v4 \
    EPICS_V4_PVACCESS_BIN=${EPICS_FOLDER}/v4/pvAccessCPP/bin/${EPICS_HOST_ARCH} \
    EPICS_TOPDIR=${EPICS_BASE} \
    EPICS_BIN=${EPICS_BASE}/bin/${EPICS_HOST_ARCH} \
    EPICS_CA_ADDR_LIST="127.255.255.255" \
    EPICS_PV_ADDR_LIST="127.255.255.255" \
    EPICS_PVA_ADDR_LIST="127.255.255.255" \
    EPICS_CA_AUTO_ADDR_LIST="YES" \
    EPICS_PV_AUTO_ADDR_LIST="YES" \
    EPICS_PVA_AUTO_ADDR_LIST="YES" \
    EPICS_EXTENSIONS=${EPICS_FOLDER}/extensions \
    EPICS_EXTENSIONS_BIN=${EPICS_FOLDER}/extensions/bin/${EPICS_HOST_ARCH} \
    EPICS_CA_MAX_ARRAY_BYTES=50000000 \
    PATH=${PATH}:${EPICS_BIN}:${EPICS_EXTENSIONS}:${EPICS_EXTENSIONS_BIN}:${EPICS_V4_PVACCESS_BIN}
