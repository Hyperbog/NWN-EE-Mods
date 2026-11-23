# M1 — J4 source-lineage audit results (2026-11-22)

**Scope:** user-run read-only audit of `C:\Projects\cx` against the 30 published J4 original implementation hashes in [SOURCE_MANIFEST.json](../src/first-person/SOURCE_MANIFEST.json).

| Finding | Observed |
| --- | --- |
| Local checkout branch | `main` |
| Local checkout HEAD | `2470f0d27be0a29c152456aa60222f1f4fc25c34` |
| J4-exact source files | **16/30** |
| Different source files | **14/30** |
| Missing source files | **0** |
| Tracked modified entries under `managed/` | **1,123** |

## Preserved exact J4 implementations

The camera animation motion/settings and attack follow files, the first-person head/visibility/world guard/probe, and all six jump-physics components are exact original-implementation matches. `UniversalEyeClearance.cs` is also exact. Exact source matches do not establish the runtime is consistent or reproducible.

## Divergent files requiring source inspection

- Rendering: `AlloyRenderer.Batches.cs`, `DbKeyhole.cs`, `AlloyRenderer.DbPass.cs`, `AlloyRenderer.DbStage.cs`
- Engine/animation: `ClientApi.cs`, `PoseService.cs`
- Camera/input/feedback: `ActionFeedback.cs`, `CameraDriveService.cs`, `CameraKnobs.cs`, `CameraService.cs`, `HeadTrackService.cs`, `MouseLookService.cs`, `StepGuardService.cs`
- Inbound message handling: `HotkeyServerLinkService.cs`

`CameraKnobs.cs` is an **exact match** to newer upstream CX (Git blob `e5f3ffdca4ac8d13f02b2c6630a65143537b9f11`). It lacks the custom J4 first-person and reticle declarations. The other 13 differences are **unclassified**: do not assume they are newer upstream or broken. The audit performs hash comparisons, not semantic diffs, compilation, or runtime checks.

## Follow-up: collect only 14 differing source files

The helper [M1_DriftBundle.ps1](../src/first-person/milestones/M1/M1_DriftBundle.ps1) copies precisely the 14 diverging C# files into `C:\Projects\M1_DriftSources.zip`, outside the CX checkout. It does not read or include `cx.cfg`, `cx.log`, savegames, binaries, backups, or Git objects. **Do not commit the ZIP to a public repository**; upload it only in the development conversation for a private source-level review. The collection script itself is committed to GitHub; the local sources are not.

```cmd
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/main/src/first-person/milestones/M1/M1_DriftBundle.ps1' -OutFile 'C:\Projects\M1_DriftBundle.ps1'"
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M1_DriftBundle.ps1"
```

If an archive with that output name already exists, the script refuses to overwrite it. This helper has been statically checked against the audit list but has **not yet been executed on the Windows development machine**.

## Build/release gate

No M1 patch or source overwrite is authorized by this audit. Preserve the last known working J4 runtime and source, diagnose the 13 other divergences, reconcile APIs, run the Windows CX self-checks and compile, then test in-game menu persistence and J4 movement/camera/combat safety before installing a matching five-DLL set.

