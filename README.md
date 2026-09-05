# LoopWorkspace (Glucose Guard)

This fork builds **Glucose Guard** on top of [LoopKit/LoopWorkspace](https://github.com/LoopKit/LoopWorkspace).

Two GitHub pieces, then one iOS build:

1. This repo is already the fork of [LoopKit/LoopWorkspace](https://github.com/LoopKit/LoopWorkspace).
2. [iDustbin/glucose-guard-design](https://github.com/iDustbin/glucose-guard-design) holds logo, icons, and the **GlucoseGuard** display name. The **Bootstrap Glucose Guard** Action creates that repo (via `GH_PAT`) and then starts **4. Build Loop**.
3. Build Loop clones the design repo, applies branding, and uploads to the existing TestFlight app (`com.TEAMID.loopkit.Loop`). No new Apple App ID.

Run **Bootstrap Glucose Guard** (or push to this branch) after `GH_PAT` is set. Then install the new TestFlight build to see icon and name.

For a local Xcode icon/name refresh after an upstream pull:

```
./Scripts/apply_glucose_guard_branding.sh
```

Or apply a local checkout of the design repo:

```
GLUCOSE_GUARD_DESIGN_PATH=/path/to/glucose-guard-design ./Scripts/apply_glucose_guard_branding.sh
```

The Loop app can be built using GitHub in a browser on any computer or using a Mac with Xcode.

* Non-developers may prefer the GitHub method
* Developers or Loopers who want full build control may prefer the Mac/Xcode method

## GitHub Build Instructions

The GitHub Build Instructions are at this [link](fastlane/testflight.md) and further expanded in [LoopDocs: Browser Build](https://loopkit.github.io/loopdocs/gh-actions/gh-overview/).

## Mac/Xcode Build Instructions

The rest of this README contains information needed for Mac/Xcode build. Additonal instructions are found in [LoopDocs: Mac/Xcode Build](https://loopkit.github.io/loopdocs/build/overview/).

### Clone

This repository uses git submodules to pull in the various workspace dependencies.

To clone this repo:

```
git clone --branch=<branch> --recurse-submodules https://github.com/LoopKit/LoopWorkspace
```

Replace `<branch>` with the initial LoopWorkspace repository branch you wish to checkout.

### Open

Change to the cloned directory and open the workspace in Xcode:

```
cd LoopWorkspace
xed .
```

### Input your development team

You should be able to build to a simulator without changing anything. But if you wish to build to a real device, you'll need a developer account, and you'll need to tell Xcode about your team id, which you can find at https://developer.apple.com/.

Select the LoopConfigOverride file in Xcode's project navigator, uncomment the `LOOP_DEVELOPMENT_TEAM`, and replace the existing team id with your own id.

### Build

Select the "LoopWorkspace" scheme (not the "Loop" scheme) and Build, Run, or Test.
