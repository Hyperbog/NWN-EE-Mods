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


## Exact upstream comparison of uploaded 14-file ZIP

The ZIP contains 14 precisely named C# files. Independent Git blob hashes computed from the ZIP bytes matched all 14 file blobs in upstream `nwncxee/cx` at revision `66fcc820ef746fdf155b81309f63e7da52d5c865` (100%). This is **byte-for-byte equality**, not an inference from source names, file lengths, or the earlier SHA-256 audit. No other unknown J4 variants remain among the audited 30 files.

| Local ZIP source | Git blob SHA (first 12) | Classification |
| --- | --- | --- |
| `managed/Alloy/AlloyRenderer.Batches.cs` | `21f0a49eaa0b` | Exact upstream CX |
| `managed/Alloy/Db/DbKeyhole.cs` | `ea418353171b` | Exact upstream CX |
| `managed/Alloy/Scene/AlloyRenderer.DbPass.cs` | `21bf53338920` | Exact upstream CX |
| `managed/Alloy/Scene/AlloyRenderer.DbStage.cs` | `09262644df8f` | Exact upstream CX |
| `managed/Framework/ClientApi.cs` | `79959847a042` | Exact upstream CX |
| `managed/Services/Anim/PoseService.cs` | `fdafd8e4b5e8` | Exact upstream CX |
| `managed/Services/Camera/ActionFeedback.cs` | `762bc8121c7a` | Exact upstream CX |
| `managed/Services/Camera/CameraDriveService.cs` | `f1584bcd3d8d` | Exact upstream CX |
| `managed/Services/Camera/CameraKnobs.cs` | `e5f3ffdca4ac` | Exact upstream CX |
| `managed/Services/Camera/CameraService.cs` | `24d4c6e608b1` | Exact upstream CX |
| `managed/Services/Camera/HeadTrackService.cs` | `483e3d8254da` | Exact upstream CX |
| `managed/Services/Camera/MouseLookService.cs` | `472f5f77e257` | Exact upstream CX |
| `managed/Services/Camera/StepGuardService.cs` | `f1d79c292faf` | Exact upstream CX |
| `managed/Services/Hotkeys/HotkeyServerLinkService.cs` | `1b1c3d85e5f8` | Exact upstream CX |
The other 16 audited files matched the published J4 normalized implementation checksums. The local clone's additional 1,123 tracked modifications were not audited by this 30-file comparison.

### Separate, guarded M1 staging

Use [M1_StageJ4.ps1](../src/first-person/milestones/M1/M1_StageJ4.ps1). It makes an independent **local Git clone of pinned checkout HEAD 2470f0d**, downloads the 30 annotated J4 sources from immutable public commit `796a222cec17dfefe455ae42c8a97e149c33cee4`, checks each file against the published SHA-256 in `SOURCE_MANIFEST.json`, copies them into **the clone only**, and applies the M1 menu patch from immutable commit `55bb687c0116fadd6ddb6ff6a56dae5a034df318` there.

Default staging directory: `C:\Projects\NWN_FP_M1_J4_STAGE`. The tool refuses an existing or nested destination and a changed local HEAD. It **never overwrites files in C:\Projects\cx** and never installs DLLs. After successful source staging, a compatible Windows build and self-check are still required; the script does not establish runtime behavior or prove that non-overlay dependencies are present. It uses Git and HTTPS, and is not yet Windows-tested.

```cmd
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/main/src/first-person/milestones/M1/M1_StageJ4.ps1' -OutFile 'C:\Projects\M1_StageJ4.ps1'"
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M1_StageJ4.ps1"
```

If Git clone or download fails, leave the partial staging directory alone for inspection rather than rerunning over it. Never reset, clean, overwrite, or replace the existing working checkout. Do not install any new DLLs until separate-stage build and full gameplay regression pass.

## Staged reconstruction completed on Windows (2026-11-22)

The developer executed M1_StageJ4.ps1 in the Visual Studio 2026 Developer Command Prompt. The run succeeded: a local clone at C:\Projects\NWN_FP_M1_J4_STAGE was created from pinned HEAD 2470f0d27be0a29c152456aa60222f1f4fc25c34, all 30 published J4 source files printed VERIFIED J4, and the M1 settings patch passed git apply check and application. The script reported STAGING READY and explicitly made no changes to the original C:\Projects\cx source, game DLLs, or cx.cfg.

A separate git status --short in the stage showed **29 tracked modified C# files plus one untracked UniversalEyeClearance.cs**, matching the expected 30-file overlay. This is a valid staging state, not a failed or incomplete apply. The source tree is **not yet compiled, self-checked, or game-tested**.

### Next gate: managed compile-only test

From a Windows Visual Studio Developer Command Prompt:

```cmd
cd /d "C:\Projects\NWN_FP_M1_J4_STAGE"
dotnet --version
dotnet build managed\cx_managed.csproj -c Release -r win-x64 -p:PublishAot=false -v:minimal > "C:\Projects\M1_ManagedCompile.log" 2>&1
echo M1_MANAGED_BUILD_EXIT=%ERRORLEVEL%
```

The test uses the staged project and writes build artifacts only under its own project/build cache. This is a C# compile and dependency-compatibility gate; it is **not NativeAOT compilation**, native DLL packaging, CX self-check, or in-game validation. Return the exit code and compiler errors from M1_ManagedCompile.log. Do not copy or install any game files.

If managed compile succeeds, run the native Windows build later from the same isolated stage, after initializing the funchook submodule:

```cmd
git -C "C:\Projects\NWN_FP_M1_J4_STAGE" submodule update --init --recursive
cd /d "C:\Projects\NWN_FP_M1_J4_STAGE"
"C:\Program Files\Git\bin\bash.exe" ./build-win-native.sh > "C:\Projects\M1_NativeBuild.log" 2>&1
echo M1_NATIVE_BUILD_EXIT=%ERRORLEVEL%
```

The native build creates local artifacts only. CX's build-win-native.sh is documented in the upstream source and requires VS/MSVC, Git Bash, .NET 10, CMake and Python, along with its fetched native dependencies. A successful native build is still not permission to install: self-checks, five-DLL consistency, install/rollback, and J4 wall/movement/jump/combat regressions remain gates.


## M1 managed compilation gate — passed (2026-11-22)

The developer ran the documented isolated-stage command:

```cmd
cd /d "C:\Projects\NWN_FP_M1_J4_STAGE"
dotnet build managed\cx_managed.csproj -c Release -r win-x64 -p:PublishAot=false -v:minimal > "C:\Projects\M1_ManagedCompile.log" 2>&1
echo M1_MANAGED_BUILD_EXIT=%ERRORLEVEL%
```

**Observed:** `M1_MANAGED_BUILD_EXIT=0`, `Build succeeded.`, **150 Warning(s)** and **0 Error(s)**, as independently checked from the uploaded `M1_ManagedCompile.log`. The build restored the managed project and analyzer project, compiled `cx_analyzers`, and wrote `managed\bin\x64\Release\net10.0\win-x64\cx_managed.dll` in the isolated stage. Because `PublishAot=false` was passed, this is a **non-deployable managed compatibility build**, not the NativeAOT extension.

Warnings were 63 × CS0649, 30 × CS0219, 14 × CS0169, 13 × CS8602, 11 × CA2014, 5 × CS8600, 5 × CS8604, 4 × CS0162, 3 × CS0675, 1 × CS8793, and 1 × CS0414. The preserved `AlloyRenderer.Batches.cs` contributes five warnings; no warnings or errors were reported in `CameraKnobs.cs`. These warnings should be tracked separately from M1 functional verification and do not require broad J4 rewrites to establish menu integration.

### Next gate: isolated NativeAOT Windows build

Run in the **same** Visual Studio Developer Command Prompt that has working MSVC, .NET 10, CMake, Python, and Git Bash:

```cmd
git -C "C:\Projects\NWN_FP_M1_J4_STAGE" submodule update --init --recursive
cd /d "C:\Projects\NWN_FP_M1_J4_STAGE"
"C:\Program Files\Git\bin\bash.exe" ./build-win-native.sh > "C:\Projects\M1_NativeBuild.log" 2>&1
echo M1_NATIVE_BUILD_EXIT=%ERRORLEVEL%
```

Verify submodule initialization succeeded before proceeding. The upstream `build-win-native.sh` builds Windows NativeAOT and packages `cx-windows-x64\` within the **stage**, including `version.dll`, `cx_openal.dll`, `phonon.dll`, `shaderc_shared.dll`, and `vma.dll`. The build can fetch dependencies and modify generated/build files within staging; it is not an installer.

For a failed build, collect errors without uploading private game configurations:

```cmd
powershell -NoProfile -Command "Get-Content -LiteralPath 'C:\Projects\M1_NativeBuild.log' -Tail 80"
```

**Do not copy the new five DLLs into the game.** Native build success is not CX self-check success and does not verify runtime behavior, settings persistence, or the J4 wall/helmet movement regression.
