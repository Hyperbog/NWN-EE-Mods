> **Historical record — not current instructions.** See [STATUS.md](../../STATUS.md) for current evidence and the [original snapshot](https://github.com/Hyperbog/NWN-EE-Mods/blob/bc3b0b4a6c1a0624602344b0636ebdc4cc3e9763/docs/M4_ACTION_CAMERA.md) for links in their original context.

# M4 — Mandatory Action Camera

**Source milestone:** Derived from the verified M3 source without altering M3, M2, M1, the original CX checkout, the game, or any rollback backups.

Action Camera is now a permanent Driving-mode capability, not a user preference. `driving.action=off` and `driving.mouselook=off` in old `cx.cfg` are ignored by effective runtime gates; the legacy declarations remain only for config compatibility. The former `driving.actionkey` binding is ignored in Driving, so it cannot turn aiming off. The Action Camera toggle and action-key control are not exposed in the Enhanced First Person panel. Chase and Top-down keep their existing optional Action Camera configuration.

**Cursor safety:** Press **Z** to release or recapture the cursor. This pauses relative mouse capture and hides the crosshair but **does not disable Action Camera**. Dialogs, chat, Settings, UI ownership, loss of focus, free camera, and switching out of Driving still release mouse capture when required. Turning off the overall CX Driving camera master also releases Action Camera at the next input event; it remains the emergency escape hatch.

**Removed from the Driving menu as ineffective under mandatory Action Camera:** enable mouse-look, right-drag looking, turn-keys side-run, automatic recenter, Action Camera, and Action Camera toggle key. The old config knobs remain registered but no longer control those effective Driving behaviors. Mouse sensitivity and vertical inversion remain functional. Reticle, hit feedback and aim assist remain configurable.

First-person movement treats Action Camera as enabled even while Z temporarily releases capture, avoiding a switch to alternate movement controls. The camera likewise keeps its first-person collision and recenter gating while the cursor is released. No new animation smoothing, camera lag, shader effects, or wall/helmet fixes are introduced by M4.

## Faster gate

Use `M4_StageBuild.ps1` to copy the verified M3 source to a fresh M4 directory, apply the M4 patch, compile managed code, build NativeAOT, and verify five ZIP-to-folder DLL hashes **in one command**. The script refuses existing output destinations. It writes `C:\Projects\M4_StageBuildReport.txt` containing the new version.dll SHA-256. Do not install a new DLL before the new hash is recorded in Git and a single guarded switch is pinned to it.

Compiled DLLs/ZIP are produced locally in `C:\Projects\NWN_FP_M4_ACTION_STAGE` rather than committed into Git; the repository commits the source patch, build recipe and version record. The previous M3 build, M1 backup and original backup are unchanged. In-game validation of mandatory aiming and cursor behavior remains pending.

## M4 Build Fix1 — automatically select an unused stage

The first Windows invocation of M4_StageBuild.ps1 stopped safely at `Refusing existing M4 directory: C:\Projects\NWN_FP_M4_ACTION_STAGE`. No compilation was attempted in that invocation. A prior or partial M4 stage already occupies the default path.

Fix1 retains all existing stages and logs. Before copying anything, the script finds an unused group of five paths: stage, report, managed log, native stdout log and native stderr log. If the original names exist, the script selects `_R02`, then `_R03`, etc. through `_R99`. It displays the selected stage and report and writes the four build output paths into the final report. All original source, pre-M1 and pre-M3 backups, and installed game remain protected. It never deletes or overwrites a previous stage/report/log. The patch itself is unchanged, so this is a build-workflow fix, not a new gameplay version.

Replace the local `M4_StageBuild.ps1` with the Fix1 version and run it again. The existing M4 directory must **not** be manually removed. Windows execution of Fix1 remains unverified until the developer provides its report.


## M4 Windows build checkpoint — logs received (2026-11-23)

Developer-supplied logs for `C:\Projects\NWN_FP_M4_ACTION_STAGE_R02` confirm the managed build succeeded with 0 errors and 150 warnings in 11.61 seconds. The warnings are in non-M4 code paths and match the M3 count. Native stdout shows all compilation stages, NativeAOT link and release output containing five DLLs, README and licenses, with ZIP packaging. Native stderr contains two nonfatal CMake policy/deprecation warnings and notes that the standalone `nwmain.exe` symbol check was skipped. These three logs do **not** include the per-DLL SHA-256 values or the final five-file folder-versus-ZIP verification outcome; that appears in the separate `M4_StageBuildReport_R02.txt` written by the consolidated stage script. Await that report, then pin the exact `version.dll` hash in Git and prepare a version-specific reversible M4 switch. There is no need to rerun compilation from these logs alone.


## M4-rc1 release — ready for gameplay (2026-11-23)

The uploaded `M4_StageBuildReport_R02.txt` reports `M4 ACTION CAMERA STAGE + NATIVE BUILD: PASS`. All five DLL files exactly match ZIP SHA-256 values. The new `version.dll` is 25,258,496 bytes with SHA-256 `29a719191b9f781a6c37193ffc7c6b8d23ed236c38f8857dd499145edefc70e2`; four companion DLLs are byte-identical to the verified M3/M1 package. See [M4_VERSION.json](../src/first-person/milestones/M4/M4_VERSION.json).

The [M4_RuntimeSwitch.ps1](../src/first-person/milestones/M4/M4_RuntimeSwitch.ps1) installer accepts installed M1, M3 or M4 `version.dll` hashes, rejects unknown binaries, validates the staged M4 DLL, CX game executable and both original/M1 rollback generations, and replaces **only** `version.dll`. It preserves a GUID-named displaced DLL backup in the game directory. `RestoreM1` returns to the existing verified M1 backup without touching `cx.cfg` or source. This script has not yet been executed on the user's Windows machine.

With NWN:EE closed, download the script and run `-Action InstallM4`. Upload the single installation report `C:\Projects\M4_RuntimeSwitch_InstallM4.txt` and begin immediate gameplay testing, including cursor release/reacquire via Z, mouse turning while walking, menus and chat, helmet changes, wall contact and attacks. If gameplay breaks, close the game and run `-Action RestoreM1`. No further offline rehearsals are required for this already-tested File.Replace mechanism.
