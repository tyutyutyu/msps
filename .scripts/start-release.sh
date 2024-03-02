#!/usr/bin/env bash

set -eu

VERSION="${1}"

git flow release start "${VERSION}"
poetry version "${VERSION}"
gh pr create --base main --title "Release: ${VERSION}" --body ""
