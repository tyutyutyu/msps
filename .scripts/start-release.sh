#!/usr/bin/env bash

set -eu

VERSION="${1:?Usage: ./start-release.sh <version> (e.g. 1.0.3rc1 or 1.0.3)}"

echo "Setting version to ${VERSION} in pyproject.toml..."
uv version "${VERSION}"

echo ""
echo "Next steps:"
echo "  1. Run: task verify"
echo "  2. Commit the version change and push"
echo "  3. Tag and trigger the release:"

if echo "${VERSION}" | grep -qE 'rc[0-9]+'; then
  echo "     task release:test VERSION=${VERSION}"
else
  echo "     task release:prod VERSION=${VERSION}"
fi
