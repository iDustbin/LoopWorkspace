# Glucose Guard Design

iOS branding for **Glucose Guard**: logo and Home Screen name only.
The Loop fork
[iDustbin/LoopWorkspace](https://github.com/iDustbin/LoopWorkspace) syncs from
[LoopKit/LoopWorkspace](https://github.com/LoopKit/LoopWorkspace). **4. Build Loop**
applies `ios/` icons and `display_name.xcconfig`, then Fastlane uploads TestFlight.
Loop’s own HUD, charts, and bolus UI are not patched.

## Layout

- `branding/` — logo, SVG mark, color tokens
- `ios/` — `OverrideAssets*.xcassets` and `display_name.xcconfig`
- `docs/step-1.md` — what ships now vs later

## Apply to a local LoopWorkspace checkout

From the LoopWorkspace root:

```bash
./Scripts/apply_glucose_guard_branding.sh
```

```bash
python3 glucose-guard-design/ios/tests/test_hud_and_menu.py
```
