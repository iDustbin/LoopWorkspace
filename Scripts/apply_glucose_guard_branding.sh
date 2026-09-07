#!/usr/bin/env bash
# Apply Glucose Guard name and app icons onto a LoopWorkspace checkout.
# Does not patch Loop UI, charts, HUD, or menus.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCAL_DESIGN="${GLUCOSE_GUARD_DESIGN_PATH:-}"

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
  if [[ -d "${bundled}/ios" ]]; then
    echo "Using Xcode design from ${bundled}" >&2
    printf '%s\n' "${bundled}"
    return
  fi

  echo "No glucose-guard-design/ios tree found in this LoopWorkspace checkout." >&2
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
echo "Glucose Guard name and icons applied from ${SRC} (Loop UI left unchanged)"
