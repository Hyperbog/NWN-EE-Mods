# Repository standards

[PROJECT_BRIEF.md](PROJECT_BRIEF.md) defines the working agreement; [STATUS.md](../STATUS.md) tracks current evidence. Product owner override (2026-11-26): develop and commit directly on main. No required work branches or pull requests. Use Conventional Commits, one concern per commit, issue references and CI evidence. Never force-push main. This overrides conflicting branching/merge requirements in the preserved original brief.

## Label registry

| Label | Meaning | Proposed color |
| --- | --- | --- |
| bug | Observed defect | d73a4a |
| feature | Feature request | a2eeef |
| regression | Previously accepted behavior deteriorated | b60205 |
| docs | Documentation | 0075ca |
| build/ci | Build or CI concern | 1d76db |
| needs-repro | Missing reproducible evidence | fbca04 |
| blocked | External dependency or prerequisite | 5319e7 |
| P0 | Breaks game or installation | b60205 |
| P1 | Significant release-blocking gameplay concern | d93f0b |
| P2 | Lower-priority concern | 0e8a16 |

Use the existing GitHub enhancement label as a temporary alias for feature until the requested labels exist; then switch the feature template. READ: GitHub returned bug and P1 labels for each issue #2–#6 (priorities provisional for #5–#6). P1 was created with GitHub's default color rather than the proposed color. Do not infer regression solely from a reported symptom.

## Repository owner settings (pending)

- Description: Enhanced First Person for Neverwinter Nights: Enhanced Edition, built on NWNCX:EE.
- Topics: neverwinter-nights, nwn-ee, nwncx, first-person, game-mod, csharp.
- Main is intentionally unprotected at the owner's direction. Do not enable mandatory PR rules. Review each diff, check the main head before a non-force update, and do not overwrite a baseline or publish a gameplay-approved release without evidence. Optional PR CI remains available.
- Project board columns: Backlog, Ready, In progress, In test (user), Done. Milestones are release targets, not evidence of success.
- GitHub Actions dependencies are proposed weekly by Dependabot; review SHA pins and CI before merging.
- Follow [upstream synchronization](UPSTREAM_SYNC.md) for reviewed integrations into source main; keep fork Actions disabled and preserve exact distribution pins and historical tags.
- Never use mass normalization (git add --renormalize .) on the existing overlay/patch history before confirming unchanged manifest hashes and reconstruction.
- License and notice files cover EFP and NWNCX; review third-party dependency notices before a broadly distributed release.

These settings are a checklist, not a claim that branch protection, topics, labels or the project board are already configured. The available connector supports issue label application; repository-wide label creation/editing, description/topics, board and branch protection actions are not exposed. Mandatory branch protection is intentionally not part of the revised policy. Runtime/build changes still require successful CI before acceptance.
