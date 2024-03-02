#!/usr/bin/env bash

set -e

docker build \
    --file .docker/Dockerfile.tests \
    --quiet \
    --tag tyutyutyu/msps_test \
    .

docker run \
    --interactive \
    --rm \
    --tty \
    tyutyutyu/msps_test
