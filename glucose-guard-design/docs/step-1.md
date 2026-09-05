# Glucose Guard — Step 1 scope

This repository is the branding source of truth for the iOS Loop fork
(`iDustbin/LoopWorkspace`) and the Kubernetes web shell.

## Implemented now

- App name: **GlucoseGuard**
- Robot-cross logo on brand red (`#F4333C`)
- iOS and watchOS override app icons
- Dark and light theme tokens
- Status ring around the logo (green = mock “loop connected”)
- OneDrop-style placeholder navigation: Today, Learning, Healthway, + , Profile
- Kubernetes manifests for the web shell
- GitHub Actions on the Loop fork pull this repo **after** syncing
  `LoopKit/LoopWorkspace`, then Fastlane publishes to the existing TestFlight
  account

## Explicitly not in step 1

- Live CGM, pump, or Nightscout values
- Withings, Rex.fit, or other third-party health APIs
- Medical-person search and dataset access requests
- Food overview (owned by another company / designer)
- Custom Omnipod DASH communication patches

Omnipod DASH drops on newer InPlay/Atlas pods (especially iPhone 16 / 17e) are
handled upstream. Stay synced with LoopKit so Pod Keep Alive (Loop 3.14+)
arrives through the fork-sync workflow.

## Later

- CGM detail, A1C/GMI, averages for 3/7/30/90 days
- Bolus note + change control on the web dashboard
- Closed-loop status driven by real device telemetry
