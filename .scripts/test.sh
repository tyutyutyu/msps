#!/usr/bin/env bash

set -e

uv run coverage run --branch --module pytest
uv run coverage report --show-missing
