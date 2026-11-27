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

- OBSERVED: supplemental revision 2 M11 checklist reports 11 PASS/7 FAIL; two logs reviewed and sanitized evidence recorded separately. No new runtime change or confirmed root cause.

- READ: Phase 3.2 standardized results template for all 18 scenarios, build provenance, five installed DLL checksums and sanitized evidence. OBSERVED: R3 combat synchronization reported working for tested sword/melee; prioritize #5 in Phase 4, preserving later improvements. No runtime changes.

- READ: Phase 3.3 map actual M11 log emitters, cadence, gates and evidence gaps to all 18 scenarios; reconcile inactive probe documentation. Phase 3 complete; issue #5 first for diagnose-first stabilization. No runtime edits or probe activation.

- READ: Phase 4.1A recover R3 package name and archived source provenance; independently compare cumulative J4 to M11 (11 changed files). Original R3 incremental package subsequently recovered and verified (15/15 immutable hashes, matching original source and five R2 backups, historical R3 build/runtime hash records agree). J1 subsequently recovers all five original R3 DLLs (actual hashes match R3 and J1 manifests) and exact pre-J1 jump fixtures; 18/18 package checks pass. Full R3 tree remains unverified. No runtime edits.

- READ: Phase 4.1B verify J4 archive and published jump source blob; compare J4/M11 combat paths, identify confirmed eye-integration changes and retained pose/render code, document isolation gate. No runtime edits or confirmed root cause.

- READ/OBSERVED: Phase 4.1C existing M11 logs show four recognized melee animation-state samples and up to 0.977 m requested adaptive clearance. Source traces shared color-record translation; causal link unconfirmed. Existing-setting isolation test pending; no runtime changes.

- OBSERVED: clearance-disabled combat test fails; product owner explicitly requests historical animation-aware eye/framing. READ: ADR-002 supersedes fixed-eye animation prohibition only; retain no wall-driven camera displacement and later gameplay improvements. Phase 4.1D next; no runtime changes.

- READ: Phase 4.1D implement ADR-002 in CX source commit `4e675d4e8e45056db1e17f6e598f3cdd7de23263`; restore grounded animated eye and historical attack framing, reset presentation contexts, preserve dialogue/airborne fallback, no Driving wall retreat or legacy locomotion tether. Five camera files changed, bounded telemetry and self-check assertions added. Compile/package and gameplay pending.

- READ: Phase 4.1E adopt independent engineering review findings; pin exact animation-aware candidate, update current checklist/template and brief precedence, record comparison protocol. Prior run 45917719418 was green for older M11 pin only. New Windows build/package pending; no runtime changes or gameplay approval.

- COMPILED/PACKAGED: Phase 4.1E run 45931914373 passed first attempt; exact combat candidate b54673b published with verified CI/release digest agreement and five-DLL manifest. Controlled installation authorized; runtime symbol/self-check and gameplay pending.

- OBSERVED: initial combat candidate report confirms restored combat animation and immersive animated movement; enemy-lunge clipping recorded separately as #9. Full checklist and exact installed identity remain pending. No runtime changes.

- OBSERVED: #9 preliminary isolation result, attackfollow.enabled=0 eliminated reported lunge clipping while preserving immersion in a small test. Extended verification pending; no runtime change.

- OBSERVED: #9 extended verification with attackfollow.enabled=0: seven PASS, zero FAIL, combat near walls pending; retain animated eye and immersion, plan minimal default-off change after final test. No runtime edit.

- OBSERVED: #9 wall-adjacent combat acceptable with expected clipping, eight-item isolation checklist completed; #4 ground bodies still obstruct. READ: CX `3e7d7ec9da65f4507df642d0a66f5f0f35a6b3e8` makes additive attack follow opt-in, changes only default and UI text; compilation/package and default verification pending.

- READ: product-owner direction supersedes unshipped opt-in decision; CX `61787ce17747b0027e4e574d06000bbb2e58caaa` removes redundant AttackCameraFollow implementation and registrations/calls completely. Keep retired code in history only; no new runtime package yet.

- READ: pin CX `61787ce17747b0027e4e574d06000bbb2e58caaa` / `32a9a8ce432ca3bc9824074e75dacdb88fd2945c` for the attack-follow removal build. Three-file source diff verified against prior combat candidate; Windows compilation and package checks pending, previous release preserved.

## M11 development candidate — 2026-11-26

### Changed
- READ: rebuild on M1–M5, fixed actor-root eye, native movement preflight, requested-axis fallback and bounded local-path completion attempt. Retire M6–M10 from active chain.

### Known issues
- OBSERVED: angled-wall escape and diagonal movement failures; remains collision, combat animation and vertical-contact concerns.

COMPILED: Actions run 45849781085. PACKAGED: exact-commit M11 preview release. INSTALLED: version.dll matched manifest. OBSERVED: release acceptance not met. See [STATUS.md](STATUS.md).

## Earlier milestones

See [version register](docs/FIRST_PERSON_VERSIONS.md). Historical source, packages and backup procedures are retained; no retroactive release acceptance is implied.
