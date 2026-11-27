# EFP gameplay results — YYYY-MM-DD, VERSION, session ID

Copy this template to `YYYY-MM-DD-VERSION[-session].md`; never overwrite earlier results. Use the [numbered checklist](../CHECKLIST.md) and record its revision. Unknown values must be marked UNKNOWN, not guessed.

## Build and environment

| Field | Value |
| --- | --- |
| Date, time range and time zone | UNKNOWN |
| Checklist revision | UNKNOWN |
| Exact release tag and URL | UNKNOWN |
| Distribution commit | UNKNOWN |
| CX source repository / commit / tree (if supplied by release) | UNKNOWN |
| CI run / build conclusion | UNKNOWN |
| Release ZIP SHA-256 / verification | UNKNOWN |
| Game build / nwmain.exe SHA-256 | UNKNOWN |
| Module / area / reproducible location | UNKNOWN |
| Race / model / equipment / weapon | UNKNOWN |
| Relevant EFP settings / controls / renderer | UNKNOWN |
| Previous-runtime backup retained? | UNKNOWN |
| Evidence level (READ, COMPILED, PACKAGED, INSTALLED, OBSERVED) | UNKNOWN |

### Installed identity

Compare each installed file against the selected exact release manifest; record actual and expected values. Do not infer binary identity from a startup banner. Do not publish personal filesystem paths.

| DLL | Expected SHA-256 | Actual SHA-256 | Match? |
| --- | --- | --- | --- |
| version.dll | UNKNOWN | UNKNOWN | UNKNOWN |
| cx_openal.dll | UNKNOWN | UNKNOWN | UNKNOWN |
| phonon.dll | UNKNOWN | UNKNOWN | UNKNOWN |
| shaderc_shared.dll | UNKNOWN | UNKNOWN | UNKNOWN |
| vma.dll | UNKNOWN | UNKNOWN | UNKNOWN |

## Scenario results

PASS / FAIL / NOT TESTED per checklist. Preserve submitted results exactly; separate interpretation from observations. Record counts per applicable variant, and why unavailable variants were not tested. Do not invent times, counts or subresults.

| ID | Scenario | Result | Successful / attempted; variants | Evidence/time or notes |
| --- | --- | --- | --- | --- |
| 01 | Settings and persistence | NOT TESTED | — | — |
| 02 | Stationary camera / mouse | NOT TESTED | — | — |
| 03 | Clear-space locomotion | NOT TESTED | — | — |
| 04 | Movement and gait stop | NOT TESTED | — | — |
| 05 | Straight wall | NOT TESTED | — | — |
| 06 | Angled wall | NOT TESTED | — | — |
| 07 | Corner escape | NOT TESTED | — | — |
| 08 | Diagonal obstacle | NOT TESTED | — | — |
| 09 | Living NPC collision | NOT TESTED | — | — |
| 10 | NPC dialogue | NOT TESTED | — | — |
| 11 | Combat | NOT TESTED | — | — |
| 12 | Helmet equip/unequip | NOT TESTED | — | — |
| 13 | Flat/uphill/downhill jump | NOT TESTED | — | — |
| 14 | Z cursor / chat | NOT TESTED | — | — |
| 15 | Save/load | NOT TESTED | — | — |
| 16 | Area transitions | NOT TESTED | — | — |
| 17 | Dead NPC/remains | NOT TESTED | — | — |
| 18 | NPC landing/vertical clipping | NOT TESTED | — | — |

### Combat subresults (11)

Record actual action/target/outcome, native hand/weapon wind-up/strike/recovery, animation-aware eye/aim/recovery and reticle separately. Match first and third person for three cycles where safe; note first attack after load and after idle. Record viewport, FOV, sensitivity, DPI, renderer, fphead.mode, fphead.eyelock, fpclear.enabled, animcam.enabled, attackfollow.enabled and roll toggles. R3 verified historical runtime is the sword/melee behavioral reference; J4 is the full-source proxy. Ranged and other unavailable variants stay separate. [ADR-002](../../decisions/ADR-002-animation-aware-eye.md) supersedes fixed-eye animation restriction; no collision-driven eye retreat. A missing camera response is not proof of missing native clip playback.

## Failure record (repeat for each failed variant)

- Scenario / issue / priority:
- Timestamp and time zone / log filename and line range:
- Exact steps, input order and obstacle/entity:
- Expected vs actual:
- Successful/attempted count; recovery or stop condition:
- Sanitized log excerpt (verbatim, mark redactions):
- Screenshot/video reference (optional; remove private information):
- READ source findings, OBSERVED behavior, hypotheses and remaining unknowns (separate):

## Summary and acceptance

- Reported PASS / FAIL / NOT TESTED:
- Evidence gaps and unavailable variants:
- Issue links and disposition (new / existing / regression evidence):
- Acceptance decision and rationale; no release approval by compilation alone:
- Rollback required/performed? Record exact backup identity privately and observed outcome; preserve saves and configuration.

Use the [subsystem log map](../LOG_MAP.md) for emitter names, gates, cadence and interpretation. Keep raw logs and personal paths out of Git. Use the reviewed installer and backup from the selected release if restoration is needed. A recorded failure is not a confirmed root cause.
