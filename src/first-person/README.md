# Enhanced First Person — J4 source archive

## Verified source

This snapshot preserves 30 C# source files from the last tested J4 development lineage. It consists of the pinned local NWNCX source commit, C3C camera fixes, D4/D5 diagnostics, R3 combat reticle, and J4 world-space jump.

Code comments were prefixed to each file without changing original C# implementation bytes. The manifest records both original and annotated SHA-256 hashes; strip the marked header to recover the original source.

**This is not standalone**. It depends on NWNCX:EE (`https://github.com/nwncxee/cx`) and the matching native hooks/build-specific ABI. Updating CX may overwrite or invalidate this integrated overlay. Do not mix version.dll from different builds.

The uploaded `cx.zip` has several source files that differ from the tested J4 lineage (including rendered body clearance and the red combat hit marker), despite having the J4 compiled DLL. The authoritative files in this archive were recovered from the prior checkpoint and development package fixtures, rather than copied from those mismatched files.

## Verification methodology

- 19 files recovered from `2470f0d27be0a29c152456aa60222f1f4fc25c34` using the uploaded checkout Git object database.
- 10 files recovered from the exact hash-validated C3C/D4/D5/R3/J4 package fixtures.
- 1 inbound observer source was reconstructed as the D4-approved addition to its pinned checkpoint file; it is one of the 30 total.
- No compiled DLLs, credentials, local config, private logs or backup state are in this archive.

## Files

- `managed/Alloy/AlloyRenderer.Batches.cs`: Local player render-pass isolation
- `managed/Alloy/Db/DbKeyhole.cs`: Keyhole occlusion behavior
- `managed/Alloy/Scene/AlloyRenderer.DbPass.cs`: First-person color-pass transform staging
- `managed/Alloy/Scene/AlloyRenderer.DbStage.cs`: First-person per-pass stage restoration
- `managed/Framework/ClientApi.cs`: Engine API bridge
- `managed/Services/Anim/PoseService.cs`: Animated pose and model attachment observations
- `managed/Services/Camera/ActionFeedback.cs`: Damage feedback and reticle hit crescents
- `managed/Services/Camera/AnimationCameraMotion.cs`: Camera response to animation
- `managed/Services/Camera/AnimationCameraSettings.cs`: Animation camera tuning
- `managed/Services/Camera/AttackCameraFollow.cs`: Attack motion following
- `managed/Services/Camera/CameraDriveService.cs`: Camera-relative driving and release diagnostics
- `managed/Services/Camera/CameraKnobs.cs`: Camera and reticle configuration
- `managed/Services/Camera/CameraService.cs`: First-person camera orchestration
- `managed/Services/Camera/FirstPersonHeadFilter.cs`: Head/face render filtering
- `managed/Services/Camera/FirstPersonModelProbe.cs`: Bounded model diagnostic
- `managed/Services/Camera/FirstPersonVisibility.cs`: Local player render visibility policy
- `managed/Services/Camera/FirstPersonWorldGuard.cs`: Camera vs. world clearance
- `managed/Services/Camera/Fix14CProbe.cs`: Earlier movement/animation diagnostic
- `managed/Services/Camera/HeadBoneCamera.cs`: Animated head-eye sampling
- `managed/Services/Camera/HeadTrackService.cs`: Player model head tracking
- `managed/Services/Camera/JumpPhysics/AirMomentumMotor.cs`: Airborne horizontal steering
- `managed/Services/Camera/JumpPhysics/JumpMotor.cs`: Jump motor and trigger gating
- `managed/Services/Camera/JumpPhysics/JumpPositionService.cs`: J4 world-space ballistic jump and landing
- `managed/Services/Camera/JumpPhysics/JumpPreview.cs`: Jump state preview and visual diagnostics
- `managed/Services/Camera/JumpPhysics/JumpWalkBridgeService.cs`: Jump-to-native-walk bridge
- `managed/Services/Camera/JumpPhysics/RayCollisionWorld.cs`: Existing horizontal collision checks
- `managed/Services/Camera/MouseLookService.cs`: First-person mouse-look and contextual dot
- `managed/Services/Camera/StepGuardService.cs`: Native movement/position observer
- `managed/Services/Camera/UniversalEyeClearance.cs`: C3C adaptive self-occlusion clearance
- `managed/Services/Hotkeys/HotkeyServerLinkService.cs`: Inbound message timing observer
