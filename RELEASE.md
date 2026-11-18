# Release Process

## Branching Model

`main` is the only long-lived branch and is protected: every change, including
version bumps, lands through a pull request from a short-lived branch
(`feature/*`, `fix/*`, `release/*`). Production tags are created on `main`.

## Prerequisites

- All changes committed on the working branch
- `task` (Task runner) and `uv` installed

> `.scripts/start-release.sh <version>` automates the steps below. When started
> on `main`, it creates a `release/<version>` branch for the version bump.

## Test Release (TestPyPI)

1. Bump version to an RC identifier (e.g. `1.0.3rc1`):
   ```bash
   task version-bump -- patch   # or minor / major
   # then manually set the rc suffix in pyproject.toml if needed
   ```
2. Verify everything passes:
   ```bash
   task verify
   ```
3. Commit the version change, then tag and push:
   ```bash
   git add pyproject.toml uv.lock && git commit -m "chore: bump version to 1.0.3rc1"
   task release:test VERSION="$(uv version --short)"
   ```
4. The `v1.0.3rc1` tag triggers the **Publish to TestPyPI** workflow.
5. Validate the published package installs and works:
   ```bash
   pip install -i https://test.pypi.org/simple/ msps==1.0.3rc1
   msps --help
   ```

## Production Release (PyPI)

1. Bump version to a stable identifier (e.g. `1.0.3`):
   ```bash
   task version-bump -- patch   # or minor / major
   ```
2. Verify everything passes:
   ```bash
   task verify
   ```
3. Commit, merge to `main`, then tag and push:
   ```bash
   git add pyproject.toml && git commit -m "chore: bump version to 1.0.3"
   # open and merge PR to main
   task release:prod VERSION=1.0.3
   ```
4. The `v1.0.3` tag triggers the **Publish to PyPI** workflow, which:
   - Publishes to PyPI via Trusted Publishing
   - Signs artifacts with Sigstore
   - Creates a GitHub Release with auto-generated notes

## Tag Format

| Target   | Tag format       | Example       |
|----------|------------------|---------------|
| TestPyPI | `v<X.Y.Z>rc<N>` | `v1.0.3rc1`  |
| PyPI     | `v<X.Y.Z>`      | `v1.0.3`     |

> **Note:** The git tag version (without the `v` prefix) must exactly match `project.version` in `pyproject.toml`. Both release workflows verify this before publishing.
