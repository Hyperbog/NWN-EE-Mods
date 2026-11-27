# M11 animation-aware combat candidate — 2026-11-26, initial observation

OBSERVED: product-owner report following Phase 4.1E installation instructions. Expected release distribution b54673b2b192cad378e1b5d4d8e0edb0227ead19, CX 4e675d4e8e45056db1e17f6e598f3cdd7de23263, tree c0dd20c6c874162182103bc43f49a8190a4101bd. Exact installed DLL hashes, installer output, configuration, fresh log, repetition counts, tested rigs/equipment and module not supplied. Build identity is inferred from session context, not independently INSTALLED-verified.

| Observation | Reported result |
| --- | --- |
| Combat animation restoration (#5, scenario 11 subresult) | PASS as reported |
| Locomotion camera bob and character connection | Positive, reported |
| First-person immersion | Positive, reported |
| Enemy clipping during lunge (#9, scenario 11 framing subresult) | FAIL as reported |
| Full checklist revision 3 | NOT TESTED / incomplete evidence |

Product owner: "Combat animation restored. Movement looks great since it bobs with the character too. The camera feels like it's part of the character now. It's immersive feeling." The requested feel references Titanfall 2 and Cyberpunk 2077. Enemy clipping sometimes occurs during lunge attacks. Preserve successful animated eye and body synchronization. No claim that every character/equipment variant, native playback, reticle, jump, dialogue, movement stop or wall escape has passed. No new runtime edits.

## Next discriminator

[Issue #9](https://github.com/Hyperbog/NWN-EE-Mods/issues/9) separately tracks enemy lunge clipping. READ: original world guard skips creature hits and is bypassed in Driving; C3C clearance only shifts the local body/attachments. Determine if native actor/model overlap, animated-eye intrusion or near-plane intersection is involved. Matched first/third-person attack in open space, same target and equipment, timestamp, cx.log, note body/feet overlap and recovery. A video is optional. If not conclusive, design bounded read-only telemetry before repair. No generic world camera retreat or new separate mod until justified. #5 stays open pending full acceptance; no global release approval.

## Lunge follow-up — 2026-11-26

OBSERVED: owner reports character model does not come near enemy and suspects camera too far forward. Uploaded cx.log (7105 lines) identifies combat candidate at L368, game 8193.37-17 at L55, CameraService.SelfCheck passed at L365. Banner is not binary hash verification. L4865, 5599, 5633, 5641, 5676, 5721 show recognized melee-state transitions with tracked=1, eyeDelta=0.229–0.318 m and requested modelShift=0.070–0.080 m. Eight C3C melee samples, L4864–5720, requested shift 0.070–0.144 m, zero wall correction, trusted=1, rejected=0. C3C reached 240-sample cap; efpcombat 75 transitions. No signed forward projection, enemy surface distance, actor separation or exact clipping-frame marker. No causal proof; body overlap hypothesis weakened by user observation. Existing SSAO self-check failure L150 remains separate.

READ: CameraService L338–340 layers AnimationCameraMotion, AttackCameraFollow and MaintainHeadClearance after head sample. AttackCameraFollow L54–59 defaults enabled, 60% strength, 0.28 m maximum forward tracking (component cap, not total eye offset). Cheapest next discriminator: compare existing enabled condition to temporarily setting attackfollow.enabled=0 in cx.cfg with game closed, preserving original file and fpclear/head/animcam settings. Same target/weapon, three attempts where safe, report clipping, animation feel and recovery separately, restore original configuration afterward. If inconclusive, instrument signed per-layer offsets and target clearance read-only. No DLL/source change; preserve animated bob and natural attack framing.

## Additional attack-follow isolation — preliminary result

OBSERVED: product owner reports `attackfollow.enabled=0`, clipping eliminated, combat immersion preserved: "I performed a small test, but it looks good at the moment." Limited coverage; no new log, config bytes, counts, target/rig/equipment or independent installed hashes provided. The result supports the additive attack-follow layer as a contributor in the tested condition, not a proven geometric mechanism or universal fix. No native collision or renderer change warranted for this symptom yet. Keep the existing candidate and original config backup, temporarily retain only this override for extended testing (replaces earlier instruction to restore immediately). Test several repeat lunges against the same target, then a different available character/equipment/target combination, confirm head bob, attack framing, recovery and no new clipping; record unavailable variants and stop on severe obstruction. Upload fresh cx.log after the session. If reproduced success, consider a separate minimal default-off change respecting explicit user overrides, with migration/compatibility evaluated before build. No new runtime edit or package. Issue #9 remains open; #5/full checklist still pending.

## Issue #9 extended verification — 2026-11-26 23:16 local

OBSERVED: owner submitted extended checklist under the temporary `attackfollow.enabled=0` override; 7 PASS, 0 FAIL, 1 PENDING (not yet tested). No inferred per-variant repetition counts, exact model/weapon identities, new log, configuration bytes or installed hash evidence.

| Test | Owner-reported result |
| --- | --- |
| Repeated lunge attacks | PASS |
| Different melee weapons | PASS |
| Unarmed combat | PASS |
| Different character models | PASS |
| Different armor and helmets | PASS |
| Combat near walls | PENDING |
| Walking and running immersion | PASS |
| Attack-to-movement transitions | PASS |

These results support retaining the historical animated head/torso camera while making the additive AttackCameraFollow layer opt-in. They do not establish a universal collision fix or the exact geometric cause. Keep current candidate and override unchanged until wall-adjacent combat is observed; avoid forcing a reproduction if blocked. Distinguish enemy clipping, wall clipping, camera retreat/jitter, and movement trapping. Once remaining test is recorded, consider a separate minimal default-off source change respecting explicit saved overrides, followed by compile/package and verification with default configuration. No runtime changes now. Issue #9 remains open; #5 and full revision 3 acceptance remain pending. Existing wall/diagonal and vertical-contact defects stay separate.

## Final extended wall-adjacent observation and opt-in implementation

OBSERVED: owner reports attacking near walls is fine; expected animation-dependent clipping remains, and bodies on the ground still obstruct movement. Screenshot shows substantial foreground geometry obstruction (target marked dead), but cannot establish geometry identity, exact camera position, collision or attack phase. Wall-combat item accepted as reported; extended eight-item isolation checklist complete, with no reported enemy-lunge failure. This is not a general wall-clipping pass or full revision 3 acceptance. #4 remains open independently.

READ: inspected mounted cx.log (1,706,578 bytes, 4,127 lines, 23:13:07–23:16:28 local, 2026-11-26). Two uploads share the same name/path; only the mounted file was inspected. Log ends before 23:18 screenshot, lacks startup/config confirmation and has no C3C samples. 18 efpcombat samples, 103–120/120, cap reached at L1641, none in melee IDs 201–205. Four blocked-input events, ten m11drive lines overall, no m11path or explicit corpse/remains classification. L3688 and L3773 show held=0, drive=1, zero effective keys, native movement continuing; no exact incident correlation. Do not infer cause or physical key state. Fresh log/installed hash remain pending.

READ: source [3e7d7ec](https://github.com/Hyperbog/cx/commit/3e7d7ec9da65f4507df642d0a66f5f0f35a6b3e8), tree 510c5db1eebe76abbfe1a36fc5f62d1f7faecd90, changes only AttackCameraFollow.cs toggle default true to false and label/help. Verified diff against prior combat source. No camera, native movement or collision algorithm changes. Knob.cs binds valid stored values, accepts 0/1, and KnobFile writes only off-default declared settings: explicit true remains opt-in; absent or false now disables the extra layer. Previous default-on build can resume extra attack-follow if a newer config save omits its new default; preserve backup or explicitly reapply attackfollow.enabled=0 if returning to old combat candidate. Distribution pin unchanged pending compile/package checkpoint. No new installation or compile yet. #9 remains open pending verification of packaged default-off candidate; #5 still awaits full verification. #4 next investigation recommended, distinguish corpse vs remains, native collision vs residual drive/step refusal without editing the combat baseline.


## Superseding product direction — remove rejected feature

Product owner explicitly rejects optional/opt-in features for discarded EFP behavior. READ: source 61787ce17747b0027e4e574d06000bbb2e58caaa (tree 32a9a8ce432ca3bc9824074e75dacdb88fd2945c) deletes AttackCameraFollow.cs (208 lines) and removes its diagnostic registration, knob group registration, reset and two Apply calls from CameraService/CameraKnobs. Remote three-file diff verified. No other runtime algorithms changed. The default-off commit was not selected by the distribution pin or released. Existing attackfollow.* config keys become inert unknown keys (generic CX preservation policy unchanged); do not overwrite cx.cfg or remove unrelated settings. Prior candidate still needs attackfollow.enabled=0. New candidate compilation and default-independent gameplay verification pending; issue #9 remains open. Repository code search returned no hits even before deletion, and a broader scan exceeded tool-call limit; compilation remains the definitive reference check.
