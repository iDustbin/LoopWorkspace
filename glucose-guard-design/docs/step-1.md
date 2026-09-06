# Glucose Guard — Step 1 (iOS only)

Branding source of truth for the Loop iOS fork (`iDustbin/LoopWorkspace`).

## Implemented now

- App name: **GlucoseGuard** on the Home Screen (rewrites Loop `InfoPlist.xcstrings`)
- Robot-cross logo on brand red (`#F4333C`)
- iOS and watchOS override app icons
- Loop’s Today HUD and predicted-glucose charts stay — Figma is the direction, not a replacement
  - Full green/white circle around the logo (no chopped C-gap)
  - Dark Loop chrome, brand red, Figma menu **Today · Food · Bolus · Profile** plus a floating **+**
  - Left HUD pill keeps the **current glucose value** (sensor days stay in CGM detail)
  - CGM / pump taps open Figma-inspired detail sheets (14-day sensor, 3-day pod, change bolus)
  - Learning: dark STATISTIKEN (AVG, SD, **A1C**, TIR / TBR / TAR)
- **4. Build Loop** applies this tree in the Xcode checkout, then Fastlane uploads TestFlight

## Not in this step

- Kubernetes / web dashboard
- Withings, Rex.fit, or clinician search
- Food overview / restaurant favorites (owned by another company)
- Custom Omnipod DASH radio patches (stay synced with LoopKit)

Omnipod DASH drops on newer InPlay/Atlas pods are handled upstream. Stay synced with LoopKit so Pod Keep Alive arrives through the fork-sync workflow.
