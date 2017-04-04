#!/usr/bin/env bash

set -a
set -e
set -u

. ./env-vars.sh

# Run Wildfly
docker run --name ${EPICS_DEV_DOCKER_RUN_NAME} --net ${NET_NAME} --dns ${DNS_IP} \
    -d ${EPICS_DEV_DOCKER_ORG_NAME}/${EPICS_DEV_DOCKER_IMAGE_NAME}
