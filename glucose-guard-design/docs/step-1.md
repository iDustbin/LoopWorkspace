# Glucose Guard — Step 1 (iOS only)

Branding source of truth for the Loop iOS fork (`iDustbin/LoopWorkspace`).

## Implemented now

- App name: **GlucoseGuard** on the Home Screen (rewrites Loop `InfoPlist.xcstrings`)
- Robot-cross logo on brand red (`#F4333C`)
- iOS and watchOS override app icons
- Native **Xcode/SwiftUI** screens from the Figma mobile theme:
  - Accent / glucose charts in brand red, closed-loop ring in green (`#22C55E`)
  - Logo inside the loop status ring
  - SwiftUI tab bar: **Today · Learning · Healthway · +**
  - CGM detail: 14-day sensor bar, last reading, AVG
  - Pump detail: 3-day pod bar, basal, change bolus
  - Learning: 3 / 7 / 30 / 90 day AVG, SD, **A1C**, TIR / TBR / TAR
  - Healthway: Glucose Values dashboard
  - Bolus: current recommended amount plus **Change Bolus**
  - Add CGM overlay lists LibreLinkUp and Dexcom Share
- **4. Build Loop** applies this tree in the Xcode checkout, then Fastlane uploads TestFlight

## Not in this step

- Kubernetes / web dashboard
- Withings, Rex.fit, or clinician search
- Food overview / restaurant favorites (owned by another company)
- Custom Omnipod DASH radio patches (stay synced with LoopKit)

Omnipod DASH drops on newer InPlay/Atlas pods are handled upstream. Stay synced with LoopKit so Pod Keep Alive arrives through the fork-sync workflow.
