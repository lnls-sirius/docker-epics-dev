#!/usr/bin/env bash

set -a
set -e
set -u

# Source env vars
. ./env-vars.sh

# Download prereqs
./download-install-app.sh
