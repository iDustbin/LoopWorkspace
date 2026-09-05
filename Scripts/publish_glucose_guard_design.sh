#!/usr/bin/env bash
# Create or update iDustbin/glucose-guard-design from the bundled branding tree.
# Uses GH_PAT (never printed). Intended for GitHub Actions.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OWNER="${GLUCOSE_GUARD_DESIGN_OWNER:-iDustbin}"
REPO="${GLUCOSE_GUARD_DESIGN_REPO:-glucose-guard-design}"
SRC="${ROOT}/glucose-guard-design"

if [[ -z "${GH_PAT:-}" ]]; then
  echo "GH_PAT is unset. Add the Loop browser-build PAT as a repo secret." >&2
  exit 1
fi

if [[ ! -d "${SRC}/ios" ]]; then
  echo "Missing ${SRC}/ios" >&2
  exit 1
fi

export GH_TOKEN="${GH_PAT}"
export GH_PROMPT_DISABLED=1

if ! gh repo view "${OWNER}/${REPO}" >/dev/null 2>&1; then
  echo "Creating ${OWNER}/${REPO}"
  gh repo create "${OWNER}/${REPO}" \
    --public \
    --description "Glucose Guard iOS branding: logo, icons, display name" \
    --disable-wiki
else
  echo "${OWNER}/${REPO} already exists"
fi

work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT
cp -R "${SRC}/." "${work}/"
cd "${work}"
git init -b main
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git add -A
git commit -m "sync iOS branding from LoopWorkspace"

git -c "http.extraHeader=Authorization: Bearer ${GH_PAT}" \
  push --force "https://github.com/${OWNER}/${REPO}.git" main

echo "Published branding to ${OWNER}/${REPO}"
