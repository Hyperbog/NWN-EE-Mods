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
