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


## Isolated NativeAOT Windows build passed (2026-11-22)

The developer ran `git submodule update --init --recursive` and the pinned stage's `build-win-native.sh` in the Visual Studio Developer Command Prompt. Reported exit codes were **M1_SUBMODULE_EXIT=0** and **M1_NATIVE_BUILD_EXIT=0**.

This confirms that the native build script returned success. **The native build log and generated artifacts were not uploaded or inspected**, so file-level integrity, CX initialization, settings-panel self-checks, and game behavior remain pending. The earlier managed build remained at **0 errors / 150 warnings**.

### Next gate — verify the five packaged DLLs without installing them

Use [M1_VerifyNative.ps1](../src/first-person/milestones/M1/M1_VerifyNative.ps1) to verify the stage's `cx-windows-x64` directory and ZIP. The script checks five expected DLL names, AMD64 Windows PE headers, non-missing readme/license files, SHA-256 equality of each DLL between directory and ZIP, and the presence of the staged M1 settings marker. It reads the staged artifacts and writes one report **outside** the stage: `C:\Projects\M1_NativeArtifacts.txt`. It does not copy, install, or modify DLLs, and refuses to overwrite an existing report.

```cmd
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/main/src/first-person/milestones/M1/M1_VerifyNative.ps1' -OutFile 'C:\Projects\M1_VerifyNative.ps1'"
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M1_VerifyNative.ps1"
```

If successful, upload `M1_NativeArtifacts.txt` (text metadata and hashes only; no executable DLLs). If unsuccessful, share the exact exception and do not install anything.

A source-build pass does not establish that the J4+M1 runtime will load or behave correctly. Dedicated off-device self-checks and a **reversible isolated game test** remain mandatory, including the known blocked-wall walking-in-place and helmet-swap running-in-place regression. Do not replace installed working DLLs or `cx.cfg` yet. The verifier has not yet been Windows-executed.


## Five-DLL NativeAOT artifact gate — passed (2026-11-22)

The developer supplied both `M1_NativeBuild.log` and `M1_NativeArtifacts.txt`. The native build log confirms MSVC compiled the funchook, bootstrap/thunk, xatlas, audio, FSR/DoF and NativeAOT components and packaged `cx-windows-x64/` and its ZIP. No error lines were reported; two informational CMake warnings concerned minimum version compatibility and policy CMP0194. The build **skipped a native symbol check** because the Windows script lacks `nwmain.exe`.

The verifier report lists all five expected AMD64 PE DLLs, with matching SHA-256 values in the package directory and ZIP. The aggregate DLL byte size is 89,197,208 bytes. These results establish **artifact-level integrity**, not startup, runtime self-check, gameplay safety or a functioning settings panel.

| DLL | Bytes | SHA-256 |
| --- | ---: | --- |
| `version.dll` | 25,240,064 | `a3d65b433191ef652d5d03fc1ae3c6fa407f044c518c47d92111652d0079ac86` |
| `cx_openal.dll` | 3,834,368 | `3963b06e319180700be0bcc0d027336664bb3a4975876b4a5442f10746fab5b4` |
| `phonon.dll` | 52,950,168 | `ca3dbc01dbc24492717011e80f6a51404ca143ae344ca660971d2c983f1e058d` |
| `shaderc_shared.dll` | 6,962,688 | `8e13592eac48b94755e4aa4c41552b210b41ca906d0bfe35b0a6d47a97d0b7c6` |
| `vma.dll` | 209,920 | `504da73d9a8bb5acca40d8b563d8898c536329de07a1638f8cd9dbe1126d661e` |

### Independent CX settings registry capacity check

The pinned CX registry `KnobGroup.SelfCheck.cs` enforces a maximum of 14 `Tier.User` rows per submenu. An independent declaration-level analysis of J4+M1's Driving group found 13 ordinary User knobs plus the one User-tier group master = **14**; the four new visible controls replace four previous default-visible controls moved to Advanced. This does not replace an actual runtime `KnobGroup.SelfCheck` or settings panel visual test.

### Read-only game preflight

The next safe gate is [M1_GamePreflight.ps1](../src/first-person/milestones/M1/M1_GamePreflight.ps1). Provide the actual folder containing `nwmain.exe` via `-GameBin`; it refuses CX source/staging paths and running game processes. It pins the five verified package SHA-256 hashes, reads the installed game executable and currently installed same-named DLL hashes without changing them, and saves `C:\Projects\M1_GamePreflight.txt` **outside the game and staging checkout**. The script does **not install or back up** any files. If the report exists, it refuses overwrite.

```cmd
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/main/src/first-person/milestones/M1/M1_GamePreflight.ps1' -OutFile 'C:\Projects\M1_GamePreflight.ps1'"
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M1_GamePreflight.ps1" -GameBin "FULL_DIRECTORY_CONTAINING_nwmain.exe"
```

Once the report is reviewed, create a verified restorable backup and test the new M1 package in a controlled, reversible install, followed by CX self-check logs, menu toggles/persistence, combat/reticle, walls, helmet swaps, jumping and movement regressions. **Never install the native package without a restorable current runtime snapshot.** Motion blur MB1 remains a separate milestone. The preflight script has not yet been Windows-tested.


## Read-only game preflight verified (2026-11-22)

The developer ran the game preflight against a real NWN:EE Steam installation. It confirmed `nwmain.exe` was **not running**, found all five existing DLLs, and reverified all five staged M1 DLLs against their pinned SHA-256 values. The installed `version.dll` was the only file differing from M1: old SHA-256 `b7d67f9cc95fdda93790f4e231d1f0f0066849c8a0645deef16ec5c0d5d7a3b0`, size **25,229,824** bytes; new M1 SHA-256 `a3d65b433191ef652d5d03fc1ae3c6fa407f044c518c47d92111652d0079ac86`, size **25,240,064** bytes. All four companion DLLs are identical to the package. The current game executable SHA-256 is `3b7cb1252e0edb2ce22d7971f333aade027039ae30a45b4bc64732c3e6bec73a`.

This is **not** a successful runtime test and no game or configuration files have been changed.

### Next gate: preserve five-DLL original runtime backup

The [M1_BackupInstalled.ps1](../src/first-person/milestones/M1/M1_BackupInstalled.ps1) script refuses an existing destination, rejects a running `nwmain.exe`, and revalidates the exact original `nwmain.exe` and five existing DLL SHA-256 hashes **before copying** anything. It writes copies of all five installed DLLs plus `BACKUP_MANIFEST.txt` to a new directory outside the game and both CX source trees. Each copied file is rehashed against both the original and the preflight checksum. It writes a short separate report at `C:\Projects\M1_BackupVerification.txt`. If any check fails, the source/game files are not modified; a partial backup is left intact for inspection rather than deleted.

```cmd
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/main/src/first-person/milestones/M1/M1_BackupInstalled.ps1' -OutFile 'C:\Projects\M1_BackupInstalled.ps1'"
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M1_BackupInstalled.ps1" -GameBin "D:\SteamLibrary\steamapps\common\Neverwinter Nights\bin\win32"
```

Expected output directory: `C:\Projects\M1_PreM1_Runtime_Backup` (five original DLL copies + manifest). Expected report: `C:\Projects\M1_BackupVerification.txt`. Upload **only the text report**; do not upload original DLLs or commit the private backup. No `cx.cfg` or `cx.log` data is read or modified. The script is currently **static-reviewed but not Windows-tested**.

The backup is prerequisite to any test installation, not an installation or proof that restoration succeeds. The next checkpoint is a separately guarded reversible install/restore procedure plus CX self-check/in-game test plan. Continue to leave working `version.dll` and the other installed DLLs unchanged.


## Original five-DLL backup verified (2026-11-22)

The user supplied `M1_BackupVerification.txt` showing `RESULT: PASS`. The backup contains the exact five installed DLL versions in `C:\Projects\M1_PreM1_Runtime_Backup`, with each independently checked against the game preflight hash. The `version.dll` backup remains the previous working package (`b7d67f9cc95fdda93790f4e231d1f0f0066849c8a0645deef16ec5c0d5d7a3b0`). The four other DLL hashes are unchanged between old and M1. The report confirms the source checkout, game installation and `cx.cfg` were not modified.

This establishes a valid **backup**, not yet a tested restore or functional M1 release.

### Next gate: offline copy-and-restore rehearsal

[M1_OfflineRollbackTest.ps1](../src/first-person/milestones/M1/M1_OfflineRollbackTest.ps1) uses the fully validated five-file hashes for both installed and M1 DLLs. It checks `nwmain.exe` is not running and verifies all source hashes before creating a new scratch directory `C:\Projects\M1_OfflineRollbackTest`. It copies each M1 DLL into that scratch directory, verifies each SHA-256, copies the original backup files back into scratch, re-verifies all original SHA-256s, and finally rechecks the real installed game hashes. The **game is never modified**. Output report: `C:\Projects\M1_OfflineRollbackTest.txt`, which is not overwritten if present. A partially created scratch directory is retained for inspection after failure. This verifies copy/restore **in scratch only**, not the ability to restore over a loaded game DLL or the extension's runtime behavior.

```cmd
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/main/src/first-person/milestones/M1/M1_OfflineRollbackTest.ps1' -OutFile 'C:\Projects\M1_OfflineRollbackTest.ps1'"
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M1_OfflineRollbackTest.ps1"
```

This helper is statically checked but **not yet Windows-executed**. After the report passes, prepare a separate guarded installer/restore pair with explicit verification. Until then, do not replace the working `version.dll` or any of the four companion DLLs.


## Offline rollback rehearsal verified — preparing guarded M1 switch (2026-11-22)

The developer uploaded `M1_OfflineRollbackTest.txt`, reporting `RESULT: PASS`: all five M1 DLLs copied into isolated scratch and hashed, all five original backed-up DLLs restored into scratch and rehashed, and the installed game binary/DLLs rechecked without modification. This is an **offline test only**; there has still been no game-directory installation or actual game launch of M1.

### Guarded switch procedure

[M1_RuntimeSwitch.ps1](../src/first-person/milestones/M1/M1_RuntimeSwitch.ps1) accepts three **explicit** actions: `Status` (read-only), `InstallM1` (installs M1's pinned `version.dll`), or `RestoreOriginal` (restores the pinned original `version.dll`). It verifies the exact game executable and all five original-backup checksums before any replacement; checks installed companion DLLs; refuses unknown installed `version.dll` hashes or a running NWN process; and installs/restores a hash-verified temporary file via a same-volume `System.IO.File.Replace` call. **Only `version.dll` is switched.** The other four installed DLLs, `cx.cfg`, and both CX source trees remain untouched. Restore does **not** require the staged M1 package to remain present. Reports are written under `C:\Projects\M1_RuntimeSwitch_<Action>.txt`, never silently overwritten.

Do not execute an install and a restore together. Run Status first and review its report:

```cmd
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/main/src/first-person/milestones/M1/M1_RuntimeSwitch.ps1' -OutFile 'C:\Projects\M1_RuntimeSwitch.ps1'"
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M1_RuntimeSwitch.ps1" -Action Status
```

**Optional controlled M1 install, only after deciding to accept a reversible runtime change:**

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M1_RuntimeSwitch.ps1" -Action InstallM1
```

**Restore the original tested baseline after exiting the game:**

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M1_RuntimeSwitch.ps1" -Action RestoreOriginal
```

The script does not launch the game or run CX self-checks. File replacement is an **actual game change**, unlike the preceding audit and scratch tests. A changed DLL may have runtime regressions even if it compiled and all hashes match. The script has been statically reviewed but has **not yet been executed on Windows**. If any action fails, do not bypass hash refusals or manually overwrite files; report the exact error and the installed `version.dll` SHA-256.

### Initial gameplay smoke test after a successful install

Start NWN:EE normally with the test DLL. Check that the game reaches the main menu without a CX initialization failure, open `/settings` in-game, verify Controls → Enhanced First Person and the regular/Advanced controls, then use a disposable offline save for the reticle, action camera, turning, walking against a wall, jumping, combat animations, and helmet unequip/re-equip. In particular, the previously observed blocked-wall walking-in-place and helmet-triggered running-in-place are **not known resolved** by M1. Exit the game before restoring the original baseline. Do not interpret a clean DLL hash as proof of gameplay correctness.


## Guarded runtime status action passed (2026-11-22)

The user ran the existing pinned `M1_RuntimeSwitch.ps1 -Action Status` on Windows and uploaded `M1_RuntimeSwitch_Status.txt`. The report states `Action: Status` and `Result: READ_ONLY`. Both before and after checksums of the installed `version.dll` are `b7d67f9cc95fdda93790f4e231d1f0f0066849c8a0645deef16ec5c0d5d7a3b0`, the verified original working build. The five original backup DLLs, four installed companion DLLs, and the expected `nwmain.exe` checksum passed. The script reported no modifications to `cx.cfg`, the game executable, or CX sources.

**Next checkpoint: optional user-executed, one-file runtime installation.** After closing NWN, run:

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M1_RuntimeSwitch.ps1" -Action InstallM1
```

Expected result: `M1_RuntimeSwitch_InstallM1.txt` reporting `SWITCHED_AND_VERIFIED` and the installed `version.dll` hash `a3d65b433191ef652d5d03fc1ae3c6fa407f044c518c47d92111652d0079ac86`. The other four DLLs remain unchanged. If the command fails, stop and report the exact exception; do not bypass the refused state or attempt a manual DLL swap.

After successful installation, start NWN, confirm the client and CX initialize, open `/settings`, and inspect **Controls → Enhanced First Person** including Advanced disclosure. Test camera/action activation and persistence in an offline save, and separately reticle, combat feedback, walls, helmet swaps, and jumping. The known blocked-wall walking-in-place and helmet-related running-in-place behaviors remain open regressions and were not corrected by M1, which is a settings UI change.

**Restoration command**, only with NWN closed:

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M1_RuntimeSwitch.ps1" -Action RestoreOriginal
```

Never run InstallM1 and RestoreOriginal together. Restore writes `M1_RuntimeSwitch_RestoreOriginal.txt` and verifies the original `version.dll` hash; the five-DLL backup remains intact. None of these game actions have yet been performed or verified in the developer's environment.


## M1 runtime installation blocked by File.Replace argument exception (2026-11-22)

The developer ran `M1_RuntimeSwitch.ps1 -Action InstallM1`. The procedure reached `[IO.File]::Replace($temp, $target, $null)` and PowerShell reported `ArgumentException: The path is not of a legal form` (three-argument Replace invocation). This was **not** a verified installation success. The script did not write an InstallM1 completion report. The installed DLL hash after the exception is **not yet observed** and must not be assumed unchanged.

Microsoft's `System.IO.File.Replace` documentation permits a null backup argument in principle but includes path-format exceptions; a Windows-specific invocation or path problem has not yet been isolated. Do **not** rerun InstallM1, make manual file replacements or claim game startup validation.

1. Re-run the existing **read-only Status** action with a fresh report output:

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M1_RuntimeSwitch.ps1" -Action Status -ReportPath "C:\Projects\M1_RuntimeSwitch_AfterError.txt"
```

2. Download and run [M1_ReplaceApiProbe.ps1](../src/first-person/milestones/M1/M1_ReplaceApiProbe.ps1). The probe creates **only disposable text files** under `D:\SteamLibrary\steamapps\common\M1_ReplaceApiProbe` (outside the game), attempts both null-backup and named-backup `File.Replace` invocations on the same volume, checks the resulting scratch contents, and writes `C:\Projects\M1_ReplaceApiProbe_Result.txt`. It **never reads or writes game DLLs**, the original backup or the CX checkout.

```cmd
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/main/src/first-person/milestones/M1/M1_ReplaceApiProbe.ps1' -OutFile 'C:\Projects\M1_ReplaceApiProbe.ps1'"
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M1_ReplaceApiProbe.ps1"
```

The probe refuses any existing scratch destination or report. If either script fails, collect the exact error and stop. After both reports are reviewed, correct the installer with an isolated regression test before any actual retry. Do not delete or overwrite the five-DLL backup. The diagnostic probe is statically checked but not yet executed on Windows.


## Post-failure diagnostics: File.Replace null backup fails, named backup succeeds (2026-11-22)

The user supplied both `M1_RuntimeSwitch_AfterError.txt` and `M1_ReplaceApiProbe_Result.txt`. The read-only status confirms installed `version.dll` remained SHA-256 `b7d67f9cc95fdda93790f4e231d1f0f0066849c8a0645deef16ec5c0d5d7a3b0`, matching the untouched original and saved five-DLL backup. All four installed companion DLLs and five original backup DLLs matched their pinned hashes.

The same-D-drive scratch probe on Windows PowerShell `5.1.26100.9711` and CLR `4.0.30319.42000` recorded:

- `NullBackup : FAIL` — `ArgumentException`, "The path is not of a legal form".
- `NamedBackup : PASS` — replacement and displaced-file backup contents verified.

The failure was in the script's three-argument `File.Replace` invocation with a **null backup path**, not in the compiled NativeAOT package. No game DLL was installed. The old `M1_RuntimeSwitch.ps1` is **retired and fail-closed** on GitHub; do not rerun an earlier locally downloaded copy.

### Fix1 isolated self-test (mandatory before retry)

The replacement [M1_RuntimeSwitchFix1.ps1](../src/first-person/milestones/M1/M1_RuntimeSwitchFix1.ps1) passes a uniquely named backup file on the **game's D: drive** to `[IO.File]::Replace` when switching versions. After the operation, it verifies the displaced DLL backup's pre-switch hash and the installed DLL's intended new hash; the extra displaced-file backup is retained in the game folder. The independently verified five-DLL baseline backup remains untouched. `RestoreOriginal` does not depend on the new package remaining available. Every action performs hash checks; the game must be closed for mutation.

Before attempting installation, run **only** the disposable-file `SelfTest`. It creates `D:\SteamLibrary\steamapps\common\M1_RuntimeSwitchFix1_SelfTest`, verifies a named-backup replacement of two small text files, and writes a report `C:\Projects\M1_RuntimeSwitchFix1_SelfTest.txt`. It refuses existing scratch or report destinations and does **not** touch any game file. The script is statically reviewed but has not yet been Windows-executed.

```cmd
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/main/src/first-person/milestones/M1/M1_RuntimeSwitchFix1.ps1' -OutFile 'C:\Projects\M1_RuntimeSwitchFix1.ps1'"
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M1_RuntimeSwitchFix1.ps1" -Action SelfTest
```

After the report passes, use Fix1 `Status` to check hashes again, and only then consider a user-executed `InstallM1` in a separate step. Do **not** run the old switch script. Source checkout, existing `cx.cfg`, and original backup must remain untouched.


## Fix1 scratch self-test passed on Windows (2026-11-22)

The developer uploaded `M1_RuntimeSwitchFix1_SelfTest.txt`, whose complete result is:

```text
M1 RUNTIME SWITCH FIX1 SELFTEST: PASS
Scratch: D:\SteamLibrary\steamapps\common\M1_RuntimeSwitchFix1_SelfTest
Named-backup File.Replace succeeded; destination and backup contents verified.
No game executable, DLL, backup, source or cx.cfg files accessed or modified.
Live installation and runtime startup: NOT TESTED.
```

This validates Fix1's disposable-file named-backup replacement procedure on the relevant Windows filesystem, **not** a live game installation or CX startup. The prior read-only post-error status showed the original installed `version.dll` was unchanged and the five-DLL backup was still valid.

### Next gate: read-only Fix1 status

Run the **new** guarded switch with `-Action Status`:

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M1_RuntimeSwitchFix1.ps1" -Action Status
```

Expected report: `C:\Projects\M1_RuntimeSwitchFix1_Status.txt`. Verify `Result: READ_ONLY` and the original installed `version.dll` hash `b7d67f9cc95fdda93790f4e231d1f0f0066849c8a0645deef16ec5c0d5d7a3b0` before allowing `InstallM1` on another turn. Do not run the retired original installer. A successful Fix1 status does not prove that M1 works in-game.


## Fix1 live status verification passed — controlled installation gate (2026-11-22)

The user uploaded `M1_RuntimeSwitchFix1_Status.txt`, showing `Action: Status` and `Result: READ_ONLY`. The pre/post checksums of installed `version.dll` are both `b7d67f9cc95fdda93790f4e231d1f0f0066849c8a0645deef16ec5c0d5d7a3b0` (original), and the script verified the four installed companion DLLs and all five original backup DLLs. The original CX checkout and `cx.cfg` were not modified. The empty named displaced-DLL backup line is expected for Status.

All prerequisites to a **user-executed controlled test installation** are now passed: managed compile, native build and five-DLL integrity, read-only game preflight, original backup, offline rollback rehearsal, scratch API probe, Fix1 scratch self-test and Fix1 read-only status. These gates do not prove runtime startup, CX self-checks or gameplay.

With NWN completely closed, run ONLY this command:

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M1_RuntimeSwitchFix1.ps1" -Action InstallM1
```

A successful switch should write `C:\Projects\M1_RuntimeSwitchFix1_InstallM1.txt` with `Result: SWITCHED_AND_VERIFIED`, installed `version.dll` SHA-256 `a3d65b433191ef652d5d03fc1ae3c6fa407f044c518c47d92111652d0079ac86`, and an additional named displaced-DLL backup path on the game volume. **Do not launch NWN until the InstallM1 report has been reviewed.** On failure, capture the exact exception and stop; do not use the retired old installer or manually copy DLLs.

With the game closed, `-Action RestoreOriginal` from the **same Fix1 script** can restore the original `version.dll` from the independently verified backup, while retaining a named displaced-file backup. Do not run install and restore together or remove the five-DLL baseline backup.


## Fix1 controlled M1 installation verified — game runtime smoke test next (2026-11-22)

The developer uploaded `M1_RuntimeSwitchFix1_InstallM1.txt`. It reports `Action: InstallM1` and **`Result: SWITCHED_AND_VERIFIED`** for game binary folder `D:\SteamLibrary\steamapps\common\Neverwinter Nights\bin\win32`:

- **Before:** `version.dll` SHA-256 `b7d67f9cc95fdda93790f4e231d1f0f0066849c8a0645deef16ec5c0d5d7a3b0` (original)
- **After:** `version.dll` SHA-256 `a3d65b433191ef652d5d03fc1ae3c6fa407f044c518c47d92111652d0079ac86` (new J4+M1 NativeAOT build)
- Four companion DLLs and all five original backup DLLs were independently verified.
- An additional named backup of the displaced original was left at `D:\SteamLibrary\steamapps\common\Neverwinter Nights\bin\win32\.m1fix1-571ae02d170a4013b21ac36bf13a8ef9.previous-version.dll.bak`.
- Original source checkout and `cx.cfg` were not modified.

**Installation integrity passed.** Runtime CX initialization, loaded module functionality, settings rendering, controls persistence and in-game behavior were **not** tested by the installer.

### Smoke test in NWN:EE (M1 only)

1. Launch NWN:EE normally; verify that the client reaches its main menu and loads a test offline character/module. If CX fails to load or the game crashes, stop and preserve the log.
2. Open chat and enter `/settings`. Navigate to **Controls → Enhanced First Person**; check whether the submenu exists, renders legibly, and shows normal and Advanced controls. Confirm Chase/Top-down remain independently accessible.
3. Inspect the master `driving.enabled`, `driving.firstperson`, and `driving.action` switches without changing existing defaults unnecessarily; these are separate prerequisites for the expected first-person path. Verify the visible sensitivity, head-tracking, reticle and hit-marker controls, and reticle-style / clean-reticle Advanced settings.
4. Change one harmless setting (e.g. sensitivity), document its starting value, close/reopen the panel and optionally restart to verify persistence. Restore the original value afterward.
5. Only after startup/menu verification, make a separate movement and combat regression pass: head camera, mouse-look, locomotion, wall contacts, helmet unequip/re-equip at a wall, jumping, combat animations and reticle feedback. The known blocked-wall and helmet movement regressions have **not** been fixed as part of M1.

If game startup, menu or stability fails, close the game before restoring the original build, using:

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M1_RuntimeSwitchFix1.ps1" -Action RestoreOriginal
```

Save `C:\Projects\M1_RuntimeSwitchFix1_RestoreOriginal.txt` if restoration is necessary. The script verifies exact original and new checksums and preserves another displaced DLL copy. Never use the retired original `M1_RuntimeSwitch.ps1`. Do not modify or remove the baseline backup at `C:\Projects\M1_PreM1_Runtime_Backup`.

Request from the developer: observed CX game startup result, screenshot or short description of **Controls → Enhanced First Person**, and the CX log for review if a self-check fails. Gameplay validation has not yet been observed.


## Initial in-game feedback — M2 corrective source audit (2026-11-22)

The developer confirms that **Controls → Enhanced First Person** appears in NWN:EE with installed M1. The **Head follows the crosshair** toggle appears ineffective, and several settings descriptions are difficult to understand. This is an in-game menu-visibility pass, **not** evidence that all toggles work. The user requests each toggle be checked, clearer labels/tooltips, then highest-quality motion blur.

Source audit identified that `driving.headtrack` controls the player's **look-at animation**, but `fphead.mode` separately controls how the first-person camera follows the animated head joint. `HeadTrackService.Wanted` already reads `MouseLook.HeadTrack.V` each frame and also requires the action-camera capture and valid animation hooks. The current toggle could therefore appear ineffective from first person. The actual animation-hook behavior requires runtime diagnostics and is **not yet fixed or proven**.

A second definite mismatch is `driving.face`: camera-facing movement is forced on during first-person action aiming, so its old visible toggle cannot affect that mode. The source-only M2 repair makes it Advanced and explains the limitation. Recenter and right-drag are similarly conditional. The source also showed that the optional cursor-release key is **Z**, contrary to the older Alt-toggle text.

[M2 source audit](M2_SETTINGS_AUDIT.md) and [M2 clarity patch](../src/first-person/milestones/M2/M2_MenuClarity.patch) preserve existing knob keys/defaults and J4 movement and rendering. The source patch was reconstructed and **applied in an independent patch-context simulation** against the published J4+M1 text (7 M1 hunks + 5 M2 hunks). Its Windows `git apply`, compilation and runtime remain unverified. Do not update the installed M1 DLL using this source patch until another isolated build and rollback verification.

### Next: create separate M2 settings source stage

Download the patch and stage helper from the audited GitHub commit, then run:

```cmd
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/main/src/first-person/milestones/M2/M2_MenuClarity.patch' -OutFile 'C:\Projects\M2_MenuClarity.patch'"
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/main/src/first-person/milestones/M2/M2_StageClarity.ps1' -OutFile 'C:\Projects\M2_StageClarity.ps1'"
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M2_StageClarity.ps1"
```

Expected report: `C:\Projects\M2_SettingsStageReport.txt`. This produces a separate `C:\Projects\NWN_FP_M2_SETTINGS_STAGE` and does not change `C:\Projects\cx`, installed DLLs, `cx.cfg` or the verified M1 stage.

**MB1 design direction:** reuse the pinned Alloy renderer's existing camera + per-object/skinned/dangly motion vectors and depth, then add a shutter-based, occlusion-aware, adaptive blur before HUD composite. The rendering order and upscaling compatibility must be audited against the **actual pinned source** before creating MB1 code. Motion blur is a separate milestone after the M2 in-game toggle audit.
