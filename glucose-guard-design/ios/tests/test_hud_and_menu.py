#!/usr/bin/env python3
"""Verify HUD glucose + Figma menu patches against the pinned Loop sources."""

from __future__ import annotations

import sys
import tempfile
import urllib.request
from pathlib import Path
from urllib.parse import quote

LOOP_PIN = "1f71ec4fa94941abdbd72fd5bd914770faa2e90b"
LOOPKIT_PIN = "e7e2ee2b546c4d8122014838cb98a0e26dd91208"
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "ios"))

from apply_theme import apply_glucose_range_chart, apply_hud_chrome  # noqa: E402

HUD_FILES = (
    "LoopUI/Views/DeviceStatusHUDView.swift",
    "LoopUI/Views/StatusBarHUDView.swift",
    "LoopUI/Views/LoopCompletionHUDView.swift",
    "LoopUI/Views/CGMStatusHUDView.swift",
    "LoopUI/Views/GlucoseValueHUDView.swift",
)


def fetch(rel: str, dest: Path, *, repo: str = "Loop", pin: str = LOOP_PIN) -> None:
    url = f"https://raw.githubusercontent.com/LoopKit/{repo}/{pin}/{quote(rel, safe='/')}"
    dest.parent.mkdir(parents=True, exist_ok=True)
    with urllib.request.urlopen(url, timeout=30) as response:
        dest.write_bytes(response.read())


def test_hud_keeps_glucose() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        loop = Path(tmp)
        for rel in HUD_FILES:
            fetch(rel, loop / rel)
        apply_hud_chrome(loop)
        cgm = (loop / "LoopUI/Views/CGMStatusHUDView.swift").read_text(encoding="utf-8")
        assert "glucoseValueHUD.isHidden = true" not in cgm
        assert "the left pill always shows the current glucose value" in cgm
        glucose = (loop / "LoopUI/Views/GlucoseValueHUDView.swift").read_text(encoding="utf-8")
        assert "systemFont(ofSize: 22, weight: .bold)" in glucose
        print("HUD glucose patch applies to pinned Loop sources")


def test_figma_device_screens() -> None:
    design = (ROOT / "ios/overlays/GlucoseGuardXcodeDesign.swift.txt").read_text(encoding="utf-8")
    screens = (ROOT / "ios/overlays/GlucoseGuardFigmaScreens.swift.txt").read_text(encoding="utf-8")
    host = (ROOT / "ios/overlays/GlucoseGuardTabBarHost.swift.txt").read_text(encoding="utf-8")
    apply = (ROOT / "ios/apply_theme.py").read_text(encoding="utf-8")
    assert "Stop Sensor" in design
    assert "Replace Pump" in design
    assert "Suspend Insulin Delivery" in design
    assert "Device Details" in design
    assert "GlucoseGuardGlucoseSettingsView" in screens
    assert "LibreView" in screens
    assert "Dexcom Share" in screens
    assert "Emergency Contacts" in screens
    assert "GlucoseGuardJourneyView" in screens
    assert "My Journey" in screens
    assert "presentGlucoseGuardGlucoseSettings()" in host
    assert "onCGMTapped()" in host
    assert "onPumpTapped()" in host
    assert "GlucoseGuardFigmaScreens.swift.txt" in apply
    assert "targetLowMgdl" in screens
    assert "targetLowMgdl" in host
    assert "[90, 110, 95, 130, 100, 118, 102]" not in design
    assert "(low + high) / 2" not in screens
    assert "apply_glucose_range_chart" in apply
    print("Figma CGM/pump/settings screens are wired")


def test_menu_overlay() -> None:
    design = (ROOT / "ios/overlays/GlucoseGuardXcodeDesign.swift.txt").read_text(encoding="utf-8")
    host = (ROOT / "ios/overlays/GlucoseGuardTabBarHost.swift.txt").read_text(encoding="utf-8")
    for label in ('"Today"', '"Food"', '"Bolus"', '"Profile"'):
        assert label in design, label
    assert "onFood:" in design and "onBolus:" in design and "onProfile:" in design
    assert "presentGlucoseGuardFood()" in host
    assert "presentBolusScreen()" in host
    assert "presentSettings()" in host
    assert "presentGlucoseGuardLearning()" not in host.split("onToday")[0]
    assert 'onLearning:' not in host
    assert "offset(y: -34)" not in design
    assert "view.bottomAnchor" in host
    assert "additionalSafeAreaInsets.bottom" in host
    print("Figma menu overlay wires Today / Food / Bolus / Profile")


def test_glucose_range_chart() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        loop = root / "Loop"
        fetch(
            "LoopKitUI/Charts/PredictedGlucoseChart.swift",
            root / "LoopKit/LoopKitUI/Charts/PredictedGlucoseChart.swift",
            repo="LoopKit",
            pin=LOOPKIT_PIN,
        )
        fetch(
            "LoopKitUI/Charts/IOBChart.swift",
            root / "LoopKit/LoopKitUI/Charts/IOBChart.swift",
            repo="LoopKit",
            pin=LOOPKIT_PIN,
        )
        fetch("Loop/Extensions/ChartColorPalette+Loop.swift", loop / "Loop/Extensions/ChartColorPalette+Loop.swift")
        fetch(
            "Loop/View Controllers/StatusTableViewController.swift",
            loop / "Loop/View Controllers/StatusTableViewController.swift",
        )
        apply_glucose_range_chart(loop)
        predicted = (root / "LoopKit/LoopKitUI/Charts/PredictedGlucoseChart.swift").read_text(encoding="utf-8")
        assert "targetBoundLines" in predicted
        assert "glucoseFill" in predicted
        assert "glucoseLine" in predicted
        assert "dashPattern: [6, 4]" in predicted
        assert "0.31, green: 0.64, blue: 0.96" in predicted
        assert "colors.glucoseTint.withAlphaComponent(0.2)" not in predicted
        iob = (root / "LoopKit/LoopKitUI/Charts/IOBChart.swift").read_text(encoding="utf-8")
        assert "iobDots" in iob
        assert "withAlphaComponent(0.5)" not in iob
        palette = (loop / "Loop/Extensions/ChartColorPalette+Loop.swift").read_text(encoding="utf-8")
        assert "0.957, green: 0.200, blue: 0.235" in palette
        assert "insulinTint: UIColor" in palette
        status = (loop / "Loop/View Controllers/StatusTableViewController.swift").read_text(encoding="utf-8")
        assert "applyGlucoseGuardChartChrome" in status
        chrome = (ROOT / "ios/overlays/GlucoseGuardHomeChrome.swift.txt").read_text(encoding="utf-8")
        assert "applyGlucoseGuardChartChrome" in chrome
        print("Screenshot chart style patches apply to pinned Loop and LoopKit")


if __name__ == "__main__":
    test_hud_keeps_glucose()
    test_menu_overlay()
    test_figma_device_screens()
    test_glucose_range_chart()
    print("ok")
