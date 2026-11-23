# M1 — Enhanced First Person in CX settings

**Status (2026-11-22): patch committed; Windows build and in-game testing pending.** This is a settings-panel-only integration for the preserved J4 custom CX lineage. It is not a new DLL or a motion-blur implementation.

## What it changes

The existing **Driving** camera group's CX settings submenu moves under **Controls → Enhanced First Person** in `/settings`. It remains the `driving` knob group; existing `driving.*` keys, chat commands and values in `cx.cfg` are unchanged. Chase and Top-down stay in their existing submenus.

The Driving submenu exposes the following controls as ordinary rows: eye-level first person (`driving.firstperson`), mouse sensitivity (`driving.sens`), head tracking (`driving.headtrack`), reticle visibility (`driving.reticle`), and side-crescent target-damage feedback (`driving.hitmarker`). Action camera (`driving.action`) and the existing CX camera master (`driving.enabled`) remain separately controllable; all three switches are needed for the normal first-person path. Reticle style and clean-reticle presentation become **Advanced** rows.

Four existing Driving-only controls—camera offset X/Y, recenter, and right-drag—move to **Advanced**. This keeps the CX panel's maximum of 14 default-visible rows. No defaults, values, key names, input handlers, renderer passes, native collision, J4 jump, C3C clearance, or combat animations are modified.

## Applying to the matching development checkout

1. Keep your last-known-working J4 source, five-DLL runtime, and `cx.cfg` backed up. **Do not merge newer upstream CX DLLs into J4.** This patch is not a replacement for your working local changes.
2. Obtain [the M1 patch](../src/first-person/milestones/M1/EnhancedFirstPerson_CX_Settings.patch) and save it locally, e.g. `C:\Projects\M1_CX_Settings.patch`.
3. In a Git Bash or a Visual Studio command prompt with Git available, check before applying:

```cmd
git -C "C:\Projects\cx" apply --check "C:\Projects\M1_CX_Settings.patch"
git -C "C:\Projects\cx" apply "C:\Projects\M1_CX_Settings.patch"
git -C "C:\Projects\cx" diff -- managed/Services/Camera/CameraKnobs.cs
```

**If `--check` fails, stop:** your local source has drifted from the published J4 overlay. Do not use `--reject`, `--3way`, reset, clean, or force. Preserve your local audit and modified files for reconciliation. The published 30-file J4 archive and its SHA-256 manifest must remain untouched.

To undo this exact patch (only if the patched file has not been edited further):

```cmd
git -C "C:\Projects\cx" apply -R --check "C:\Projects\M1_CX_Settings.patch"
git -C "C:\Projects\cx" apply -R "C:\Projects\M1_CX_Settings.patch"
```

## Verification before installation

Build only against the compatible pinned CX source. Run CX's settings self-check: registry uniqueness, 14 User rows in the Driving submenu, and correct persisted legacy keys. Verify `/settings` visibility, toggle and slider persistence after restart, action-camera prerequisites, Chase/Top-down stability, disabled/re-enabled options, walk/run, blocked-wall contact, jumping, attacks and helmet swaps. Do not replace any game DLLs before a successful matching Windows build and reversible installer test.

**Not yet verified:** build, actual UI rendering, game persistence, input-release behavior, and runtime regression results. MB1 adjustable motion blur is a separate future milestone.
