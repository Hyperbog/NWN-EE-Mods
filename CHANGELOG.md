# Changelog

All notable changes to Enhanced First Person will be documented here using the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format. Historical milestone names are retained pending semantic version migration.

## [Unreleased]

### Added
- Phase 0 evidence checkpoint, gameplay checklist, test results and issues #2–#6.
- Project brief and ADR-001; current documentation reconciliation (READ, no runtime changes).
- MIT license for EFP contributions, NWNCX third-party notice, formatting rules, contribution templates, weekly Actions dependency update configuration and label registry (READ). Applied bug/P1 labels to issues #2–#6.
- READ: consolidate documentation and PR CI into main; product owner adopts main-only direct commits with branch protection disabled. COMPILED: PR #7 run 45892845104 succeeded; integrated main CI run 45895431828 completed successfully (COMPILED).
- READ: archive 19 historical documents with original bodies retained; reconcile current version and cloud-build guides with STATUS.md and BUILD_PLAN.json. No runtime or installer changes.

- READ: portable installer resolves Steam/GOG or explicit game path, configurable work directory and executable hash allowlist, and pinned manifest version. Existing replacement/rollback core retained; Windows fixture CI run 45901803873 failed before compilation; READ: corrected test-only mock scope and added assertions for the running-process refusal; retry pending.

## M11 development candidate — 2026-11-26

### Changed
- READ: rebuild on M1–M5, fixed actor-root eye, native movement preflight, requested-axis fallback and bounded local-path completion attempt. Retire M6–M10 from active chain.

### Known issues
- OBSERVED: angled-wall escape and diagonal movement failures; remains collision, combat animation and vertical-contact concerns.

COMPILED: Actions run 45849781085. PACKAGED: exact-commit M11 preview release. INSTALLED: version.dll matched manifest. OBSERVED: release acceptance not met. See [STATUS.md](STATUS.md).

## Earlier milestones

See [version register](docs/FIRST_PERSON_VERSIONS.md). Historical source, packages and backup procedures are retained; no retroactive release acceptance is implied.
