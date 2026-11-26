# Changelog

All notable changes to Enhanced First Person will be documented here using the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format. Historical milestone names are retained pending semantic version migration.

## [Unreleased]

### Added
- Phase 0 evidence checkpoint, gameplay checklist, test results and issues #2–#6.
- Project brief and ADR-001; current documentation reconciliation (READ, no runtime changes).
- MIT license for EFP contributions, NWNCX third-party notice, formatting rules, contribution templates, weekly Actions dependency update configuration and label registry (READ). Applied bug/P1 labels to issues #2–#6.
- READ: consolidate documentation and PR CI into main; product owner adopts main-only direct commits with branch protection disabled. COMPILED: PR #7 run 45892845104 succeeded; integrated main CI run 45895431828 completed successfully (COMPILED).
- READ: archive 19 historical documents with original bodies retained; reconcile current version and cloud-build guides with STATUS.md and BUILD_PLAN.json. No runtime or installer changes.

- READ: portable installer resolves Steam/GOG or explicit game path, configurable work directory and executable hash allowlist, and pinned manifest version. Existing replacement/rollback core retained; Windows fixture CI run 45901803873 failed before compilation; READ: corrected test-only mock scope and added assertions for the running-process refusal; COMPILED: retry 45903157287 passed the installer fixture, source reconstruction, native build, package verification and publication. Phase 1.3 CI acceptance met; no new installation or gameplay evidence.

- READ: relocate two inactive diagnostic probe sources to `tools/diagnostics/` with unchanged blobs and document their limitations; include diagnostic path changes in Windows CI. Active source, build plan and overlay manifest unchanged. COMPILED: run 45904914275 passed on `1e0582f` without retries, including build and publish. READ: entire active source tree matches original M11 candidate. Phase 1 hygiene exit criteria met; gameplay acceptance still withheld.

- READ: Phase 2.1–2.3 source fork initialized and seven commits/six tags published; independent reconstruction equals CX tree `13e2a83859a4e711e90931df5c9a21ec5e2eeae1` (1,877 entries, zero differences).
- READ: Phase 2.4 direct-source CI pins CX commit and tree, adds source identity to release metadata, retains legacy package verification and installer rollback, and validates the direct-source manifest against the immutable distribution plan. CI 45908530208 failed at installer parsing before compilation; READ: repaired literal replacement corruption from the prior accepted installer; COMPILED: retry 1 run [45909430241](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45909430241) passed both installer fixtures, pinned checkout, native build, package checks and publication. PACKAGED: direct-source release ZIP digest matches CI manifest. Original installed M11 unchanged.

- READ: Phase 2.5 document the upstream synchronization procedure, native ABI/offset review, dependency pins, exact-source CI, gameplay gates and rollback. Documentation only; no upstream integration or runtime changes.

- READ: Phase 2.6 retire 71 obsolete reconstruction inputs from active main; preserve immutable history and original base ref, simplify the direct-source plan and packaging CLI without changing installer, fixtures or pinned CX source. COMPILED: run [45910684322](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45910684322) passed on `c3312aa` without retries. PACKAGED: release ZIP digest matches CI manifest and GitHub asset metadata. Phase 2 architecture complete; original installed M11 and gameplay acceptance unchanged.

- READ: Phase 3.1 formalize repeatable gameplay checklist revision 2, preserving IDs 01–16 and adding remains/NPC landing as 17–18. Clarify combat subresults, wall escape, repetition counts and evidence rules; original M11 results preserved, no runtime changes or new test session.

## M11 development candidate — 2026-11-26

### Changed
- READ: rebuild on M1–M5, fixed actor-root eye, native movement preflight, requested-axis fallback and bounded local-path completion attempt. Retire M6–M10 from active chain.

### Known issues
- OBSERVED: angled-wall escape and diagonal movement failures; remains collision, combat animation and vertical-contact concerns.

COMPILED: Actions run 45849781085. PACKAGED: exact-commit M11 preview release. INSTALLED: version.dll matched manifest. OBSERVED: release acceptance not met. See [STATUS.md](STATUS.md).

## Earlier milestones

See [version register](docs/FIRST_PERSON_VERSIONS.md). Historical source, packages and backup procedures are retained; no retroactive release acceptance is implied.
