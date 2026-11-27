# Issue #5 — R3 reference recovery (Phase 4.1A)

READ: original incremental R3 package recovered and independently verified; historical build/installation hash records recovered. Exact complete R3 source tree and R3 binary bytes remain unverified. OBSERVED: owner reported near-perfect synchronized sword/melee animations in R3; M11 loses combat animation but has other improvements. Do not interpret R3 as a fully accepted gameplay baseline.

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

Historical build log records native compilation and five artifacts, symbol check skipped. Build DLL and runtime new hashes agree; changed_dlls only version.dll. Recorded R3 version.dll SHA-256 `4123043ec927ef961bff694d269612f3045ad984c981df6102c7d3c55a02829a`. All five archived backup DLL hashes match old R2 records (R2 version.dll `59099cbe3e93b7bae97827a7bf30d7d18c957a61a6b0cbd9adb3b8932fe15247`). R3 DLL bytes are not in archive. Runtime manifest is historical installation evidence, not independent verification of a completed installation or current binary. No new build or gameplay; no DLLs, raw archives or private paths committed.

## Remaining gate

Incremental R3 source and historical recorded runtime identity recovered. Complete R3 tree not established by single-file fixture. The next J1 package may contain R3 predecessor source and runtime backup; inspect its source manifest and before fixture first. Recover missing predecessor fixtures if necessary; alternatively explicitly approve the documented later J4 proxy for source comparison. Do not execute historical scripts, replace installed M11 or introduce speculative changes. Issue #5 remains open.
