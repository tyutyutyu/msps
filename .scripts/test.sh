#!/usr/bin/env bash

set -e

poetry run coverage run --branch -m pytest
coverage report --show-missing
