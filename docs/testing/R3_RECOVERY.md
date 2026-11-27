# Issue #5 — R3 reference recovery (Phase 4.1A)

READ: partial recovery, exact tested R3 build not yet identified. OBSERVED: owner reported near-perfect synchronized sword/melee animations in R3; M11 loses combat animation but has other improvements. Do not interpret R3 as a fully accepted gameplay baseline.

## Provenance

The [archived source manifest](https://github.com/Hyperbog/NWN-EE-Mods/blob/5aa3b7fee93d34b180398957fa6c819f36df0f91/src/first-person/SOURCE_MANIFEST.json) records `NWN_EE_DotCrescent_CombatRed_R3/source/ActionFeedback.after.cs` as the origin of the J4 ActionFeedback module. Recorded original LF SHA-256: `497bea017915970ad4aca73ab38c05152121cc6c891ab15d2e586ff5f705d569`. The original hash is historical manifest evidence, not a newly verified unheadered artifact. The archived published file and migrated J4 copy have matching Git blob `b26fb4db925cef5cc3dc95a7f4c1d1e3c45f4bb5` and equal normalized contents.

[Historical J4 notes](../history/FIRST_PERSON_J4.md) describe R3 as combat-red reticle/side crescents and C3C as adaptive body/eye clearance. [Source publication notes](../history/FIRST_PERSON_SOURCE.md) identify the cumulative C3C/D4/D5/R3/J4 overlay. R3 was an incremental revision, not established here as an independent full source snapshot. No standalone R3 release or commit was located in the returned GitHub search/release results or exact-name project/library file searches. Local package, source backups and build/installation reports have not been inspected.

## Available comparison checkpoint

- J4: [214e9db](https://github.com/Hyperbog/cx/commit/214e9dbfe3dbbfbb675661f7ded7ed10b97a6f03), tree `d008ef185b010bce9c402794335f0d56fb40da6c`.
- M11: [b7895ed](https://github.com/Hyperbog/cx/commit/b7895eda58cb1124e98a27109a1acc79e8544c6b), tree `13e2a83859a4e711e90931df5c9a21ec5e2eeae1`.
- Full recursive tree comparison (1877 non-tree entries each, neither truncated) and GitHub comparison agree: 11 changed files, 6 descendant commits. No additions/removals in the comparison.

Changed under managed/Services/Camera/: ActionFeedback.cs, CameraDriveService.cs, CameraKnobs.cs, CameraService.cs, FirstPersonHeadFilter.cs, FirstPersonVisibility.cs, FirstPersonWorldGuard.cs, HeadBoneCamera.cs, HeadTrackService.cs, MouseLookService.cs, StepGuardService.cs.

Identical Git entries across J4 and M11: DbAnim.cs, PoseService.cs, AnimationCameraMotion.cs, AttackCameraFollow.cs, UniversalEyeClearance.cs, AlloyRenderer.Batches.cs. Unchanged module code does not prove unchanged behavior; callers, settings, render inputs and timing can change. The J4 checkpoint is a later cumulative source reference, not a verified R3 runtime or reproduction. It narrows subsequent comparison; no causal inference yet.

## Recovery gate

Locate original R3 package/ZIP or extracted folder and related source/installer backup reports in local C:\Projects and Downloads. Preserve originals and do not execute any legacy installer, revert scripts, build, clean or overwrite current source. User may supply package, README, manifest, source fixtures, build/installation report or version.dll hash (not game binaries). A patch-only package requires matching predecessor source and source verification. If exact R3 is irrecoverable, explicitly approve J4 as a comparison proxy with its limitations; never label it R3. No changes to runtime or installed M11. Issue #5 remains open; Phase 4.1A exact identity pending local evidence.
