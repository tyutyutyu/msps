#!/usr/bin/env bash

set -e

poetry run coverage run --branch --module pytest
coverage report --show-missing
