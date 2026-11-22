# First-Person Mod — Development

## Current baseline

The first-person controller, mouse-look, character-facing lock, jump motor, airborne steering, attack camera response and first-person wall/keyhole adjustments have been exercised in local Windows builds.

These are **experimental observations**, not a shipped compatibility guarantee. The working baseline currently exists in the developer's local NWNCX:EE checkout; the complete tested source and redistributable build have not yet been published here.

## Fix 14B — read-only model diagnostic (experimental)

The [model-part probe source](../src/diagnostics/FirstPersonModelProbe.cs) is now tracked on `main`. Its local patch/build/test package is provided through the active development conversation, **not** published as a stable DLL release.

- Requires the existing custom Fix 14A first-person source; do not apply to a vanilla NWNCX checkout.
- New opt-in configuration: `fpvisibility.probe=1`.
- Every ~8 seconds (up to 24 snapshots), writes nearby part-pivot identifiers, model names, node names and attachment flags to `cx.log`.
- Changes no geometry, visibility decisions, camera pose, movement, animation, shadows, or collision.
- Designed to determine which **part hierarchy** contributes to first-person self-clipping; part pivots are not mesh-triangle bounds.

The upstream NWNCX:EE `main` HEAD inspected for this milestone was `44a12be8485b3994d390ebf3329705f4de40c40d`, **63 commits** ahead of the original custom patch base `b4b43a54ed68aa1072ce1715c0479b2fb127b5ef`. The camera service and SceneRay were unchanged in that comparison; rendering code changed. The local checkout version and Windows runtime remain to be verified.

**Test status:** Python source-patching, rollback, archive extraction and simulated DLL/config restoration passed. The .NET 10 smoke test and NWNCX:EE Windows build have not run in this environment; runtime behavior is unverified.
**Build compatibility correction:** The first Fix 14B package incorrectly checked for a `PartWorld[` usage in `SceneDb.cs`; that file declares `Matrix4x4[] PartWorld` without indexing it locally. The corrected `Fix14B_ApiFix` package validates the actual `PartModel`, `PartNode`, `PartWorld`, and `ObjAttachTo` typed declarations instead. Offline patch/rollback and installer tests pass; the corrected package still awaits a Windows NWNCX build and game test. No additional branch or GitHub release was created.


### First in-game model-probe results (local Windows test, 2026-11-21)

The Fix14B probe **ran successfully** and emitted 24 snapshots over about three minutes. It resolved all 24 local-player parts sampled each time (`unmapped=0`, `unknownModel=0`). Names of relevant parts included `helm_026`, `pmh0_head002`, `pmh0_neck001`, `pmh0_chest016`, `pmh0_bicepl004`, `pmh0_bicepr004`, and `pmh0_cloak_003` (`Cloak_Skin`). One sample recorded `pmh0_head002` between samples showing `helm_026`, confirming that the probe observes head model replacement when equipment changes.

Part pivots were approximately 0.07–0.08 m from the mapped head for helmet/neck, 0.28 m for upper arms, 0.34–0.50 m for cloak, and 0.55 m for chest. **These are not mesh extents or camera collision measurements**; never use them alone to decide what geometry to hide.

The same log still reports NWNCX build `b4b43a54` as its runtime base. Replacing NWNCX binaries with a custom patch build may have overwritten a newer installed release. The startup also had `general.logs=0`; while the probe logged, it did not capture actionable drive-state, actual-displacement, step-refusal, or animation-transition evidence. Do not attribute the reported wall-running or helmet-induced run-in-place to any one subsystem yet.

**Next isolated diagnostic:** correlate drive intent and key state, physical horizontal position change, engine desired/corrected position, step-guard result, animation ID and gait phase, and equipment changes over the same frame. Instrument only, leave movement/animation physics unchanged until a failing timeline exists.

Do not publish raw game logs or screenshots containing local user information.

## Priority: first-person character rendering

**Observed defect:** the camera can see through or intersect the local character's head, torso, clothing, armor, or other equipment, especially during attack animations and near walls.

Planned approach:

1. Instrument the renderer to identify the local player's current model, rig, animated parts, attachments and draw calls.
2. Distinguish head and torso meshes from hands, weapons and shields; support helmet replacements and custom models.
3. Apply *local-player, first-person, color-pass-only* visibility filtering; do not delete parts from the world.
4. Preserve shadows, NPC rendering, third-person character visibility, attack animation and equipment state.
5. Fail conservatively for unknown rigs; expose diagnostics and a switch to disable the experiment.

**Non-goal:** hide the whole character permanently. The intention is an immersive body-aware first-person view.

## Compatibility matrix

Test each milestone against:

| Area | Cases |
| --- | --- |
| Character | Different playable races, sexes, phenotypes and sizes |
| Equipment | No helmet, helmets, robes, heavy armor, cloaks, weapons and shields |
| Combat | One-handed, two-handed, dual-wield, ranged, unarmed/monk, spells and unusual animations |
| Movement | Stand, run, strafe, jump from standstill, moving jump, midair steering and landing |
| Geometry | Walls, corners, doors, ceilings, tight interiors, ramps and area transitions |
| View | Free look, 180° turns, look down, attack tracking, third-person switching |
| Content | Base-game models plus representative community/custom models |

Record **build revision, settings, appearance, equipment, animation, observed result and screenshot** for each failure.

## Release gates

A release requires: a reproducible Windows x64 build; passing automated smoke tests; reversible installation; no regression in first-person controls and jump physics; documented supported game/client configuration; and completed representative compatibility testing.

Local source backups and game DLLs belong outside this public repository. Once validated, publish cohesive source changes rather than a chain of numbered hotfix archives.

## Branch policy

Use **`main` only**. Development milestones are tracked by commits and, once stable, GitHub Releases. Do not create feature/fix branches.
