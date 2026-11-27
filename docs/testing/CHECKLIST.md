# Enhanced First Person gameplay acceptance checklist

Revision 3 — Phase 4.1E (READ); [revision 2](https://github.com/Hyperbog/NWN-EE-Mods/blob/335be4376fd8cc15774c0a9e0f3a29a23da02294/docs/testing/CHECKLIST.md) remains the historical test contract. IDs 01–16 retain their original scope; 17–18 isolate previously reported defects. [Original checklist](https://github.com/Hyperbog/NWN-EE-Mods/blob/6d297703d1b69beb0c78371cb8b1cd04f0e6e214/docs/testing/CHECKLIST.md) and [M11 results](RESULTS/2026-11-26-M11.md) remain historical evidence, not results under this revision.

## Before testing

- Use the explicitly selected exact-commit release only. Record date/time zone, release tag, distribution commit, CX commit/tree if available, game build, executable and all five installed DLL SHA-256 hashes against the release manifest. See [status](../../STATUS.md) and [installer](../INSTALLER.md).
- Preserve cx.cfg, saves and rollback backup. Close NWN before installation or restore. Use a disposable save in a repeatable location. Record module/area, race/model, equipment, controls and relevant settings.
- Current installed diagnostic candidate: original M11 distribution commit `7a26ce3a909f13f7c5dee2afbc022febc2616f4e`; version.dll `fe81fb1b6cf5b58d920cb477000da8f4b0147cc062961af634c12be42a2cdcec`. Later direct-source packages are not installed or gameplay-approved. M5-rc1 is an observed dialogue baseline only.
- Install only after the selected candidate is PACKAGED and explicitly authorized. [ADR-002](../decisions/ADR-002-animation-aware-eye.md) governs the new combat candidate; original M11 results retain revision 2 criteria.

## Numbered scenarios

| ID | Procedure | Observable PASS criterion |
| --- | --- | --- |
| 01 | Open settings; change one noncritical setting, restart, verify and restore. | Menu accessible; chosen value persists; mandatory Action Camera preserved. |
| 02 | Idle; rotate mouse horizontally and vertically. | Believable animated eye alignment; responsive mouse orientation; no unwanted jitter or drift. |
| 03 | Clear space: walk/run, strafe left/right, reverse, all available diagonals. | Correct camera-relative travel and locomotion animation; no unexpected turn. |
| 04 | Release each movement input alone and in combinations. | Travel and walk/run animation stop normally; no sustained gait or displacement. |
| 05 | Straight wall: hold forward 10 s, release, observe 5 s; turn away and move. | Inward motion stops; gait stops after release; clear escape works; no camera pushback or sustained jitter. |
| 06 | Oblique wall: approach from both sides where possible; hold briefly, rotate while blocked; release, turn completely away, press forward. | Stable eye and prompt escape without penetration, teleport or stuck gait. |
| 07 | Inside corner: contact, release all keys, turn fully away, press forward into clear space. | Prompt escape without camera pushback, teleport, penetration or persistent gait. |
| 08 | Diagonal into wall; release blocked axis, keep/request clear axis; release all; escape. | Explicit clear direction works; stable eye; no trapping/penetration. Automatic continuous wall sliding not required. |
| 09 | Living stationary NPC: approach, hold 10 s, release, turn away and move. | Intended collision prevents penetration; stable eye; stopping and escape work. |
| 10 | Open/close NPC dialogue twice; select reply and resume aiming. | First-person orientation held, cursor usable, normal aiming restored. |
| 11 | Matched melee attacks in first/third person, three cycles each where safe; open space first, near obstacle after acceptable open-space result; second rig/equipment and ranged if available. Record actual action, visible hand/weapon, eye/aim/recovery and reticle separately. | Executed attacks show synchronized body/weapon motion, believable animation-aware eye and readable target, mouse aim retained, no severe self-obstruction or excessive drift; feedback evaluated separately. A native miss is not animation failure. |
| 12 | Equip/unequip helmet idle and following wall contact. | No unexpected gait, displacement or trapping; acceptable body/head visibility. |
| 13 | Jump flat, uphill and downhill; three attempts each. | Intended jump, coherent trajectory and landing; regain control without trapping, double elevation or abrupt eye handoff. |
| 14 | Z cursor release/recapture; settings and chat entry. | Cursor works; mandatory Action Camera resumes; text entry does not drive movement. |
| 15 | Save to disposable slot and load it. | No crash; camera/controls resume; original saves unaffected. |
| 16 | Area transition and resume movement. | Camera follows new actor location; no lingering offset, drive or loss of controls. |
| 17 | Identify dead NPC versus remains and intended collision behavior; walk/run across intended nonblocking entity; attempt escape after contact. | Confirmed nonblocking entity permits traversal; no trapping; preserve living NPC/solid-object collision. Unknown entity class or intended solidity is NOT TESTED, with symptom recorded. |
| 18 | In safe disposable area, attempt jump onto stationary NPC; observe descent, landing, actor/eye height and escape. | Coherent eye/actor motion, no severe vertical clipping, unintended eye handoff or trapping; clear ground movement resumes. Standing on NPC is not required. |

## Execution and evidence

For scenario 11 record resolution, FOV, sensitivity, DPI, motion/clearance settings, equipment and renderer. Keep mouse still during a matched stationary swing; compare first attack after load vs after idle. Check forward travel while attacking at level and downward pitch, and first frame on landing/dialogue transitions. See [review disposition](ENGINEERING_REVIEW.md).

For 04–09 and 17–18 use three attempts per relevant variant where safe; for 13 use three per surface. Record successful/attempted counts per variant. Stop an unsafe or blocking reproduction; do not force further attempts. Record unattempted variants separately. For other scenarios record tested actions and any unavailable variant (e.g. ranged weapon).

Use PASS (all required applicable variants observed and met), FAIL (any observed criterion violated), or NOT TESTED (insufficient evidence/blocked/unavailable). A failed variant remains FAIL even if later attempts succeed. Record subresults for partial coverage; never silently count untested variants as passing. Explain nonapplicability; release approval requires explicit review of omissions.

For each failure record ID, time/time zone, input order, location/geometry or entity identity, expected/actual behavior, counts and whether recovery worked. Preserve relevant sanitized cx.log excerpts and screenshots when available. Do not infer collision shape, native actor position or root cause from camera motion alone. Minor visual wall-edge clipping is acceptable per [ADR-001](../decisions/ADR-001-fixed-actor-root-eye.md); trapping and independent eye retreat are not.

Stop for crashes, unusable controls or unsafe save behavior. Preserve evidence, exit NWN, and restore only if needed via the reviewed installer and exact recorded previous-runtime backup (including original WorkDir if customized). Do not bypass refusal checks. See [installer guide](../INSTALLER.md).

Link failures to issues: 05–07 [#2](https://github.com/Hyperbog/NWN-EE-Mods/issues/2), 08 [#3](https://github.com/Hyperbog/NWN-EE-Mods/issues/3), 17 [#4](https://github.com/Hyperbog/NWN-EE-Mods/issues/4), 11 [#5](https://github.com/Hyperbog/NWN-EE-Mods/issues/5), 18 [#6](https://github.com/Hyperbog/NWN-EE-Mods/issues/6). Preserve original observations; triage new failures without assuming regression or cause. Report results using the [standardized results template](RESULTS/TEMPLATE.md) and [subsystem log map](LOG_MAP.md). Compilation does not establish gameplay acceptance.
