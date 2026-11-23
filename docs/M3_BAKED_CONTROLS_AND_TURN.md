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
