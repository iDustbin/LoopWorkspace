# Glucose Guard Design

iOS branding for **Glucose Guard**: logo, color tokens, Loop override app icons,
and native Xcode/SwiftUI screens from the Figma mobile theme
(Today / Learning / Healthway / +, CGM and pump detail, A1C).

Step 1 is **iOS only**. The Loop fork
[iDustbin/LoopWorkspace](https://github.com/iDustbin/LoopWorkspace) syncs from
[LoopKit/LoopWorkspace](https://github.com/LoopKit/LoopWorkspace). GitHub Actions
then apply `ios/` and publish to the existing TestFlight account.

## Layout

- `branding/` — logo, SVG mark, color tokens
- `ios/` — `OverrideAssets*.xcassets` and `display_name.xcconfig`
- `docs/step-1.md` — what ships now vs later

## Apply to a local LoopWorkspace checkout

From the LoopWorkspace root:

```bash
./Scripts/apply_glucose_guard_branding.sh
```

Or point at this folder:

```bash
GLUCOSE_GUARD_DESIGN_PATH=/path/to/glucose-guard-design \
  ./Scripts/apply_glucose_guard_branding.sh
```

The GitHub source of truth is [iDustbin/glucoseguard](https://github.com/iDustbin/glucoseguard).
This folder is the copy that Bootstrap publishes there, and the local fallback
if the remote is not cloned yet.
