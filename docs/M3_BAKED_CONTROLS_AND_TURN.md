# M3 — built-in first-person preset and mouse-turn correction

Status: staged patch authored; Windows source application, compilation, runtime and animation not yet tested.

## Built-in options
Driving uses eye-level view, camera-relative movement and facing, head aiming and a clean reticle regardless of conflicting legacy cx.cfg values. The six legacy knob declarations remain registered but are hidden from the settings panel. Action Camera begins enabled every session, and its existing shortcut temporarily releases or recaptures the cursor without changing cfg. The CX Driving master remains visible as an opt-out; Chase and Top-down retain their settings.

Driving camera lag in position, rotation and zoom is forced to zero at all camera reads, while the Smoothing slider is hidden. This does not remove native character animation or head-bone motion; it only eliminates mod camera lag.

## Turning correction
Previously, CameraDriveService slew-limited walking orientation to 540 degrees per second while HeadBoneCamera later wrote the newest camera yaw in the same turn. M3 eliminates the first-person drive slew and suppresses the later HeadBoneCamera writer while movement is held. Stationary mouse turns still use the head-camera facing writer. Native movement packets, collision and the rest of the J4 pose system remain unchanged. No new camera smoothing is introduced.

This is an isolated source correction for a likely competing-writers cause, not proof that all animation jitter is solved. Wall contact, helmets, jumping, combat and server reconciliation still need runtime verification. The existing SsaoPass.SelfCheck failure is a separate issue.

## Safe workflow
Apply the M3 patch only through M3_StageBaked.ps1 after checking the published M2 CameraKnobs hash. Build the separate stage with dotnet managed compiler and the Windows NativeAOT script, check the new DLLs, then construct a NEW pinned reversible installer. The existing M1_RuntimeSwitchFix1 installer only accepts the old M1 DLL hash and must not be used for M3. Never touch the original cx checkout, cx.cfg or the five-DLL rollback backup. Motion blur is deferred until turning quality is evaluated.


## M3 isolated source staging passed (2026-11-22)

The developer supplied `M3_BakedStageReport.txt` confirming:

```text
M3 SOURCE STAGE: PASS
M2: C:\Projects\NWN_FP_M2_SETTINGS_STAGE
M3: C:\Projects\NWN_FP_M3_BAKED_STAGE
M3 CameraKnobs SHA256: 59881B5270A25F62D75EEFEF82DCE186A262B309D02D24A7563CF793D35250DC
M1 game DLL, cx.cfg, backup, CX original, M1 and M2 source: UNCHANGED
Windows managed build, NativeAOT and animation runtime: NOT TESTED
```

This verifies separate-stage patch application, not compilation or character-turn smoothness.

### Next isolated gate: managed C# compilation

In the Visual Studio Developer Command Prompt:

```cmd
cd /d "C:\Projects\NWN_FP_M3_BAKED_STAGE"
dotnet build managed\cx_managed.csproj -c Release -r win-x64 -p:PublishAot=false -v:minimal > "C:\Projects\M3_ManagedCompile.log" 2>&1
echo M3_MANAGED_BUILD_EXIT=%ERRORLEVEL%
```

Upload `C:\Projects\M3_ManagedCompile.log` and its exit code. Do not install or overwrite any DLL. If compilation fails, the log will identify the precise M3 source errors; if it succeeds, plan an isolated NativeAOT Windows build and reverify all package hashes. Runtime jitter and mouse-capture behavior remain unverified until a guarded M3 installation and gameplay test.


## Isolated M3 managed compilation verified (2026-11-22)

The developer uploaded `M3_ManagedCompile.log`, generated in `C:\Projects\NWN_FP_M3_BAKED_STAGE` with:

```cmd
dotnet build managed\cx_managed.csproj -c Release -r win-x64 -p:PublishAot=false -v:minimal
```

Full log review confirms **Build succeeded, 150 warnings, 0 errors**, elapsed **9.21 seconds**. All warnings occur outside the modified `managed\Services\Camera` code. The warning profile matches the earlier managed baseline (63 CS0649, 30 CS0219, 14 CS0169, 13 CS8602, 11 CA2014, 5 CS8600, 5 CS8604, 4 CS0162, 3 CS0675, 1 CS8793 and 1 CS0414). The generated managed artifact is `managed\bin\x64\Release\net10.0\win-x64\cx_managed.dll`, **not** a NativeAOT game-installable `version.dll`.

### Next gate — Native Windows build in isolated M3 source

Run from the Visual Studio Developer Command Prompt:

```cmd
cd /d "C:\Projects\NWN_FP_M3_BAKED_STAGE"
git submodule update --init --recursive
echo M3_SUBMODULE_EXIT=%ERRORLEVEL%
```

Proceed only on submodule exit 0. Then:

```cmd
"C:\Program Files\Git\bin\bash.exe" ./build-win-native.sh > "C:\Projects\M3_NativeBuild.log" 2>&1
echo M3_NATIVE_BUILD_EXIT=%ERRORLEVEL%
```

Upload `M3_NativeBuild.log` and the exit code; on failure, do not retry without reviewing the error. A successful command exit does not replace the subsequent five-DLL PE/hash/ZIP integrity check and a new pinned reversible installer. **Do not deploy the M3 package or use the M1 hash-pinned switch script.** The installed M1 DLL, original CX checkout, `cx.cfg`, and rollback backup remain protected. Turning smoothness is untested until an actual M3 gameplay test.


## NativeAOT M3 build passed — five-DLL integrity gate (2026-11-22)

The developer reported `M3_NATIVE_BUILD_EXIT=0` and supplied `M3_NativeBuild.log`. The log records successful funchook, bootstrap/thunk, xatlas, audio, FSR 3.1, DoF permutations, NativeAOT linker and ZIP/package assembly. Two warnings about CMake compatibility and policy CMP0194 were nonfatal; no build errors appear. The native symbol check was **skipped** because `nwmain.exe` was not in the build's location. The full package contains five DLLs plus `README.txt` and `LICENSES.txt`, but the log alone does not prove file-by-file integrity.

Next, run the separate read-only [M3_VerifyNative.ps1](../src/first-person/milestones/M3/M3_VerifyNative.ps1). It pins the M3 staged CameraKnobs SHA-256 `59881B5270A25F62D75EEFEF82DCE186A262B309D02D24A7563CF793D35250DC`, checks the five AMD64 PE headers and byte-identical SHA-256 ZIP contents, checks both metadata files, confirms four companion DLLs remain equal to the previously installed M1 baseline, and records the **new, not-yet-pinned M3 `version.dll` SHA-256**. It refuses existing reports and never installs files.

```cmd
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/main/src/first-person/milestones/M3/M3_VerifyNative.ps1' -OutFile 'C:\Projects\M3_VerifyNative.ps1'"
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M3_VerifyNative.ps1"
```

Report: `C:\Projects\M3_NativeArtifacts.txt`. Upload the text report only. The verifier has **not** been run on Windows yet. No M3 installation should be attempted before examining the new package hash and preparing a separate, reversible switch that preserves the existing installed M1 `version.dll`, the previous original backup and `cx.cfg`. Do not use the old M1-pinned switch script to install M3.


## M3 NativeAOT artifacts verified; preserve currently installed M1 (2026-11-22)

The developer uploaded M3_NativeArtifacts.txt, confirming PASS for all five AMD64 DLLs and ZIP SHA-256 matches, and intact README and LICENSES ZIP entries. The new M3 version.dll is **25,254,400 bytes**, SHA-256 **1ec40d2fd60454dc92e8bfd29ca591600fba0db1d3f5e2ccc4232b09868e891d**. The four companion DLLs exactly match the prior verified M1 package. The source CameraKnobs checksum matches the staged M3 checksum (59881B5270A25F62D75EEFEF82DCE186A262B309D02D24A7563CF793D35250DC). NativeAOT packaging integrity has passed; runtime startup, menu, and mouse-turn behavior have not been tested.

The next safety gate is to preserve the **currently installed M1** runtime separately from the older pre-M1 backup. M3_BackupInstalledM1.ps1 refuses existing backup/report paths and verifies the installed executable, installed M1 DLLs, old pre-M1 backup, and new M3 stage package before copying all five installed M1 DLLs into C:\Projects\M3_PreM3_M1_Runtime_Backup. Each copy is independently SHA-256 verified, and a text report is written at C:\Projects\M3_M1_BackupVerification.txt. The script does not install M3 or modify the game/cx.cfg. It is statically checked but has not yet been executed on Windows.

Run with NWN closed:

~~~cmd
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/main/src/first-person/milestones/M3/M3_BackupInstalledM1.ps1' -OutFile 'C:\Projects\M3_BackupInstalledM1.ps1'"
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M3_BackupInstalledM1.ps1"
~~~

Upload only the verification text report. Stop for mismatched hashes or an existing backup, and preserve the original baseline backup. The next step is a scratch-only restore rehearsal before any new hash-pinned live M3 installer. The old M1 RuntimeSwitchFix1 tool is not suitable for installing M3.

## M3 backup preflight case-comparison fix (2026-11-22)

First Windows run of `M3_BackupInstalledM1.ps1` **failed safely before copying or creating its backup**, because `Assert-Hash` converted the computed SHA-256 to lowercase but used case-sensitive `-cne` against the uppercase pinned `CameraKnobs.cs` hash. The developer reported:

```text
expected=59881B5270A25F62D75EEFEF82DCE186A262B309D02D24A7563CF793D35250DC
actual=59881b5270a25f62d75eefef82dce186a262b309d02d24a7563cf793d35250dc
```

The two 64-character digests match byte-for-byte when hex letter case is normalized. Fix1 of the **M3 backup helper** changes only the comparison to `$sha -cne $expected.ToLowerInvariant()`. Hash verification remains strict for digest bytes, all expected pins remain the same, and the script still refuses pre-existing destinations or unsafe paths. The old downloaded `C:\Projects\M3_BackupInstalledM1.ps1` must be refreshed from this new commit before another run. Windows verification of the corrected helper is pending. No live M3 installation has occurred.


## Verified separate M1 rollback copy; scratch switch/restore gate (2026-11-22)

The developer uploaded `M3_M1_BackupVerification.txt`. It confirms **RESULT: PASS** for the independent five-DLL copy of the **currently installed M1 runtime** at `C:\Projects\M3_PreM3_M1_Runtime_Backup`. Its `version.dll` is SHA-256 `a3d65b433191ef652d5d03fc1ae3c6fa407f044c518c47d92111652d0079ac86` (25,240,064 bytes); four companion DLLs match their pinned hashes. The staged M3 `version.dll` SHA-256 `1ec40d2fd60454dc92e8bfd29ca591600fba0db1d3f5e2ccc4232b09868e891d` was independently verified. The game, pre-M1 original backup, original CX and `cx.cfg` were not modified.

The new **[M3_OfflineSwitchRestore.ps1](../src/first-person/milestones/M3/M3_OfflineSwitchRestore.ps1)** runs only in a fresh scratch directory `C:\Projects\M3_OfflineRollbackRehearsal`. Before writing, it checks the game is closed, asserts source/build and both rollback generations have expected hashes, and refuses an existing scratch/report. It copies M1's five DLLs into scratch, replaces only its scratch `version.dll` with M3 via a **named** `[IO.File]::Replace` backup, verifies the displaced M1 DLL, and reverses the operation with another named backup to restore M1; then re-verifies scratch five DLLs, installed five DLLs, game executable and independent backups.

**No real game replacement is executed by the rehearsal.** It preserves both named displaced scratch backups and writes a single report `C:\Projects\M3_OfflineRollbackReport.txt`. The script has been statically audited but **not executed on Windows**. A successful rehearsal is a prerequisite, not a substitute, for a separate checksum-pinned live M3 switch/restore implementation.

With NWN closed, download and execute this rehearsal, then upload the text report:

```cmd
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/main/src/first-person/milestones/M3/M3_OfflineSwitchRestore.ps1' -OutFile 'C:\Projects\M3_OfflineSwitchRestore.ps1'"
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M3_OfflineSwitchRestore.ps1"
```

Stop if there is an error. Do not delete a partial scratch directory, run an installer or attempt a manual DLL copy. M3 in-game turning, baked menu and remaining wall/helmet regressions remain untested.


## M3 offline installation and M1 rollback rehearsal passed (2026-11-22)

The developer uploaded `M3_OfflineRollbackReport.txt` confirming `M3 OFFLINE INSTALL + M1 RESTORE REHEARSAL: PASS`. In disposable `C:\Projects\M3_OfflineRollbackRehearsal`, all five baseline M1 DLLs matched hashes; named-backup `File.Replace` switched M1 to M3 (`version.dll` SHA-256 `1ec40d2fd60454dc92e8bfd29ca591600fba0db1d3f5e2ccc4232b09868e891d`) while preserving displaced M1 (`a3d65b433191ef652d5d03fc1ae3c6fa407f044c518c47d92111652d0079ac86`); another named-backup replacement restored M1 and preserved displaced M3. Four companion DLLs, installed game files and both independent rollback backups were reverified as unchanged. Source and `cx.cfg` were not written. **No M3 live installation, startup or animation test has yet occurred.**

### Next gate: M3 live-target read-only Status

New [M3_RuntimeSwitch.ps1](../src/first-person/milestones/M3/M3_RuntimeSwitch.ps1) implements three isolated actions: `Status` (read-only game verification), `InstallM3` (installs only the hash-pinned M3 `version.dll`), and `RestoreM1` (restores the exact saved M1 `version.dll`). Before any action, it verifies `nwmain.exe`, both verified rollback generations, M3 stage source and all five new release DLLs, and the four installed companions. It refuses unknown installed `version.dll` hashes, existing reports or protected report destinations. Switches use a GUID-named temporary file and a **named displaced-DLL backup** inside the game directory; the displaced file is never removed. `cx.cfg`, source checkouts and four companion DLLs are not modified. The script has passed static source checks; it has **not** been executed in the developer's Windows environment yet.

Download the script and run **only Status** first:

```cmd
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/main/src/first-person/milestones/M3/M3_RuntimeSwitch.ps1' -OutFile 'C:\Projects\M3_RuntimeSwitch.ps1'"
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M3_RuntimeSwitch.ps1" -Action Status
```

Upload `C:\Projects\M3_RuntimeSwitch_Status.txt`; expected `Result: READ_ONLY`, with installed M1 `version.dll` unchanged. **Do not run `InstallM3` until the report has been reviewed.** Once verified, that action switches only one game DLL to M3 under an exact checksum. If needed, `-Action RestoreM1` is the hash-pinned M1 restoration path, not the retired M1-to-original installer. A gameplay smoke test remains necessary before treating M3 menu, movement and mouse-turn animations as working.

## Final read-only live preflight passed (2026-11-22)

The uploaded `M3_RuntimeSwitch_Status.txt` shows `Result: READ_ONLY`, with M1's installed `version.dll` SHA-256 `a3d65b433191ef652d5d03fc1ae3c6fa407f044c518c47d92111652d0079ac86` unchanged before/after; all four companions, the M3 stage, and both rollback generations verified. M3 is cleared for the `InstallM3` action of the already-committed runtime switch, not for a separate chain of further pre-installation tests.

The release manifest [M3_RELEASE_MANIFEST.json](../src/first-person/milestones/M3/M3_RELEASE_MANIFEST.json) records the checked M3 NativeAOT output `version.dll` SHA-256 `1ec40d2fd60454dc92e8bfd29ca591600fba0db1d3f5e2ccc4232b09868e891d`, all five DLL sizes and hashes, source patch order, current stage location, and rollback routes. Actual in-game menu and movement outcomes remain **unverified** and are the next gate. Preserve the pre-M1 and M1 backups.

The process changes from here: versioned Git source commit and manifest for every milestone; consolidate repeatable build+hash checks; single protected switch/restore; then test gameplay instead of serializing redundant safe-to-repeat verifiers.
