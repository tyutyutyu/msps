#!/usr/bin/env bash

set -e

poetry run coverage run --branch --module pytest
poetry run coverage report --show-missing
