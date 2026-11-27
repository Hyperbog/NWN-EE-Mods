# Issue #5 — R3 reference recovery (Phase 4.1A)

READ: original incremental R3 package recovered and independently verified; historical build/installation hash records recovered. The original R3 runtime bytes are now independently verified from the J1 predecessor backup. Complete R3 source-tree identity remains unverified. OBSERVED: owner reported near-perfect synchronized sword/melee animations in R3; M11 loses combat animation but has other improvements. Do not interpret R3 as a fully accepted gameplay baseline.

## Provenance

The [archived source manifest](https://github.com/Hyperbog/NWN-EE-Mods/blob/5aa3b7fee93d34b180398957fa6c819f36df0f91/src/first-person/SOURCE_MANIFEST.json) records `NWN_EE_DotCrescent_CombatRed_R3/source/ActionFeedback.after.cs` as the origin of the J4 ActionFeedback module. Recorded original LF SHA-256: `497bea017915970ad4aca73ab38c05152121cc6c891ab15d2e586ff5f705d569`. The recovered unheadered fixture independently matches this LF hash. The archived published file and migrated J4 copy have matching Git blob `b26fb4db925cef5cc3dc95a7f4c1d1e3c45f4bb5` and equal normalized contents.

[Historical J4 notes](../history/FIRST_PERSON_J4.md) describe R3 as combat-red reticle/side crescents and C3C as adaptive body/eye clearance. [Source publication notes](../history/FIRST_PERSON_SOURCE.md) identify the cumulative C3C/D4/D5/R3/J4 overlay. R3 was an incremental revision, not established here as an independent full source snapshot. No standalone R3 release or commit was located in the returned GitHub search/release results or exact-name project/library file searches. The product owner subsequently located and uploaded the original extracted package; see verification below.

## Available comparison checkpoint

- J4: [214e9db](https://github.com/Hyperbog/cx/commit/214e9dbfe3dbbfbb675661f7ded7ed10b97a6f03), tree `d008ef185b010bce9c402794335f0d56fb40da6c`.
- M11: [b7895ed](https://github.com/Hyperbog/cx/commit/b7895eda58cb1124e98a27109a1acc79e8544c6b), tree `13e2a83859a4e711e90931df5c9a21ec5e2eeae1`.
- Full recursive tree comparison (1877 non-tree entries each, neither truncated) and GitHub comparison agree: 11 changed files, 6 descendant commits. No additions/removals in the comparison.

Changed under managed/Services/Camera/: ActionFeedback.cs, CameraDriveService.cs, CameraKnobs.cs, CameraService.cs, FirstPersonHeadFilter.cs, FirstPersonVisibility.cs, FirstPersonWorldGuard.cs, HeadBoneCamera.cs, HeadTrackService.cs, MouseLookService.cs, StepGuardService.cs.

Identical Git entries across J4 and M11: DbAnim.cs, PoseService.cs, AnimationCameraMotion.cs, AttackCameraFollow.cs, UniversalEyeClearance.cs, AlloyRenderer.Batches.cs. Unchanged module code does not prove unchanged behavior; callers, settings, render inputs and timing can change. The J4 checkpoint is a later cumulative source reference, not a verified R3 runtime or reproduction. It narrows subsequent comparison; no causal inference yet.

## Recovered package verification (2026-11-26)

READ: uploaded NWN_EE_DotCrescent_CombatRed_R3_RECOVERY.zip, SHA-256 `d215d03496d006364a8837090562453d85ed34beb3373baaad85a5cdee74794d`. ZIP CRC passes; exact immutable inventory, 15/15 raw SHA-256 checksums pass. Both source fixtures match expected.json and generated source manifest; saved predecessor source bytes equal before fixture. After fixture raw SHA-256 `b0241fd31f48d03a4889f468247786b53ec2578f4bb77e3a3c70e79d1763f913`, normalized LF hash matches archived provenance above. Base `2470f0d27be0a29c152456aa60222f1f4fc25c34`. One-line delta only: ActionFeedback.HitCrescents white RGB to AttackR/AttackG/AttackB. R3 inherited existing combat animation from R2 over D5 R1/C3C; no animation change in R3 itself.

Historical build log records native compilation and five artifacts, symbol check skipped. Build DLL and runtime new hashes agree; changed_dlls only version.dll. Recorded R3 version.dll SHA-256 `4123043ec927ef961bff694d269612f3045ad984c981df6102c7d3c55a02829a`. All five archived backup DLL hashes match old R2 records (R2 version.dll `59099cbe3e93b7bae97827a7bf30d7d18c957a61a6b0cbd9adb3b8932fe15247`). R3 DLL bytes are not in the R3 archive itself; they are recovered from the subsequent J1 archive below. Runtime manifest is historical installation evidence, not independent verification of a completed installation or current binary. No new build or gameplay; no DLLs, raw archives or private paths committed.

## J1 predecessor recovery (2026-11-26)

READ: uploaded NWN_EE_JumpSlope_Trace_J1.zip, SHA-256 `e01233e5731d3a1a22c7cd57d61dcf992937b6a7a8c8ba8a9edf44419f6259d3`. ZIP CRC passes; all 18 immutable package hashes and all four raw before/after source fixture hashes match. Both saved predecessor sources match state manifest raw hashes and normalized before fixtures. J1 pins three R3 package files; all three independently match the recovered R3 archive. J1 r3_runtime_sha256 equals SHA-256 of the original R3 runtime manifest (`14a1ddceb0051ebcc25654be22d4d040b3deec761b873abed66ec0b9439db18d`); R3 new map equals J1 old map exactly.

| Recovered R3 DLL (J1 state/runtime/backup) | SHA-256 |
| --- | --- |
| version.dll | 4123043ec927ef961bff694d269612f3045ad984c981df6102c7d3c55a02829a |
| cx_openal.dll | 3963b06e319180700be0bcc0d027336664bb3a4975876b4a5442f10746fab5b4 |
| phonon.dll | ca3dbc01dbc24492717011e80f6a51404ca143ae344ca660971d2c983f1e058d |
| shaderc_shared.dll | 8e13592eac48b94755e4aa4c41552b210b41ca906d0bfe35b0a6d47a97d0b7c6 |
| vma.dll | 504da73d9a8bb5acca40d8b563d8898c536329de07a1638f8cd9dbe1126d661e |

All five actual backup hashes match both manifests. Additional cx_openal.dll.preJ3_mismatch.bak is not in the five-DLL identity map, differs from the verified cx_openal.dll and was excluded from the accepted reference. J1 build log records native compilation; J1 build map equals runtime new map. No historical scripts executed, files installed, binaries published or local configuration touched.

J1 changes only JumpPositionService.cs and JumpWalkBridgeService.cs (diagnostic logging); its before fixtures preserve the pre-J1 jump source. The R3 package and J1 evidence substantiate the inherited C3C/D5/R2/R3 lineage, not a full independent snapshot of every R3 source file. J4 remains the closest complete archived source comparator, not an exact R3 source tree.

## Recovery closeout and next comparison

OBSERVED: product owner reports synchronized combat worked across tested character and equipment variations and authorizes a cleaner implementation preserving functionality. Accept the verified R3 binary as a historical behavioral reference. Start with the complete J4 source and verified R3/J1 provenance for a focused read-only comparison to M11; explicitly label the source proxy. Additional local package recovery only if comparison reveals a missing discriminator. Do not downgrade the installed candidate or assume universal rig coverage. Maintain ADR-001 fixed actor-root eye, mouse orientation, existing native combat/movement/jumping/reticle and render-only model handling; no hardcoded per-race or per-weapon offsets. No perfect-implementation or gameplay-pass claim before observed tests. Issue #5 stays open. Phase 4.1A recovery sufficient for comparison; exact R3 tree remains an evidence limitation.

Phase 4.1B: [combat comparison](COMBAT_COMPARISON.md) verifies uploaded J4 source and predecessor records; exact R3 full tree remains unverified.
