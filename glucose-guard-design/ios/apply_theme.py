#!/usr/bin/env python3
"""Apply Glucose Guard mobile theme onto a checked-out Loop submodule."""

from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path

MARKER = "GLUCOSE_GUARD_THEME"


def die(message: str) -> None:
    print(message, file=sys.stderr)
    raise SystemExit(1)


def replace_once(path: Path, old: str, new: str, *, required: bool = True) -> bool:
    text = path.read_text(encoding="utf-8")
    if old not in text:
        if new.strip()[:40] in text or MARKER in text and required is False:
            return False
        if required:
            die(f"Could not find expected text in {path}")
        return False
    path.write_text(text.replace(old, new, 1), encoding="utf-8")
    print(f"Patched {path}")
    return True


def copy_colorset(src: Path, dest_catalog: Path, name: str) -> None:
    source = src / f"{name}.colorset"
    if not source.is_dir():
        die(f"Missing colorset {source}")
    target = dest_catalog / f"{name}.colorset"
    if target.exists():
        shutil.rmtree(target)
    shutil.copytree(source, target)
    print(f"Wrote {target}")


def apply_colors(design: Path, loop: Path) -> None:
    theme = design / "ios" / "theme"
    catalogs = [
        loop / "Loop" / "DerivedAssets.xcassets",
        loop / "WatchApp" / "DerivedAssets.xcassets",
        loop / "Loop Widget Extension" / "DerivedAssets.xcassets",
    ]
    for catalog in catalogs:
        if not catalog.is_dir():
            print(f"Skip missing asset catalog {catalog}")
            continue
        for name in ("accent", "fresh", "glucose"):
            copy_colorset(theme, catalog, name)


def apply_hud_mark(design: Path, loop: Path) -> None:
    source = design / "ios" / "overlays" / "glucose_guard_mark.imageset"
    dest = loop / "LoopUI" / "HUDAssets.xcassets" / "glucose_guard_mark.imageset"
    if not source.is_dir():
        die(f"Missing HUD mark {source}")
    if dest.exists():
        shutil.rmtree(dest)
    shutil.copytree(source, dest)
    print(f"Wrote {dest}")

    overlay = design / "ios" / "overlays" / "LoopStateView.swift"
    target = loop / "LoopUI" / "Views" / "LoopStateView.swift"
    if not overlay.is_file():
        die(f"Missing {overlay}")
    shutil.copyfile(overlay, target)
    print(f"Wrote {target}")


def apply_color_fallbacks(loop: Path) -> None:
    uicolor = loop / "LoopUI" / "Extensions" / "UIColor.swift"
    replace_once(
        uicolor,
        "@nonobjc static let fresh = UIColor(named: \"fresh\") ?? HIGGreenColor()",
        "@nonobjc static let fresh = UIColor(named: \"fresh\") ?? UIColor(red: 0.133, green: 0.773, blue: 0.369, alpha: 1)",
    )
    replace_once(
        uicolor,
        "@nonobjc static let glucose = UIColor(named: \"glucose\") ?? systemTeal",
        "@nonobjc static let glucose = UIColor(named: \"glucose\") ?? UIColor(red: 0.957, green: 0.200, blue: 0.235, alpha: 1)",
    )
    replace_once(
        uicolor,
        "@nonobjc public static let loopAccent = UIColor(named: \"accent\") ?? systemBlue",
        "@nonobjc public static let loopAccent = UIColor(named: \"accent\") ?? UIColor(red: 0.957, green: 0.200, blue: 0.235, alpha: 1)",
    )
    replace_once(
        uicolor,
        "@nonobjc public static let critical = systemRed",
        "@nonobjc public static let critical = UIColor(red: 0.957, green: 0.200, blue: 0.235, alpha: 1)",
    )

    swift_color = loop / "LoopUI" / "Extensions" / "Color.swift"
    replace_once(
        swift_color,
        "    public static let critical = red",
        "    public static let critical = Color(red: 0.957, green: 0.200, blue: 0.235)",
    )


def apply_hud_chrome(loop: Path) -> None:
    device = loop / "LoopUI" / "Views" / "DeviceStatusHUDView.swift"
    replace_once(
        device,
        "            progressView.tintColor = .systemGray",
        "            progressView.tintColor = UIColor(red: 0.957, green: 0.200, blue: 0.235, alpha: 1)",
    )
    replace_once(
        device,
            "            backgroundView.backgroundColor = .systemBackground\n            backgroundView.layer.cornerRadius = 23",
            "            backgroundView.backgroundColor = .systemBackground\n            backgroundView.layer.cornerRadius = 18\n            backgroundView.layer.borderWidth = 1\n            backgroundView.layer.borderColor = UIColor.separator.cgColor",
    )

    status_bar = loop / "LoopUI" / "Views" / "StatusBarHUDView.swift"
    replace_once(
        status_bar,
        "        self.backgroundColor = UIColor.secondarySystemBackground",
        "        self.backgroundColor = UIColor.systemBackground",
    )

    completion = loop / "LoopUI" / "Views" / "LoopCompletionHUDView.swift"
    replace_once(
        completion,
        "            return (title: LocalizedString(\"Loop Warning\", comment: \"Title of yellow loop message\"),",
        "            return (title: LocalizedString(\"Glucose Guard Warning\", comment: \"Title of yellow loop message\"),",
    )
    replace_once(
        completion,
        "            return (title: LocalizedString(\"Loop Failure\", comment: \"Title of red loop message\"),",
        "            return (title: LocalizedString(\"Glucose Guard Failure\", comment: \"Title of red loop message\"),",
    )


def apply_toolbar(loop: Path) -> None:
    path = loop / "Loop" / "View Controllers" / "StatusTableViewController.swift"
    text = path.read_text(encoding="utf-8")
    if "presentGlucoseGuardLogSheet" in text:
        print(f"Home chrome already applied in {path}")
        return

    old_setup = """    private func setupToolbarItems() {
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let carbs = UIBarButtonItem(image: UIImage(named: "carbs"), style: .plain, target: self, action: #selector(userTappedAddCarbs))
        let bolus = UIBarButtonItem(image: UIImage(named: "bolus"), style: .plain, target: self, action: #selector(presentBolusScreen))
        let settings = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(onSettingsTapped))
        
        let preMeal = createPreMealButtonItem(selected: false, isEnabled: true)
        let workout = createWorkoutButtonItem(selected: false, isEnabled: true)
        toolbarItems = [
            carbs,
            space,
            preMeal,
            space,
            bolus,
            space,
            workout,
            space,
            settings
        ]
    }"""
    new_setup = """    private func setupToolbarItems() {
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let symbol = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let today = UIBarButtonItem(image: UIImage(systemName: "sun.max.fill", withConfiguration: symbol), style: .plain, target: self, action: #selector(presentGlucoseGuardToday))
        let stats = UIBarButtonItem(image: UIImage(systemName: "chart.bar.fill", withConfiguration: symbol), style: .plain, target: self, action: #selector(presentGlucoseGuardStatistics))
        let add = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)), style: .plain, target: self, action: #selector(presentGlucoseGuardLogSheet))
        let settings = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle", withConfiguration: symbol), style: .plain, target: self, action: #selector(onSettingsTapped))
        toolbarItems = [
            today,
            space,
            stats,
            space,
            add,
            space,
            settings
        ]
    }"""
    replace_once(path, old_setup, new_setup)

    old_update = """    private func updateToolbarItems() {
        let isPumpOnboarded = onboardingManager.isComplete || deviceManager.pumpManager?.isOnboarded == true

        toolbarItems![0].accessibilityLabel = NSLocalizedString("Add Meal", comment: "The label of the carb entry button")
        toolbarItems![0].isEnabled = isPumpOnboarded
        toolbarItems![0].tintColor = UIColor.carbTintColor
        toolbarItems![4].accessibilityLabel = NSLocalizedString("Bolus", comment: "The label of the bolus entry button")
        toolbarItems![4].isEnabled = isPumpOnboarded
        toolbarItems![4].tintColor = UIColor.insulinTintColor
        toolbarItems![8].accessibilityLabel = NSLocalizedString("Settings", comment: "The label of the settings button")
        toolbarItems![8].tintColor = UIColor.secondaryLabel
        
        toolbarItems![2] = createPreMealButtonItem(selected: preMealMode == true && preMealModeAllowed, isEnabled: preMealModeAllowed)
        toolbarItems![6] = createWorkoutButtonItem(selected: workoutMode == true && workoutModeAllowed, isEnabled: workoutModeAllowed)
    }"""
    new_update = """    private func updateToolbarItems() {
        let isPumpOnboarded = onboardingManager.isComplete || deviceManager.pumpManager?.isOnboarded == true

        toolbarItems![0].accessibilityLabel = NSLocalizedString("Today", comment: "The label of the Today toolbar item")
        toolbarItems![0].isEnabled = true
        toolbarItems![0].tintColor = UIColor.loopAccent
        toolbarItems![2].accessibilityLabel = NSLocalizedString("Statistics", comment: "The label of the statistics toolbar item")
        toolbarItems![2].isEnabled = true
        toolbarItems![2].tintColor = UIColor.secondaryLabel
        toolbarItems![4].accessibilityLabel = NSLocalizedString("Add", comment: "The label of the add toolbar item")
        toolbarItems![4].isEnabled = isPumpOnboarded || deviceManager.cgmManager != nil
        toolbarItems![4].tintColor = UIColor.loopAccent
        toolbarItems![6].accessibilityLabel = NSLocalizedString("Settings", comment: "The label of the settings button")
        toolbarItems![6].tintColor = UIColor.secondaryLabel
    }"""
    replace_once(path, old_update, new_update)

    replace_once(
        path,
        "        tableView.backgroundColor = .secondarySystemBackground",
        "        tableView.backgroundColor = .systemBackground",
    )

    insert_after = """        present(navigationWrapper, animated: true)
        deviceManager.analyticsServicesManager.didDisplayBolusScreen()
    }
"""
    chrome = Path(__file__).with_name("overlays") / "GlucoseGuardHomeChrome.swift.txt"
    stats = Path(__file__).with_name("overlays") / "GlucoseGuardStatistics.swift.txt"
    chrome_text = chrome.read_text(encoding="utf-8")
    stats_text = stats.read_text(encoding="utf-8")
    text = path.read_text(encoding="utf-8")
    if insert_after not in text:
        die(f"Could not insert home chrome into {path}")
    text = text.replace(insert_after, insert_after + "\n" + chrome_text + "\n", 1)
    if not text.endswith("\n"):
        text += "\n"
    text += "\n" + stats_text
    if not text.endswith("\n"):
        text += "\n"
    path.write_text(text, encoding="utf-8")
    print(f"Inserted Glucose Guard home chrome into {path}")


def apply_bolus_and_settings(loop: Path) -> None:
    bolus = loop / "Loop" / "Views" / "BolusEntryView.swift"
    replace_once(
        bolus,
        "            Text(\"Bolus\", comment: \"Label for bolus entry row on bolus screen\")",
        "            Text(\"Change Bolus\", comment: \"Label for bolus entry row on bolus screen\")",
    )
    replace_once(
        bolus,
        "            bolusEntryRow\n        }",
        "            bolusEntryRow\n            Text(\"Current recommended bolus is above. Enter a new amount to change it.\", comment: \"Help text for changing the current bolus\")\n                .font(.footnote)\n                .foregroundColor(.secondary)\n        }",
        required=False,
    )

    settings = loop / "Loop" / "Views" / "SettingsView.swift"
    replace_once(
        settings,
                    """                case .cgmPicker:
                    return ActionSheet(
                        title: Text("Add CGM", comment: "The title of the CGM chooser in settings"),
                        buttons: cgmChoices
                    )""",
                    """                case .cgmPicker:
                    return ActionSheet(
                        title: Text("Add CGM", comment: "The title of the CGM chooser in settings"),
                        message: Text("LibreLinkUp, Dexcom Share, or another CGM source.", comment: "CGM chooser subtitle listing required sources"),
                        buttons: cgmChoices
                    )""",
    )
    replace_once(
        settings,
        "                        descriptiveText: NSLocalizedString(\"Tap here to set up a CGM\", comment: \"Descriptive text for button to add CGM device\"))",
        "                        descriptiveText: NSLocalizedString(\"LibreLinkUp, Dexcom Share, or another CGM. Sensor expiry is in CGM detail.\", comment: \"Descriptive text for button to add CGM device\"))",
    )
    replace_once(
        settings,
        "            .accentColor(Color(.systemGray))",
        "            .accentColor(Color(red: 0.957, green: 0.200, blue: 0.235))",
    )
    settings_text = settings.read_text(encoding="utf-8")
    if "glucoseGuardProfileSection" not in settings_text:
        replace_once(
            settings,
            "                    loopSection",
            "                    loopSection\n                    glucoseGuardProfileSection",
        )

    profile = '''
    private var glucoseGuardProfileSection: some View {
        Section(header: SectionHeader(label: NSLocalizedString("Profile", comment: "Settings profile section"))) {
            VStack(alignment: .leading, spacing: 6) {
                Text("A1C, AVG, SD, TIR, TBR, and TAR")
                    .font(.headline)
                Text("Open Statistics from the Today toolbar to switch 3, 7, 30, or 90 days.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
'''
    text = settings.read_text(encoding="utf-8")
    if "glucoseGuardProfileSection" in text and "private var glucoseGuardProfileSection" not in text:
        # referenced but not defined — fall through to insert
        pass
    if "private var glucoseGuardProfileSection" not in text:
        needle = "    private var loopSection: some View {"
        if needle not in text:
            die(f"Could not insert profile section into {settings}")
        settings.write_text(text.replace(needle, profile + "\n" + needle, 1), encoding="utf-8")
        print(f"Inserted profile section into {settings}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--loop-root", required=True)
    parser.add_argument("--design-root", required=True)
    args = parser.parse_args()
    loop = Path(args.loop_root)
    design = Path(args.design_root)
    if not (loop / "LoopUI").is_dir():
        die(f"Loop checkout is missing LoopUI: {loop}")
    apply_colors(design, loop)
    apply_hud_mark(design, loop)
    apply_color_fallbacks(loop)
    apply_hud_chrome(loop)
    apply_toolbar(loop)
    apply_bolus_and_settings(loop)
    print("Glucose Guard mobile theme applied")


if __name__ == "__main__":
    main()
