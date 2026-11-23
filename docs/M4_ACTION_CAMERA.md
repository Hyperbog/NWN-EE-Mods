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
