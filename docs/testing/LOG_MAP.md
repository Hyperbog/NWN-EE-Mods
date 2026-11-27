# M11 subsystem log map — Phase 3.3

READ against CX commit [b7895ed](https://github.com/Hyperbog/cx/commit/b7895eda58cb1124e98a27109a1acc79e8544c6b). OBSERVED examples: [revision 2 results](RESULTS/2026-11-26-M11-revision2.md). These are existing emitters, not proposed diagnostic code. Recheck after any source pin change.

## Capture and interpretation

Use the game-generated cx.log and rotated cx.1.log in the NWN user directory. Preserve both after closing the game. Record test ID, local timestamp/offset, exact release and installed hashes, input order and observed result. Enable general.logs=1 only for an agreed diagnostic session if needed; preserve and restore the previous setting. [ExtenderLog](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Framework/ExtenderLog.cs#L5-L49) gates Info, but Always bypasses the gate; queued lines may be lost on crash. Self-check fixtures are not gameplay events. Do not publish raw logs, native pointers, private paths or chat/dialogue text. Preserve original excerpts privately and mark redactions.

## Existing emitters

| Marker | Source / cadence | Meaning and limits |
| --- | --- | --- |
| EFP M11: | [CameraService](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Camera/CameraService.cs#L136-L146) startup | Architecture banner, not exact DLL identity. |
| [camera] | [CameraService](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Camera/CameraService.cs#L825-L839) every 600 presents with logging | Mode, yaw/pitch, FOV and aggregate pull-ins; not per-frame actor/eye position. |
| [m11drive] | [CameraDriveService](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Camera/CameraDriveService.cs#L236-L263) blocked transition; stop at L114 | Effective input rejected; slides counts requested-axis fallback, not continuous slide or obstacle class. |
| [m11path] | [StepGuardService](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Camera/StepGuardService.cs#L84-L104) first 120 shortenings | Existing local waypoint modified; not proof of native arrival. No per-rejection reason. |
| Fix14C: step / guard / head | [Fix14CProbe](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Camera/Fix14CProbe.cs#L49-L95) step/refusal separately throttled to 250 ms, head on change | Engine-facing keys, native animation ID, actual and desired positions before guard rollback; guard refusal and rollback intent; head mapping, not helmet ID. |
| Fix14D-D1 | [CameraDriveService](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Camera/CameraDriveService.cs#L610-L679) 1.5 s transition window, 50 ms followups, cap 2000 | Effective release, pre/post native drive, same-creature position delta. Not raw key release. |
| Fix14D-D2 | [CameraDriveService](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Camera/CameraDriveService.cs#L365-L428) input/send caps 256/1024 | Effective input edge, release ID, outgoing message major/minor/result/timing. Not proof of server action. |
| Fix14D-D3 | [CameraDriveService](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Camera/CameraDriveService.cs#L463-L564) cap 700 | Inside/outside native update displacement and drive state. |
| Fix14D-D4 | [CameraDriveService](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Camera/CameraDriveService.cs#L443-L456) cap 1800 | Inbound message observation and same-player displacement near release. Not decoded server correction authority. |
| Fix14D-D5 | [StepGuardService](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Camera/StepGuardService.cs#L141-L200) cap 1000 | Native walk and guard phases, actual/desired pre/post, native result. |
| Fix14D-C3C: anim= / rejectedPose= | [UniversalEyeClearance](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Camera/UniversalEyeClearance.cs#L190-L235) bounded 240 logs, change/need or rejection throttles | Rig/animation ID, projected clearance need, trusted shift, rejection and eye; not native clip phase, rendered pose or proof of attachment synchronization. |
| modelprobe: / [fpmodel] | [FirstPersonModelProbe](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Camera/FirstPersonModelProbe.cs#L59-L154) first-person/identity/fresh-eye gated; at most 24 reports, >=8 s apart | Part/attachment/head mapping and pivot distance; not mesh intersection or animation synchronization. |
| [fpdialog] / [dialog] | [CameraService](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Camera/CameraService.cs#L327-L342); [DialogService](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Dialog/DialogService.cs#L161-L227) and L635–639 | Hold/resume, dialogue entry/replies/send; not visual cursor success. |
| JumpSlope-J4: | [JumpPositionService](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Camera/JumpPhysics/JumpPositionService.cs#L59-L74), launch/bridge/abort/landing calls | Actual/expected/native walk/ground Z, velocity, step slope and corrections. Native ground proxy is not NPC support identity. |
| [dbanim] / Pose: | [DbAnim](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Alloy/Db/DbAnim.cs#L627-L663); [PoseService](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Anim/PoseService.cs#L253-L287) | Scene-wide animation runs/poses/events, dropped runs/unbound nodes; pose initialization. Not local attack-specific trace. |
| MouseLook.feedback: | [ActionFeedback](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Camera/ActionFeedback.cs#L87-L125) startup; existing D2 send observer | Hook state/action queue; not rendered reticle state or executed attack timing. |

## Checklist correlation

| IDs | Start with | Missing discriminator |
| --- | --- | --- |
| 01, 14 | Settings/MouseLook startup, [camera] | Actual persistence, cursor/text entry; user observation required. |
| 02, 10 | [camera], [fpdialog], [dialog] | Per-frame eye vs actor, successful cursor/reply. |
| 03–09, 17 | m11drive, m11path, Fix14C and D1–D5 | Raw vs effective request, rejection gate, contact direction/class, path provenance. |
| 11 | Fix14C step anim, DbAnim, Pose, ActionFeedback, modelprobe | Local attack event/clip phase, pose/weapon visibility and synchronized timing. |
| 12 | Fix14C head, fpmodel, D1 | Equipment identity and actual visible gait. |
| 13, 18 | JumpSlope-J4, Fix14C step/guard | NPC identity, native elevation vs eye and landing contact. |
| 15–16 | Startup/area lifecycle context, [camera], user observations | Exact save/load/transition event and control recovery. |

OBSERVED recount (cx.1.log / cx.log): D1 0/148, D2 0/69, D3 0/57, D4 0/450, D5 0/133; guard 0/8; fpmodel 72/96; m11path 0/0; JumpSlope-J4 0/0; fpdialog 0/0. Counts are marker-containing lines, not trials. Absence is not proof of no execution or successful behavior.

## First Phase 4 investigation — issue #5

Recover exact R3 source/artifact and compare the native attack request, clip selection/time, DbAnim/Pose and body/weapon render paths with M11. [CameraService L418–439](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Camera/CameraService.cs#L418-L439) bypasses animation and attack camera adjustments in Driving, while retaining model-only clearance. This proves changed eye behavior, not loss of native attack animation. If source comparison is insufficient, propose bounded read-only local-player attack/pose/visibility telemetry keyed by event/time; separate actual attack, body/weapon pose, eye and reticle. No speculative code changes or whole-build rollback; preserve ADR-001. Existing probes remain inactive in distribution. No new runtime or gameplay test in Phase 3.3.

## Phase 4.1D candidate (not installed)

Source [4e675d4](https://github.com/Hyperbog/cx/commit/4e675d4e8e45056db1e17f6e598f3cdd7de23263) adds `[efpcombat] anim=… tracked=… eyeDelta=… modelShift=… samples=…/120` in CameraService.TraceAnimatedEye, emitted on animation/tracking transitions only with logs enabled, cap 120. tracked means the camera path accepted a head sample and finite final transform; eyeDelta is distance from actor-root calibrated fallback; modelShift is requested local correction, not actual draw. Existing M11 log map remains valid for the installed original candidate. See [implementation](COMBAT_IMPLEMENTATION.md).
