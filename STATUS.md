# EFP status — Phase 0 draft

Not yet merged; Phase 1 reconciliation is pending.

Candidate: M11, source commit `7a26ce3a909f13f7c5dee2afbc022febc2616f4e`. Historical baseline: M5-rc1, OBSERVED for NPC dialogue only. M11 is the installed diagnostic candidate, not a globally accepted baseline.

| Evidence | Status |
|---|---|
| READ | M11 fixed actor-root eye and native movement preflight; previous M6–M10 experiments excluded |
| COMPILED | [Actions run 45849781085](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45849781085), build and publish succeeded |
| PACKAGED | [Release](https://github.com/Hyperbog/NWN-EE-Mods/releases/tag/efp-M11-7a26ce3a909f13f7c5dee2afbc022febc2616f4e), five-DLL manifest printed in CI build job 140012813572; ZIP SHA-256 `2921b4880c73f9d34861b8f6c1f304dbe3b535d518832b187012b8d7906f5f47` |
| INSTALLED | User's Get-FileHash output matched version.dll SHA-256 `fe81fb1b6cf5b58d920cb477000da8f4b0147cc062961af634c12be42a2cdcec` |
| OBSERVED | [2026-11-26 M11 results](docs/testing/RESULTS/2026-11-26-M11.md): 14 reported pass, two reported fail; combat and vertical-contact concerns require further review. Release acceptance withheld. |

Known defects: angled-wall/corner trapping, diagonal movement along obstacles, dead NPC/remains collision, reported loss of combat animation, vertical-contact/height clipping and trapping after landing on NPC. No fresh log excerpts or repetition counts supplied for these observations.

Standing decision: camera tracks character position and mouse orientation; no collision-driven eye displacement. Minor wall-edge clipping accepted. Do not treat every visual defect as a camera problem. Do not resume M6–M10 camera retreat experiments.

Next: collect current M11 cx.log, prioritize angled-wall escape, diagnose one concern at a time. Phase 0 evidence recording in progress; no behavior fixes authorized by this results update.
