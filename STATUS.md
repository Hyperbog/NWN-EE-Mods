# EFP status — Phase 1.3 portable installer checkpoint

Phase 0 evidence exit criteria met on 2026-11-26. Phase 1.1 documentation and CI configuration consolidated into main under the product owner's revised main-only development policy (2026-11-26). COMPILED: integrated main CI run [45895431828](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45895431828) completed build and publication successfully; original installed candidate unchanged. Gameplay release acceptance is NOT met.

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

Issues #2–#6 now carry bug and P1 labels; priorities #5–#6 remain provisional pending diagnosis. No confirmed root cause. The user confirms complete turn-away and forward movement does not escape angled contact. See results for log evidence.

## Next

Phase 1: repository hygiene only. The [project brief](docs/PROJECT_BRIEF.md), [ADR-001](docs/decisions/ADR-001-fixed-actor-root-eye.md), README, feature reference, version register and changelog are integrated into main. The MIT contribution license, preserved NWNCX notice, .gitattributes, .editorconfig, issue/PR templates, Dependabot config and [repository standards](docs/REPOSITORY_STANDARDS.md) are consolidated into main (READ). PR CI run 45892845104 succeeded before integration (COMPILED); the publish job was skipped. Phase 1.2: 19 historical records moved to [docs/history](docs/history/README.md) with archival banners; live version register and cloud guide reconciled with the unchanged M11 build plan. Phase 1.3: portable installer implementation and Windows fixture test committed (READ); CI run 45901803873 failed at the disposable installer test before source reconstruction. READ: test mock state was script-scoped; the null-expression error occurred during the running-process refusal case. Corrected fixture state sharing and added explicit refusal assertions. COMPILED: retry [45903157287](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45903157287) succeeded on correction `e967f1f`; disposable installer fixture, source reconstruction, native build, five-DLL verification, artifact upload and publication all passed. Phase 1.3 CI acceptance met; actual Steam/GOG discovery and installation remain unobserved. No user installation required. Next: Phase 1.4 diagnostic organization. No runtime changes in the documentation foundation. Do not start runtime repairs until required intervening phases are complete. Keep M11 as installed diagnostic candidate. No additional gameplay build or test requested for the Phase 0 checkpoint.

## Known compatible build (tested configuration only)

OBSERVED: NWN:EE 8193.37-17 (M11 session log). READ: installer defaults to the known game executable SHA-256 `3b7cb1252e0edb2ce22d7971f333aade027039ae30a45b4bc64732c3e6bec73a`; compatibility with other game builds is not established. The NWNCX source checkpoint is `2470f0d27be0a29c152456aa60222f1f4fc25c34` (cx-build-base). The M11 exact-commit package is unchanged. Historical claims in the supplied brief are preserved verbatim, not maintained as live status.

## Development policy override — 2026-11-26

The product owner explicitly removed branch protection and directed all active work and commits to main. This supersedes the original brief's mandatory work branches, PR merging and branch protection clauses; retain the supplied brief as a historical record. Conventional Commits, issue tracking, diagnose-first, acceptance criteria, evidence levels, no force-push, CI for runtime/build changes, backups and rollback still apply. Optional PR CI remains available, not required. Preserve cx-build-base until the replacement build architecture no longer requires it. Existing documentation and CI histories are consolidated, not discarded. No gameplay change.
