#!/usr/bin/env bash

. ./env-vars.sh

docker build -t ${EPICS_DEV_DOCKER_ORG_NAME}/${EPICS_DEV_DOCKER_IMAGE_NAME} .
