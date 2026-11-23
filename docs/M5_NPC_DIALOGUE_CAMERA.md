# M5 — Keep first-person camera during NPC dialogue

**Observed M4 regression.** The NPC screenshots show an external view and an extremely close-up player model during conversation, then restoration to normal FPS when dialogue ends. The uploaded log reports `[camera] ... gate: dialog camera, mode 2` repeatedly during Linu La'neral and Militia Soldier dialogue. M4 was installed successfully; the evidence implicates a camera gate rather than an unsuccessful build.

**Cause in code.** `CameraService.Check` returns `Gate.Dialog` whenever `CNWCModule.DialogCamera != 0`. `Adjust` immediately returns for non-active gates, so the engine's conversation camera is free to orbit and zoom instead of the player's eye-level camera. The same gate also stops Action Camera cursor capture; simply removing it would risk leaving the mouse trapped and make NPC replies unclickable.

## M5 isolated change

- Treat native NPC dialogue as an **active camera** only when Driving camera and built-in First Person are enabled. Chase, Top-down, cutscenes, server locks and genuine nonplayer attachments still use their existing gates.
- Maintain the player's eye camera every follow frame. On dialogue entry, save the pre-dialog yaw/pitch; hold that orientation throughout NPC conversation; clear conversation turn impulses. On dialogue exit, restore the saved orientation once before resuming normal mouse look.
- Independently block relative mouse capture during native NPC dialogue, so the dialog reply UI remains clickable. Action Camera is still a mandatory first-person feature; only **capture** pauses, not the camera pose.
- Preserve player model filtering/head visibility and avoid unrelated movement/animation changes.

## Build and test

Git contains the exact [M5 patch](../src/first-person/milestones/M5/M5_NpcDialogueCamera.patch) and [isolated stage/build helper](../src/first-person/milestones/M5/M5_StageBuild.ps1). Download both, then run the helper once. It copies from the verified M4-rc1 stage into a new M5 directory, applies the patch, compiles managed+NativeAOT, verifies release ZIP hashes and reports the new version DLL checksum. It does not install into the game or alter `cx.cfg`.

**Build gate:** Windows compilation is not yet proven. After the M5 report, commit the new exact checksum to Git and update the existing guarded runtime switch to accept M5. Then test two conversations, movement after exiting dialogue and Z cursor release without separate redundant preflight rounds.

**Preserved baseline:** M4 `version.dll` SHA-256 `29a719191b9f781a6c37193ffc7c6b8d23ed236c38f8857dd499145edefc70e2`. Current M4 install and existing M1/pre-M1 rollback backups remain intact.

## M5 build verified and guarded runtime installation

The user's `M5_StageBuildReport.txt` confirms **PASS** for managed/NativeAOT compilation and identical SHA-256 hashes for all five staged ZIP/folder DLLs. The M5 `version.dll` is `27dfa9eb49dff45b84d4e19c8fb0a67841514d413619f7f03cdcaf76802d9a3d` (25,260,032 bytes); M4's is `29a719191b9f781a6c37193ffc7c6b8d23ed236c38f8857dd499145edefc70e2`.

The screenshot and contemporaneous runtime `cx.log` still exhibit `gate: dialog camera, mode 2`, and no `[fpdialog]` entry. This is compatible with M4 still running: the M5 build helper deliberately does **not** install. A runtime hash check is required to establish exactly which version was loaded.

The new [M5 runtime switch](../src/first-person/milestones/M5/M5_RuntimeSwitch.ps1) allows only `Status`, `InstallM5` and `RestoreM4`. It checks `nwmain.exe`, original/M1 backup DLLs, M4/M5 DLL hashes and source markers, all four companion DLLs, and each DLL inside the M5 ZIP. Installation requires the game to be closed and the existing `version.dll` to equal verified M4 or M5. Only `version.dll` is replaced, using `File.Replace` with a retained unique named displaced backup; `RestoreM4` is the reversible option. `cx.cfg` is never touched. The script was reviewed statically; Windows runtime installation/test still awaits the user's run.
