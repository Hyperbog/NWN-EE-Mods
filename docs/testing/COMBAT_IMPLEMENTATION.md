# Issue #5 — Animation-aware combat integration (Phase 4.1D)

READ; source implementation only. [ADR-002](../decisions/ADR-002-animation-aware-eye.md) supersedes the prohibition on animation-driven eye motion but preserves no Driving wall retreat. [Source commit](https://github.com/Hyperbog/cx/commit/4e675d4e8e45056db1e17f6e598f3cdd7de23263), tree `c0dd20c6c874162182103bc43f49a8190a4101bd`, direct child of M11 `b7895eda58cb1124e98a27109a1acc79e8544c6b`. Remote main and five-file diff verified. Distribution BUILD_PLAN remains on original M11 pending Phase 4.1E. Installed runtime untouched.

## Implementation
- CameraService restores the historical calibrated model dock, HeadBoneCamera.Apply, AnimationCameraMotion.Apply, AttackCameraFollow.Apply, and MaintainHeadClearance in grounded Driving. Direct head mode replaces the initial eye with the sampled head position, rather than adding absolute world position twice. Final C3C clearance receives zero world correction and publishes local body/attachment shift as before.
- Preserve M11 stationary facing and native drive ownership; call TurnCharacter once (except dialogue); Apply takes optional facing argument and returns whether a head sample was applied. On invalid/disabled head tracking, use the actor-root calibrated fallback instead of applying residual attack offsets. Preserve original non-Driving call ordering.
- Preserve actor-root eye and held mouse yaw/pitch in NPC dialogue; preserve native actor-root jump eye while airborne. Reset presentation on player/area change, loss of tracked pose, real camera gate/mode exit/free camera and suspension; existing helpers retain model-root, time and teleport checks. Interleaved non-world camera solves do not reset the tracked context. Reset C3C pose validity history without changing clearance algorithm or log budgets.
- Do not restore legacy locomotion tether or world retreat in Driving; this is an isolated combat presentation candidate, not full J4 rollback. Historical optional head/attack settings and bounded roll remain respected. Existing helpers can layer effects on head motion; excess motion and transitions require gameplay evaluation. No new animation IDs, timing, race/weapon tables, creature position writes, pathfinding edits or independent equipment transforms.
- Add bounded [efpcombat] transition samples (120/session): animation ID, tracked flag, distance from actor-root fallback, requested model shift. This is not clip-phase or actual render application evidence. Existing C3C and pose diagnostics remain available.
- Add pure gate/finite-transform assertions in CameraService.SelfCheck (not executed yet). Reviewed source diff, checked scope and signatures; no local Windows compile or game test.

## Verification gate
Before compiling, verify exact source commit/tree and update distribution pin for the new candidate in Phase 4.1E. Validate five DLLs and manifest/checksums; retain original M11 release and backups. Restore diagnostic configuration fpclear.enabled to original value before install/test. Test matched sword/melee, multiple available characters/equipment, attack visibility and timing, eye alignment, idle mouse yaw/pitch, walking, wall/corner contact, jump flat/sloped, dialogue and Z, save/load, area transition, equipment swap and third-person. Log [efpcombat], C3C and relevant movement markers. If native animation is still missing, diagnose local playback/pose phase rather than stacking new camera effects. No claim that historical playback is restored until OBSERVED; full R3 source tree remains unverified. Issue #5 stays open.


## Phase 4.1E closeout

COMPILED/PACKAGED (2026-11-26 local, 2026-11-27 UTC): [run 45931914373](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45931914373) attempt 1 succeeded; build job 140286236880, publish job 140287956849. Installer fixture, pinned checkout, native build, five-DLL package, upload/download and publish passed. Source 4e675d4e8e45056db1e17f6e598f3cdd7de23263/tree c0dd20c6c874162182103bc43f49a8190a4101bd match plan and logged manifest; distribution b54673b2b192cad378e1b5d4d8e0edb0227ead19. [Exact prerelease](https://github.com/Hyperbog/NWN-EE-Mods/releases/tag/efp-M11-b54673b2b192cad378e1b5d4d8e0edb0227ead19) remains gameplay-unapproved. ZIP SHA-256 9ce531a449488a4fcd8310d47921f51f0100a690d8206d730bb7ab462c810071 matches logged manifest, publisher SHA256SUMS check and GitHub asset digest. Separate artifact 15168964116 SHA-256 a6910a31701ffca614a3a39525a7215a228e7a62cdee08300e8721db1a64f826 matches upload/download/API. No independent local download or DLL byte rehash performed. Native symbol check skipped because nwmain.exe absent; runtime self-checks and gameplay not executed in CI.

| DLL | Expected SHA-256 (CI manifest) |
| --- | --- |
| version.dll | 542dd2a7be85c936e784eaa4c1b73b5c5b3a60bc8952275e9ac0511bc122770a |
| cx_openal.dll | 3963b06e319180700be0bcc0d027336664bb3a4975876b4a5442f10746fab5b4 |
| phonon.dll | ca3dbc01dbc24492717011e80f6a51404ca143ae344ca660971d2c983f1e058d |
| shaderc_shared.dll | 8e13592eac48b94755e4aa4c41552b210b41ca906d0bfe35b0a6d47a97d0b7c6 |
| vma.dll | 504da73d9a8bb5acca40d8b563d8898c536329de07a1638f8cd9dbe1126d661e |

Phase 4.1E complete. Authorize only controlled test installation using exact distribution commit above and reviewed installer; restore original clearance configuration first. Record SWITCHED_AND_VERIFIED, all installed hashes and printed rollback path privately. Restore via same script -RestoreBackup and original WorkDir if necessary. Original M11 remains installed until user reports otherwise. Phase 4.1F begins with matched first/third-person combat per checklist revision 3; issue #5 and all other P1 remain open.


## Phase 4.1F initial observation

See [initial gameplay report](RESULTS/2026-11-26-M11-combat-initial.md): restored combat animation and positive movement immersion, enemy clipping during lunges (#9), full acceptance pending. Preserve candidate source and behavior.
