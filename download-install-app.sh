#!/usr/bin/env bash

# Source env vars
. ./env-vars.sh

# Clone LNLS EPICS installation scripts
git clone --branch=${EPICS_DEV_VERSION} https://github.com/lnls-sirius/epics-dev.git ${EPICS_DEV_REPO}

## Apply patches
#cd ${EPICS_DEV_REPO}
#git am --ignore-whitespace /build/patches/epics-dev/*
#cd ..

# Build EPICS
cd ${EPICS_DEV_REPO}
./run-all.sh -e yes -x yes -s yes -i -o
cd ..
