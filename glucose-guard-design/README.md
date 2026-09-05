# Glucose Guard Design

Branding, iOS override icons, and a Kubernetes web shell for **Glucose Guard**.

This is **not** a fork of [LoopKit/LoopWorkspace](https://github.com/LoopKit/LoopWorkspace).
The iOS app stays in [iDustbin/LoopWorkspace](https://github.com/iDustbin/LoopWorkspace).
That fork syncs from LoopKit, then GitHub Actions pull `ios/` from this repo and
build TestFlight.

## Layout

- `branding/` — logo, SVG mark, color tokens
- `ios/` — `OverrideAssets*.xcassets` and display-name snippet
- `web/` — Vite + React branding shell (no glucose values)
- `deploy/k8s/` — Deployment, Service, Ingress
- `docs/step-1.md` — what ships now vs later

## Apply icons to a local LoopWorkspace checkout

From the LoopWorkspace root (requires `git` and this repo readable):

```bash
./Scripts/apply_glucose_guard_branding.sh
```

Or point at a local clone:

```bash
GLUCOSE_GUARD_DESIGN_PATH=/path/to/glucose-guard-design \
  ./Scripts/apply_glucose_guard_branding.sh
```

## Web shell

```bash
cd web
npm install
npm run dev
```

Production image:

```bash
docker build -t ghcr.io/idustbin/glucose-guard-web:local web
```

Apply manifests to a cluster when one exists:

```bash
kubectl apply -f deploy/k8s
```

Step 1 does **not** show live diabetic values. The shell is branding only.
