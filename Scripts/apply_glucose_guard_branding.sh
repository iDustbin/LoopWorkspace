#!/usr/bin/env bash
# Pull Glucose Guard branding from iDustbin/glucoseguard and apply
# it to this LoopWorkspace checkout. Used after upstream LoopKit sync so
# icons and the display name survive a fork reset.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESIGN_OWNER="${GLUCOSE_GUARD_DESIGN_OWNER:-iDustbin}"
DESIGN_REPO="${GLUCOSE_GUARD_DESIGN_REPO:-glucoseguard}"
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
  CLONE_DIR="$(mktemp -d)"
  export GIT_TERMINAL_PROMPT=0

  echo "Cloning ${DESIGN_OWNER}/${DESIGN_REPO}@${DESIGN_REF}" >&2
  set +e
  if [[ -n "${GH_PAT:-}" ]]; then
    git clone --depth 1 --branch "${DESIGN_REF}" \
      "https://x-access-token:${GH_PAT}@github.com/${DESIGN_OWNER}/${DESIGN_REPO}.git" \
      "${CLONE_DIR}"
  else
    git clone --depth 1 --branch "${DESIGN_REF}" \
      "https://github.com/${DESIGN_OWNER}/${DESIGN_REPO}.git" \
      "${CLONE_DIR}"
  fi
  local clone_status=$?
  set -e

  if [[ "${clone_status}" -eq 0 && -d "${CLONE_DIR}/ios" ]]; then
    echo "Cloned https://github.com/${DESIGN_OWNER}/${DESIGN_REPO} @ $(git -C "${CLONE_DIR}" rev-parse --short HEAD)" >&2
    printf '%s\n' "${CLONE_DIR}"
    return
  fi

  # In CI the design repo must be used. Local Xcode can fall back to the bundle.
  if [[ -n "${GH_PAT:-}" ]]; then
    echo "Failed to clone https://github.com/${DESIGN_OWNER}/${DESIGN_REPO}. Not using the bundled fallback in CI." >&2
    exit 1
  fi

  echo "Remote ${DESIGN_OWNER}/${DESIGN_REPO} is not available; using bundled glucose-guard-design." >&2
  rm -rf "${CLONE_DIR}"
  CLONE_DIR=""
  if [[ -d "${bundled}/ios" ]]; then
    printf '%s\n' "${bundled}"
    return
  fi

  echo "No Glucose Guard design source found. Create iDustbin/glucoseguard or set GLUCOSE_GUARD_DESIGN_PATH." >&2
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

apply_localized_display_name() {
  local name="$1"
  python3 - "${ROOT}" "${name}" <<'PY'
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
name = sys.argv[2]
keys = ("CFBundleDisplayName", "CFBundleName")
updated = 0

loop_root = root / "Loop"
if not loop_root.is_dir():
    print("Loop submodule is missing; cannot rewrite InfoPlist.xcstrings", file=sys.stderr)
    sys.exit(1)

for path in loop_root.rglob("InfoPlist.xcstrings"):
    data = json.loads(path.read_text(encoding="utf-8"))
    strings = data.get("strings")
    if not isinstance(strings, dict):
        continue
    changed = False
    for key in keys:
        entry = strings.get(key)
        if not isinstance(entry, dict):
            continue
        locs = entry.get("localizations")
        if not isinstance(locs, dict):
            continue
        for loc in locs.values():
            if not isinstance(loc, dict):
                continue
            unit = loc.get("stringUnit")
            if isinstance(unit, dict) and "value" in unit:
                unit["value"] = name
                changed = True
    if changed:
        path.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        updated += 1
        print(f"Set {name} in {path.relative_to(root)}")

if updated == 0:
    print("No Loop InfoPlist.xcstrings files were updated", file=sys.stderr)
    sys.exit(1)
print(f"Updated CFBundleDisplayName in {updated} string catalog(s)")
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
DISPLAY_NAME="$(python3 - "${SRC}/ios/display_name.xcconfig" <<'PY'
from pathlib import Path
import sys
name = "GlucoseGuard"
p = Path(sys.argv[1])
if p.is_file():
    for line in p.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if stripped.startswith("MAIN_APP_DISPLAY_NAME"):
            _, _, value = stripped.partition("=")
            if value.strip():
                name = value.strip()
            break
print(name)
PY
)"
apply_localized_display_name "${DISPLAY_NAME}"

# Loop.xcconfig includes this file after the default MAIN_APP_DISPLAY_NAME = Loop.
printf '%s\n' \
  "// Generated from glucose-guard-design/ios/display_name.xcconfig" \
  "MAIN_APP_DISPLAY_NAME = ${DISPLAY_NAME}" \
  > "${ROOT}/Loop/LoopOverride.xcconfig"
echo "Wrote Loop/LoopOverride.xcconfig (${DISPLAY_NAME})"

echo "Glucose Guard branding applied from ${SRC}"
