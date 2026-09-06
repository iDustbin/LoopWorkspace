# Glucose Guard — Step 1 (iOS only)

Branding source of truth for the Loop iOS fork (`iDustbin/LoopWorkspace`).

## Implemented now

- App name: **GlucoseGuard** on the Home Screen (rewrites Loop `InfoPlist.xcstrings`)
- Robot-cross logo on brand red (`#F4333C`)
- iOS and watchOS override app icons
- Native **Xcode/SwiftUI** screens from the Figma mobile theme:
  - Today HUD replaces Loop's HUD: CGM pill with **up-arrows**, logo + green/white closed-loop ring, pump pill
  - Sensor expiry lives in CGM detail (14-day bar), not the top nav
  - OneDrop-style tab bar: **Today · Learning · Healthway · +**
  - CGM detail: last reading, 3/7/30/90 AVG, LibreLinkUp / Dexcom Share overlay
  - Pump detail: Omnipod DASH card, 3-day bar, basal, remaining insulin, change bolus
  - Learning: dark STATISTIKEN with AVG, SD, **A1C**, TIR / TBR / TAR
  - Healthway: light Glucose Values dashboard
  - Bolus: current recommended amount plus **Change Bolus**
- **4. Build Loop** applies this tree in the Xcode checkout, then Fastlane uploads TestFlight

## Not in this step

- Kubernetes / web dashboard
- Withings, Rex.fit, or clinician search
- Food overview / restaurant favorites (owned by another company)
- Custom Omnipod DASH radio patches (stay synced with LoopKit)

Omnipod DASH drops on newer InPlay/Atlas pods are handled upstream. Stay synced with LoopKit so Pod Keep Alive arrives through the fork-sync workflow.
