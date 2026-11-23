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
