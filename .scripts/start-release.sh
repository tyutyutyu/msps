#!/usr/bin/env bash

set -eu

# ─── helpers ────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

step()  { echo -e "\n${CYAN}${BOLD}==> $*${NC}"; }
ok()    { echo -e "${GREEN}✓ $*${NC}"; }
warn()  { echo -e "${YELLOW}! $*${NC}" >&2; }
die()   { echo -e "${RED}✗ $*${NC}" >&2; exit 1; }

confirm() {
  local answer
  read -r -p "$(echo -e "${YELLOW}${BOLD}$1${NC} [y/N] ")" answer
  [[ "${answer,,}" == "y" || "${answer,,}" == "yes" ]]
}

wait_enter() {
  echo -e "${YELLOW}${BOLD}$1${NC}"
  read -r -p "Press Enter when ready... "
}

# ─── args ───────────────────────────────────────────────────────────────────
VERSION="${1:?Usage: ./start-release.sh <version> (e.g. 1.0.3rc1 or 1.0.3)}"

if echo "${VERSION}" | grep -qE 'rc[0-9]+'; then
  IS_RC=true
else
  IS_RC=false
fi

CURRENT_BRANCH="$(git branch --show-current)"

echo -e "\n${BOLD}Release ${VERSION} ($( ${IS_RC} && echo 'TestPyPI (RC)' || echo 'PyPI (Production)'))${NC}"
echo "Current branch: ${CURRENT_BRANCH}"

if ! ${IS_RC} && [[ "${CURRENT_BRANCH}" != "develop" ]]; then
  warn "Production releases are normally run from 'develop'. You are on '${CURRENT_BRANCH}'."
  confirm "Continue anyway?" || die "Aborted."
fi

# ─── 1. set version ─────────────────────────────────────────────────────────
step "Setting version to ${VERSION}"
uv version "${VERSION}"
ok "pyproject.toml updated to $(uv version --short)"

# ─── 2. verify ──────────────────────────────────────────────────────────────
step "Running task verify"
confirm "Run task verify now?" || die "Aborted."
task verify
ok "All checks passed"

# ─── 3. commit & push ───────────────────────────────────────────────────────
step "Committing version bump"
git add pyproject.toml uv.lock
git diff --cached --quiet && die "Nothing to commit — pyproject.toml and uv.lock unchanged."
git commit -m "chore: bump version to ${VERSION}"
confirm "Push to origin/${CURRENT_BRANCH}?" || die "Aborted."
git push origin "${CURRENT_BRANCH}"
ok "Pushed to origin/${CURRENT_BRANCH}"

# ─── RC flow ─────────────────────────────────────────────────────────────────
if ${IS_RC}; then
  step "Creating and pushing tag v${VERSION} → TestPyPI"
  confirm "Tag and push v${VERSION}?" || die "Aborted."
  task release:test VERSION="${VERSION}"
  ok "Tag v${VERSION} pushed — TestPyPI workflow started"

  echo -e "\n${BOLD}Validate the published package once the workflow finishes:${NC}"
  echo "  pip install -i https://test.pypi.org/simple/ msps==${VERSION}"
  echo "  msps --help"
  exit 0
fi

# ─── Prod flow ───────────────────────────────────────────────────────────────
step "Creating PR: ${CURRENT_BRANCH} → main"
EXISTING_PR="$(gh pr list --base main --head "${CURRENT_BRANCH}" --json url --jq '.[0].url' 2>/dev/null || true)"
if [[ -n "${EXISTING_PR}" ]]; then
  warn "Open PR already exists: ${EXISTING_PR}"
  PR_URL="${EXISTING_PR}"
else
  PR_URL="$(gh pr create \
    --base main \
    --head "${CURRENT_BRANCH}" \
    --title "Release ${VERSION}" \
    --body "Automated release PR for version ${VERSION}." \
    2>&1 | tail -1)"
  ok "PR created: ${PR_URL}"
fi

wait_enter "Merge the PR on GitHub and wait for all checks to pass.\n  ${PR_URL}"

step "Pulling main"
git checkout main
git pull
MAIN_VERSION="$(uv version --short)"
[[ "${MAIN_VERSION}" == "${VERSION}" ]] || die "main version is '${MAIN_VERSION}', expected '${VERSION}'. Was the PR merged?"
ok "main is at version ${VERSION}"

step "Creating and pushing tag v${VERSION} → PyPI"
confirm "Tag and push v${VERSION}?" || die "Aborted."
task release:prod VERSION="${VERSION}"
ok "Tag v${VERSION} pushed — PyPI release workflow started"

wait_enter "Wait for the GitHub Actions release workflow to complete.\n  Check: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/actions"

step "Merging main back to develop"
confirm "Merge main back to develop now?" || { warn "Skipped — run: task merge:back-to-develop"; exit 0; }
task merge:back-to-develop
ok "develop is synced with main"

echo -e "\n${GREEN}${BOLD}✓ Release ${VERSION} complete!${NC}"
echo "Verify: uvx msps@latest --help"
