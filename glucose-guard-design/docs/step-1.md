# Glucose Guard — Step 1 (iOS only)

Branding source of truth for the Loop iOS fork (`iDustbin/LoopWorkspace`).

## Implemented now

- App name: **GlucoseGuard**
- Robot-cross logo on brand red (`#F4333C`)
- iOS and watchOS override app icons
- GitHub Actions on the Loop fork pull this tree **after** syncing
  `LoopKit/LoopWorkspace`, then Fastlane publishes to the existing TestFlight
  account

## Not in this step

- Kubernetes / web dashboard
- Live CGM, pump, or Nightscout values
- Withings, Rex.fit, or other third-party health APIs
- Medical-person search and dataset access requests
- Food overview (owned by another company / designer)
- Custom Omnipod DASH communication patches

Omnipod DASH drops on newer InPlay/Atlas pods (especially iPhone 16 / 17e) are
handled upstream. Stay synced with LoopKit so Pod Keep Alive (Loop 3.14+)
arrives through the fork-sync workflow.

## Later

- Separate design repo on GitHub
- Web/Kubernetes shell
- CGM detail, A1C/GMI, averages
