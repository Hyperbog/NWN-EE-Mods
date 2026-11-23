# Enhanced First Person version register

| Version | Source milestone | Build verification | Gameplay verification | Runtime |
| --- | --- | --- | --- | --- |
| M1 | [M1 settings patch](../src/first-person/milestones/M1/EnhancedFirstPerson_CX_Settings.patch) | Windows DLL verified | Menu displayed; movement jitter/wall and helmet issues | Installed before M3 |
| M2 | [M2 menu clarity patch](../src/first-person/milestones/M2/M2_MenuClarity.patch) | Source staging passed | Not separately installed | Incorporated into M3 |
| **M3-rc1** | [M3 baked controls and turn correction](../src/first-person/milestones/M3/M3_BakedControlsAndTurn.patch) | Managed compile passed; NativeAOT and five-DLL ZIP integrity passed; offline M1↔M3 rollback passed; live read-only Status passed | **Pending immediate game test** | Ready for `InstallM3` |
| **M4-rc1** | [M4 mandatory Action Camera patch](../src/first-person/milestones/M4/M4_MandatoryActionCamera.patch) | Managed build passed (0 errors, 150 baseline warnings); NativeAOT packaged; five-DLL release ZIP integrity PASS | **Pending in-game test** | Ready for guarded `InstallM4`; M1 rollback preserved |

The source patch for each milestone is committed to Git. The exact compiled artifact digests, stage paths, provenance and rollback paths for **M3-rc1** are in [M3_RELEASE_MANIFEST.json](../src/first-person/milestones/M3/M3_RELEASE_MANIFEST.json). The M3 compiled DLL and ZIP are stored in the developer's existing Windows source stage, **not as binary files in Git**.

## Faster development workflow from M3 onward

Each change is a numbered source milestone committed to Git with its release manifest and exact build hash. Combine compilation, native release packaging and artifact verification into one gated build instead of separate manual cycles. Preserve a single known-good runtime backup and one guarded switch/restore script. Test in-game immediately after a verified build/install and record actual observations, instead of doing repeated offline rehearsals for every iteration. Only repeat extensive preflight when native hooks, DLL replacement mechanics, game executable hashes or rollback logic change.

**M3 live status evidence:** the developer-provided `M3_RuntimeSwitch_Status.txt` shows `Result: READ_ONLY`, game `version.dll` before/after SHA-256 `a3d65b433191ef652d5d03fc1ae3c6fa407f044c518c47d92111652d0079ac86`, both rollback generations and all companion DLLs verified. No game installation occurred in that Status action.

### Immediate M3 test

With NWN closed:

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M3_RuntimeSwitch.ps1" -Action InstallM3
```

Launch NWN and compare first-person menu, mouse turning idle and during walking, wall collision, helmet unequip, and combat animations. For a severe regression, close NWN and use `-Action RestoreM1`. The switch script writes separate non-overwriting reports for InstallM3 and RestoreM1. Do not use M1's older switch script for M3. Gameplay remains unverified until a real test.


## M4 source checkpoint

[M4_VERSION.json](../src/first-person/milestones/M4/M4_VERSION.json) records the exact patch, base-stage pin and staging recipe. M4 makes Action Camera mandatory in Driving and uses Z for temporary cursor release, while hiding obsolete control toggles. Build with [M4_StageBuild.ps1](../src/first-person/milestones/M4/M4_StageBuild.ps1), then record the new native DLL SHA-256 in Git before installation. Do not mistake a Git source commit for a committed executable binary.

## M5 source checkpoint — NPC dialogue camera

M4-rc1 was installed (report shows SWITCHED_AND_VERIFIED, M3→M4). The user observed the native conversation camera orbiting and zooming away from the eyes during NPC dialogue. The log confirms mode 2 with `gate: dialog camera`. [M5](../src/first-person/milestones/M5/M5_NpcDialogueCamera.patch) fixes the camera gate and separately frees the cursor, without changing chase/top-down, cutscenes or game files. The M5 patch and build script are versioned; Windows build/gameplay testing is pending.
