# Glucose Guard — Step 1 (iOS only)

Branding source of truth for the Loop iOS fork (`iDustbin/LoopWorkspace`).

## Implemented now

- App name: **GlucoseGuard** on the Home Screen (rewrites Loop `InfoPlist.xcstrings`)
- Robot-cross logo on brand red (`#F4333C`)
- iOS and watchOS override app icons
- Mobile theme from the Figma screens:
  - Accent / glucose charts in brand red, closed-loop ring in green (`#22C55E`)
  - Logo inside the loop status ring (green/white/red by freshness)
  - CGM and pump HUD pills with lifecycle bars (sensor ~14 days, pod ~3 days stay in those cards, not a extra top-nav box)
  - Today / Statistics / **+** / Settings toolbar (One Drop–style add sheet: bolus, glucose, carbs, pre-meal, workout)
  - Bolus screen shows the current recommended amount and a **Change Bolus** field
  - Statistics: 3 / 7 / 30 / 90 day AVG, SD, **A1C** (GMI formula), TIR / TBR / TAR
  - Add CGM overlay copy lists LibreLinkUp and Dexcom Share
- GitHub Actions pull this tree after `LoopKit/LoopWorkspace` sync, then Fastlane uploads to the existing TestFlight app

## Not in this step

- Kubernetes / web dashboard
- Withings, Rex.fit, or clinician search
- Food overview / restaurant favorites (owned by another company)
- Learning and Healthway as separate product tabs (AID home stays Today)
- Custom Omnipod DASH radio patches (stay synced with LoopKit)

Omnipod DASH drops on newer InPlay/Atlas pods are handled upstream. Stay synced with LoopKit so Pod Keep Alive arrives through the fork-sync workflow.
