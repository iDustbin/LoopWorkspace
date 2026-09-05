#!/usr/bin/env bash
# Pull Glucose Guard branding from iDustbin/glucose-guard-design and apply
# it to this LoopWorkspace checkout. Used after upstream LoopKit sync so
# icons and the display name survive a fork reset.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESIGN_OWNER="${GLUCOSE_GUARD_DESIGN_OWNER:-iDustbin}"
DESIGN_REPO="${GLUCOSE_GUARD_DESIGN_REPO:-glucose-guard-design}"
DESIGN_REF="${GLUCOSE_GUARD_DESIGN_REF:-main}"
LOCAL_DESIGN="${GLUCOSE_GUARD_DESIGN_PATH:-}"
CLONE_DIR=""

cleanup() {
  if [[ -n "${CLONE_DIR}" && -d "${CLONE_DIR}" ]]; then
    rm -rf "${CLONE_DIR}"
  fi
}
trap cleanup EXIT

resolve_source() {
  if [[ -n "${LOCAL_DESIGN}" ]]; then
    if [[ ! -d "${LOCAL_DESIGN}/ios" ]]; then
      echo "GLUCOSE_GUARD_DESIGN_PATH does not contain an ios/ directory: ${LOCAL_DESIGN}" >&2
      exit 1
    fi
    printf '%s\n' "${LOCAL_DESIGN}"
    return
  fi

  local bundled="${ROOT}/glucose-guard-design"
  local url="https://github.com/${DESIGN_OWNER}/${DESIGN_REPO}.git"
  CLONE_DIR="$(mktemp -d)"

  echo "Cloning ${DESIGN_OWNER}/${DESIGN_REPO}@${DESIGN_REF}" >&2
  set +e
  if [[ -n "${GH_PAT:-}" ]]; then
    git -c "http.extraHeader=Authorization: Bearer ${GH_PAT}" \
      clone --depth 1 --branch "${DESIGN_REF}" "${url}" "${CLONE_DIR}"
  else
    git clone --depth 1 --branch "${DESIGN_REF}" "${url}" "${CLONE_DIR}"
  fi
  local clone_status=$?
  set -e

  if [[ "${clone_status}" -eq 0 && -d "${CLONE_DIR}/ios" ]]; then
    printf '%s\n' "${CLONE_DIR}"
    return
  fi

  echo "Remote ${DESIGN_OWNER}/${DESIGN_REPO} is not available; using bundled glucose-guard-design." >&2
  rm -rf "${CLONE_DIR}"
  CLONE_DIR=""
  if [[ -d "${bundled}/ios" ]]; then
    printf '%s\n' "${bundled}"
    return
  fi

  echo "No Glucose Guard design source found. Create iDustbin/glucose-guard-design or set GLUCOSE_GUARD_DESIGN_PATH." >&2
  exit 1
}

copy_catalog() {
  local src="$1"
  local dest="$2"
  if [[ ! -d "${src}" ]]; then
    echo "Missing asset catalog: ${src}" >&2
    exit 1
  fi
  rm -rf "${dest}"
  mkdir -p "$(dirname "${dest}")"
  cp -R "${src}" "${dest}"
}

apply_display_name() {
  local snippet="$1"
  local xcconfig="${ROOT}/LoopConfigOverride.xcconfig"
  python3 - "${snippet}" "${xcconfig}" <<'PY'
import re
import sys
from pathlib import Path

snippet = Path(sys.argv[1])
xcconfig = Path(sys.argv[2])
name = "GlucoseGuard"
if snippet.is_file():
    for line in snippet.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if stripped.startswith("MAIN_APP_DISPLAY_NAME"):
            _, _, value = stripped.partition("=")
            candidate = value.strip()
            if candidate:
                name = candidate
            break

text = xcconfig.read_text(encoding="utf-8") if xcconfig.exists() else ""
pattern = re.compile(r"^MAIN_APP_DISPLAY_NAME\s*=.*$", re.MULTILINE)
replacement = f"MAIN_APP_DISPLAY_NAME = {name}"
if pattern.search(text):
    text = pattern.sub(replacement, text)
else:
    if text and not text.endswith("\n"):
        text += "\n"
    text += replacement + "\n"
xcconfig.write_text(text, encoding="utf-8")
print(f"Set {replacement}")
PY
}

SRC="$(resolve_source)"
copy_catalog \
  "${SRC}/ios/OverrideAssetsLoop.xcassets" \
  "${ROOT}/OverrideAssetsLoop.xcassets"
copy_catalog \
  "${SRC}/ios/OverrideAssetsWatchApp.xcassets" \
  "${ROOT}/OverrideAssetsWatchApp.xcassets"
apply_display_name "${SRC}/ios/display_name.xcconfig"
echo "Glucose Guard branding applied from ${SRC}"
