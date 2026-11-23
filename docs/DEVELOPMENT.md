## Current J4 source checkpoint

[Enhanced First Person J4 source](../src/first-person/README.md) is preserved in 30 commented C# files with exact implementation checksums. The milestones below are historical; they do not describe the latest J4 runtime. See [features](FIRST_PERSON_J4.md), [source integration](FIRST_PERSON_SOURCE.md), and [provenance](PUBLICATION_PROVENANCE.md).

---

# First-Person Mod — Development

## Current baseline

The first-person controller, mouse-look, character-facing lock, jump motor, airborne steering, attack camera response and first-person wall/keyhole adjustments have been exercised in local Windows builds.

These are **experimental observations**, not a shipped compatibility guarantee. The working baseline currently exists in the developer's local NWNCX:EE checkout; the 30-file tested J4 source overlay has now been published under `src/first-person/managed/`; no public binary release has been published.

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

## Fix 14B — first runtime diagnostic results

A Windows gameplay log from the read-only probe confirms that the diagnostic runs: **24 snapshots**, **24 local model parts per snapshot**, **one mapped head part**, and **zero unrecognized model nodes** in the sampled character. The log is not published because it contains local system details.

Verified rendered part labels included:

- Equipped helmet: `helm_026` (`helm_026g`); unequipped head: `pmh0_head002` (`pmh0_head002g`).
- `pmh0_neck001`, approximately 0.08 m from the mapped head pivot.
- `pmh0_bicepl004` and `pmh0_bicepr004`, approximately 0.28 m from the head pivot.
- `pmh0_cloak_003` (`Cloak_Skin`), approximately 0.34–0.50 m from the head pivot.
- `pmh0_chest016` and `pmh0_pelvis008`, approximately 0.55 m from the head pivot.

A single sampled helmet-removal interval appeared before the same helmet returned in later snapshots. These are **part-pivot distances, not triangle-to-eye clearances**.

**Important runtime version finding:** the session identified itself as NWNCX:EE `v0.13.2-11-gb4b43a54` with original revision `b4b43a54`, despite a separately reported installation of a newer NWNCX version. The actual mod/game DLL set in this run is therefore still based on the older commit.

The log was configured with `general.logs=0`. No per-frame movement, collision-refusal, drive-state, actual horizontal displacement, or locomotion-state entries were captured. The log therefore **does not determine the cause of blocked-wall running-in-place or the helmet-change animation switch**.

**Relevant source-level mechanism:** the existing Fix 12 camera-only wall guard retracts the eye toward `feetXY + eyeZ - cameraForward * fpsurface.near` when blocked. That position can be inside the local character's torso/clothing. This is a likely contributor to the reported self-clipping, but needs a wall-contact runtime comparison to validate.

**Next milestone:** retain the working camera and combat tracking; add an opt-in blocked-drive state diagnostic comparing input-held, actual horizontal displacement, engine desired-position movement, camera retraction and animation ID. Separately test restricted first-person color rendering of the local neck/torso/cloak meshes during camera retraction, without changing shadows or other actors. Avoid source or DLL changes until those separate mechanisms can be validated.

### Fix 14C — movement/animation timeline (read-only experiment)

[Source: `FirstPersonMoveProbe.cs`](../src/diagnostics/FirstPersonMoveProbe.cs)

Adds bounded event logging to distinguish input and engine-driving intent from actual horizontal motion during wall contact, and to correlate this with animation IDs, desired-position gap, cumulative StepGuard refusal counters, and helmet/head model changes. It consumes the existing Fix14B `fpvisibility.probe` toggle; no movement, jump, camera, or rendering values are written. Events use the `[fpmove]` prefix in `cx.log`, capped at 160 lines per run. The triggers `wall-stall` and `uncommanded-gait` are heuristics, not confirmed causes.

Implementation has a separate **Fix14C local test package** with exact source rollback and independent DLL/`cx.cfg` backups. Python source-patch and installer simulations passed; .NET 10 / Windows build and gameplay verification are pending. The existing working Fix14B game DLLs must not be overwritten before BUILD_TEST succeeds. Collect a test timeline during: idle, ordinary run, holding W into a wall, releasing W, sprinting into the wall, and swapping helmets near a wall. Keep raw logs private.

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
