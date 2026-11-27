# ADR-002 — Animation-aware first-person eye and combat framing

Status: Accepted product direction; [source implementation](../testing/COMBAT_IMPLEMENTATION.md) compiled and packaged; [initial gameplay observation](../testing/RESULTS/2026-11-26-M11-combat-initial.md) reports restored combat and immersive movement. Full verification pending; enemy-lunge clipping tracked separately as #9. Date: 2026-11-26.

## Context

[ADR-001](ADR-001-fixed-actor-root-eye.md) resolved unacceptable wall-driven camera retreat/jitter by fixing the eye to the actor root. Its prohibition on animation-driven eye displacement is now superseded by explicit product-owner clarification following the [Phase 4.1C test](../testing/COMBAT_ISOLATION.md). R3 is the verified historical behavioral reference; J4 is the later complete-source comparator, not exact R3 source.

OBSERVED: disabling adaptive model clearance did not restore acceptable combat presentation. The owner reports clipping, off-center view, camera behind character and no combat animation. Four screenshots show foreground self-model obstruction and intersecting equipment/geometry in the reported test. Still images cannot establish playback timing or exact camera transform. Actual test config/log and restoration not independently verified.

## Decision

Restore the J4-style animation-aware first-person eye: use the existing mapped animated head and torso pose, appearance-relative eye calibration and synchronized attack framing. Mouse yaw/pitch remain the aiming reference; historical bounded pose-driven camera response (including roll if required for the approved experience) may be evaluated, not arbitrary animation yaw/pitch. No race/weapon-specific offset tables or synthetic attack animation timing. Retain native body/attachment animation and the shared, render-only adaptive clearance pipeline; evaluate against the final animation-aware eye. Unsupported/invalid rigs fall back safely to calibrated actor-root eye.

Retain ADR-001's prohibition on collision-driven eye retreat/pushback and its separation of camera, native movement and local model presentation. Do not restore FirstPersonWorldGuard.Resolve in Driving, regress NPC dialogue hold or cursor ownership, change actor position/physics, overwrite native animation state or alter pathfinding as part of this isolated combat repair. Preserve jump translation without double-applying world displacement. Keep other gameplay issues open. Use existing verified historical implementation as the first comparator before refactoring; do not stack new speculative motion systems.

## Acceptance and scope

Phase 4.1D: targeted camera integration, validate finite/identity gates, reset on model/area changes, preserve M11 input/facing ownership and dialogue, validate fallback and avoid double-counting animation/jump translation. Compile/package separately and verify on multiple tested character/equipment variations, sword/melee attacks, idle/look, walking/running, jumps, walls/corners, dialogue, equipment changes, third-person restoration and reticle. No universal compatibility claim or confirmed native playback root cause. No runtime change in this decision commit.


## Phase 13C.1 — continuous live eye

READ: owner rejects overengineering and directs KISS continuous camera tracking. Phase 13C.1 simplified source 0ae674ac58cd0cf2579d8f99d832f52fa04968e7, tree 17c95a8484b1825aa8bd8296ede84508f410581b, direct child of unshipped continuity experiment 247a2c8535a76ce5c9bcabb11a926c13a6d33367. Complete recursive tree comparison against scoped accepted horizontal-FOV source 9840ead195486427478bbc38c4d08f5a3293dfa1 confirms only CameraService.cs differs. Remove the airborne-only prohibition from AnimatedEyeAllowed and its caller/signature; update the existing gate self-check. The live HeadBoneCamera mode-2 eye already uses absolute HeadWorld with horizontal view offset, and JumpPositionService writes native actor position; do not add jump displacement again. Existing finite/rig validation, fallback, dialogue/area gates, mouse aim, animation motion, final model clearance, horizontal FOV and physics remain. Delete experimental JumpEyeContinuity.cs, its state, timers, tests and call sites; restore JumpFramingTrace.cs byte-for-byte to accepted baseline. No new settings, smoothing, or movement systems. Invalid pose can still fall back; actual rig timing/landing motion and former relative mode-1 AirLock behavior are not changed. Test whether tracked remains true across takeoff/flight/landing, eye motion follows actor without artificial handoff, projection stable; compare stationary and moving jumps and mouse turns, check combat/body clipping, dialogue, mode switch and different rig/equipment. No claim of elimination until observed; no native build or self-check execution yet. Prior accepted horizontal-FOV release 1b69659 remains rollback baseline; build pin unchanged until 13C.2. #13 open, #12 queued.


## Phase 13C.2 package checkpoint

COMPILED/PACKAGED: Phase 13C.2 [Windows CI 46020973112](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/46020973112), attempt 1, build 140580228608 and publish 140582072700 passed. Checkout and logged manifest match distribution 6e9dafd9215c4a86b903ef8c1e54e39fd005fbdd, CX 0ae674ac58cd0cf2579d8f99d832f52fa04968e7/tree 17c95a8484b1825aa8bd8296ede84508f410581b. [Exact continuous animated eye prerelease](https://github.com/Hyperbog/NWN-EE-Mods/releases/tag/efp-M11-6e9dafd9215c4a86b903ef8c1e54e39fd005fbdd), ZIP 33,694,292 bytes SHA-256 73509022036694eff19fd97f9b0919daaf5417668cd100ce2683dd3ff9b2f421 agrees between CI manifest and GitHub asset metadata; publisher SHA256SUMS passed. Artifact 15207089961 SHA-256 cb2baea081a7fd845375498e8d3f69d30b8f38db62bed523e76a4fa5e574f462 agrees with upload/download logs and API. Installer fixtures passed. Native symbol check skipped (runner lacks nwmain.exe); no independent local binary rehash or in-game verification.

| DLL | Expected SHA-256 |
| --- | --- |
| version.dll | 24f9d257199b6673395c2f5c2b5a1e7653bee9fc42e70c071a31d1bfe73600b6 |
| cx_openal.dll | 3963b06e319180700be0bcc0d027336664bb3a4975876b4a5442f10746fab5b4 |
| phonon.dll | ca3dbc01dbc24492717011e80f6a51404ca143ae344ca660971d2c983f1e058d |
| shaderc_shared.dll | 8e13592eac48b94755e4aa4c41552b210b41ca906d0bfe35b0a6d47a97d0b7c6 |
| vma.dll | 504da73d9a8bb5acca40d8b563d8898c536329de07a1638f8cd9dbe1126d661e |

Controlled installation authorized for exact release. Only version.dll hash differs from accepted horizontal-FOV release 1b69659, which remains rollback baseline. Close NWN; preserve config and installer backup; capture installation output. Fresh session with general.logs=1: at 90 horizontal perform stationary jumps, moving jumps, and a jump with mouse turning; check natural takeoff/flight/landing, no self-clipping or artificial adjustment, combat and movement unchanged. Upload fresh cx.log (include rotated log if relevant); compare matched FOV and actor-relative eye transitions and tracked status. Restore prior logging preference after testing. Existing tracker may still fall back if a rig sample is invalid; no gameplay success claim until tested. Temporary trace retained for verification; #13 open, #12 queued.
