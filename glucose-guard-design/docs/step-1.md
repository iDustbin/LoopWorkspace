# Glucose Guard — Step 1 (iOS only)

Branding source of truth for the Loop iOS fork (`iDustbin/LoopWorkspace`).

## Implemented now

- App name: **GlucoseGuard** on the Home Screen (rewrites Loop `InfoPlist.xcstrings`)
- Robot-cross logo on brand red (`#F4333C`) as the iOS and watchOS app icons
- **4. Build Loop** applies icons and the display name only. Loop’s HUD, charts, toolbar, and bolus flow are unchanged.

## Not in this step

- Custom Today chrome, tab bar, or SwiftUI overlay screens
- Chart color patches
- Kubernetes / web dashboard
- Withings, Rex.fit, or clinician search
- Food overview / restaurant favorites
- Custom Omnipod DASH radio patches (stay synced with LoopKit)
