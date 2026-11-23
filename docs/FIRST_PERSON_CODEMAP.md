# J4 source map

Each file below has a header with its purpose and safety constraints; the original implementation remains unchanged after that header.

| File | Role |
| --- | --- |
| [`managed/Alloy/AlloyRenderer.Batches.cs`](../src/first-person/managed/Alloy/AlloyRenderer.Batches.cs) | Local player render-pass isolation |
| [`managed/Alloy/Db/DbKeyhole.cs`](../src/first-person/managed/Alloy/Db/DbKeyhole.cs) | Keyhole occlusion behavior |
| [`managed/Alloy/Scene/AlloyRenderer.DbPass.cs`](../src/first-person/managed/Alloy/Scene/AlloyRenderer.DbPass.cs) | First-person color-pass transform staging |
| [`managed/Alloy/Scene/AlloyRenderer.DbStage.cs`](../src/first-person/managed/Alloy/Scene/AlloyRenderer.DbStage.cs) | First-person per-pass stage restoration |
| [`managed/Framework/ClientApi.cs`](../src/first-person/managed/Framework/ClientApi.cs) | Engine API bridge |
| [`managed/Services/Anim/PoseService.cs`](../src/first-person/managed/Services/Anim/PoseService.cs) | Animated pose and model attachment observations |
| [`managed/Services/Camera/ActionFeedback.cs`](../src/first-person/managed/Services/Camera/ActionFeedback.cs) | Damage feedback and reticle hit crescents |
| [`managed/Services/Camera/AnimationCameraMotion.cs`](../src/first-person/managed/Services/Camera/AnimationCameraMotion.cs) | Camera response to animation |
| [`managed/Services/Camera/AnimationCameraSettings.cs`](../src/first-person/managed/Services/Camera/AnimationCameraSettings.cs) | Animation camera tuning |
| [`managed/Services/Camera/AttackCameraFollow.cs`](../src/first-person/managed/Services/Camera/AttackCameraFollow.cs) | Attack motion following |
| [`managed/Services/Camera/CameraDriveService.cs`](../src/first-person/managed/Services/Camera/CameraDriveService.cs) | Camera-relative driving and release diagnostics |
| [`managed/Services/Camera/CameraKnobs.cs`](../src/first-person/managed/Services/Camera/CameraKnobs.cs) | Camera and reticle configuration |
| [`managed/Services/Camera/CameraService.cs`](../src/first-person/managed/Services/Camera/CameraService.cs) | First-person camera orchestration |
| [`managed/Services/Camera/FirstPersonHeadFilter.cs`](../src/first-person/managed/Services/Camera/FirstPersonHeadFilter.cs) | Head/face render filtering |
| [`managed/Services/Camera/FirstPersonModelProbe.cs`](../src/first-person/managed/Services/Camera/FirstPersonModelProbe.cs) | Bounded model diagnostic |
| [`managed/Services/Camera/FirstPersonVisibility.cs`](../src/first-person/managed/Services/Camera/FirstPersonVisibility.cs) | Local player render visibility policy |
| [`managed/Services/Camera/FirstPersonWorldGuard.cs`](../src/first-person/managed/Services/Camera/FirstPersonWorldGuard.cs) | Camera vs. world clearance |
| [`managed/Services/Camera/Fix14CProbe.cs`](../src/first-person/managed/Services/Camera/Fix14CProbe.cs) | Earlier movement/animation diagnostic |
| [`managed/Services/Camera/HeadBoneCamera.cs`](../src/first-person/managed/Services/Camera/HeadBoneCamera.cs) | Animated head-eye sampling |
| [`managed/Services/Camera/HeadTrackService.cs`](../src/first-person/managed/Services/Camera/HeadTrackService.cs) | Player model head tracking |
| [`managed/Services/Camera/JumpPhysics/AirMomentumMotor.cs`](../src/first-person/managed/Services/Camera/JumpPhysics/AirMomentumMotor.cs) | Airborne horizontal steering |
| [`managed/Services/Camera/JumpPhysics/JumpMotor.cs`](../src/first-person/managed/Services/Camera/JumpPhysics/JumpMotor.cs) | Jump motor and trigger gating |
| [`managed/Services/Camera/JumpPhysics/JumpPositionService.cs`](../src/first-person/managed/Services/Camera/JumpPhysics/JumpPositionService.cs) | J4 world-space ballistic jump and landing |
| [`managed/Services/Camera/JumpPhysics/JumpPreview.cs`](../src/first-person/managed/Services/Camera/JumpPhysics/JumpPreview.cs) | Jump state preview and visual diagnostics |
| [`managed/Services/Camera/JumpPhysics/JumpWalkBridgeService.cs`](../src/first-person/managed/Services/Camera/JumpPhysics/JumpWalkBridgeService.cs) | Jump-to-native-walk bridge |
| [`managed/Services/Camera/JumpPhysics/RayCollisionWorld.cs`](../src/first-person/managed/Services/Camera/JumpPhysics/RayCollisionWorld.cs) | Existing horizontal collision checks |
| [`managed/Services/Camera/MouseLookService.cs`](../src/first-person/managed/Services/Camera/MouseLookService.cs) | First-person mouse-look and contextual dot |
| [`managed/Services/Camera/StepGuardService.cs`](../src/first-person/managed/Services/Camera/StepGuardService.cs) | Native movement/position observer |
| [`managed/Services/Camera/UniversalEyeClearance.cs`](../src/first-person/managed/Services/Camera/UniversalEyeClearance.cs) | C3C adaptive self-occlusion clearance |
| [`managed/Services/Hotkeys/HotkeyServerLinkService.cs`](../src/first-person/managed/Services/Hotkeys/HotkeyServerLinkService.cs) | Inbound message timing observer |
