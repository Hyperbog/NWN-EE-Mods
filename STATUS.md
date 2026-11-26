# EFP status — Phase 0 evidence checkpoint

Phase 0 evidence exit criteria met on 2026-11-26. This status is on the documentation branch in draft PR #1; main reconciliation and CI/merge remain pending in Phase 1. Gameplay release acceptance is NOT met.

Candidate: M11, source commit `7a26ce3a909f13f7c5dee2afbc022febc2616f4e`. Historical baseline: M5-rc1, OBSERVED for NPC dialogue only. M11 is the installed diagnostic candidate, not a globally accepted baseline.

| Evidence | Status |
|---|---|
| READ | M11 fixed actor-root eye and native movement preflight; previous M6–M10 experiments excluded |
| COMPILED | [Actions run 45849781085](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45849781085), build and publish succeeded |
| PACKAGED | [Release](https://github.com/Hyperbog/NWN-EE-Mods/releases/tag/efp-M11-7a26ce3a909f13f7c5dee2afbc022febc2616f4e), five-DLL manifest printed in CI build job 140012813572; ZIP SHA-256 `2921b4880c73f9d34861b8f6c1f304dbe3b535d518832b187012b8d7906f5f47` |
| INSTALLED | User's Get-FileHash output matched version.dll SHA-256 `fe81fb1b6cf5b58d920cb477000da8f4b0147cc062961af634c12be42a2cdcec` |
| OBSERVED | [2026-11-26 M11 results](docs/testing/RESULTS/2026-11-26-M11.md): 14 reported pass, two reported fail; combat and vertical-contact concerns require further review. Release acceptance withheld. |

Known defects: angled-wall/corner trapping, diagonal movement along obstacles, dead NPC/remains collision, reported loss of combat animation, vertical-contact/height clipping and trapping after landing on NPC. The uploaded M11 log has been reviewed; exact asset identities, incident timestamps and repetition counts remain unknown.

Standing decision: camera tracks character position and mouse orientation; no collision-driven eye displacement. Minor wall-edge clipping accepted. Do not treat every visual defect as a camera problem. Do not resume M6–M10 camera retreat experiments.

## Open defects

- [#2 angled-wall/corner trapping](https://github.com/Hyperbog/NWN-EE-Mods/issues/2)
- [#3 diagonal movement](https://github.com/Hyperbog/NWN-EE-Mods/issues/3)
- [#4 dead NPC/remains collision](https://github.com/Hyperbog/NWN-EE-Mods/issues/4)
- [#5 combat animation](https://github.com/Hyperbog/NWN-EE-Mods/issues/5)
- [#6 vertical clipping/NPC landing](https://github.com/Hyperbog/NWN-EE-Mods/issues/6)

All proposed P1; priorities not yet applied as labels. No confirmed root cause. The user confirms complete turn-away and forward movement does not escape angled contact. See results for log evidence.

## Next

Phase 1: repository hygiene only, beginning with PROJECT_BRIEF.md and reconciliation of documentation. Do not start runtime repairs until required intervening phases are complete. Keep M11 as installed diagnostic candidate. No additional gameplay build or test requested for the Phase 0 checkpoint.
