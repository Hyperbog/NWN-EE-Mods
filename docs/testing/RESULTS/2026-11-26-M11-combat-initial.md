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
