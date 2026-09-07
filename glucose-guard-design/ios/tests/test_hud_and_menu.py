#!/usr/bin/env python3
"""Verify TestFlight branding is name and icons only — no Loop UI patches."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WORKSPACE = ROOT.parent


def test_branding_script_does_not_patch_loop_ui() -> None:
    script = (WORKSPACE / "Scripts/apply_glucose_guard_branding.sh").read_text(encoding="utf-8")
    assert "python3 \"${THEME_SCRIPT}\"" not in script
    assert "--loop-root" not in script
    assert "OverrideAssetsLoop.xcassets" in script
    assert "MAIN_APP_DISPLAY_NAME" in script
    assert "Loop UI left unchanged" in script
    print("Branding script copies icons and name only")


def test_apply_theme_is_noop() -> None:
    apply = (ROOT / "ios/apply_theme.py").read_text(encoding="utf-8")
    assert "Skipping Loop UI patches" in apply
    assert "inject_overlays" not in apply
    assert "installGlucoseGuardTabBar" not in apply
    assert "PredictedGlucoseChart" not in apply
    print("apply_theme.py does not patch Loop")


def test_display_name() -> None:
    snippet = (ROOT / "ios/display_name.xcconfig").read_text(encoding="utf-8")
    assert "MAIN_APP_DISPLAY_NAME = GlucoseGuard" in snippet
    print("Display name is GlucoseGuard")


if __name__ == "__main__":
    test_branding_script_does_not_patch_loop_ui()
    test_apply_theme_is_noop()
    test_display_name()
    print("ok")
