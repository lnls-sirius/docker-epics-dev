#!/usr/bin/env bash

set -a
set -e
set -u

NET_NAME="$1"

docker network create ${NET_NAME} 2>/dev/null || true
