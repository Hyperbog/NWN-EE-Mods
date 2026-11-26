# NWNCX:EE upstream synchronization

Phase 2.5 — READ. Procedure only; no upstream update is authorized or performed by this document.

## Repositories and policy

- Upstream: [nwncxee/cx](https://github.com/nwncxee/cx).
- Source: [Hyperbog/cx](https://github.com/Hyperbog/cx), active development on main only; inherited Actions remain disabled.
- Distribution: [Hyperbog/NWN-EE-Mods](https://github.com/Hyperbog/NWN-EE-Mods), builds from the exact source pin in [BUILD_PLAN.json](../src/first-person/BUILD_PLAN.json).
- Current reference: source commit `b7895eda58cb1124e98a27109a1acc79e8544c6b`, tree `13e2a83859a4e711e90931df5c9a21ec5e2eeae1`, tag `efp-M11`. Direct-source CI [45909430241](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45909430241) passed (COMPILED); this package is not installed or gameplay-approved. See [STATUS.md](../STATUS.md) for the installed candidate.
- The archived initial upstream fork branch preserves history; it is not an integration target. Do not move historical tags, force-push, use GitHub's Sync fork button, or rebase published EFP commits. Do not silently update the game executable hash allowlist.

## 1. Inspect before integrating

Open a tracking issue naming the proposed upstream release/commit, rationale, target game build, acceptance criteria and rollback plan. Do not combine an upstream update with a feature or unrelated gameplay fix.

Use a new, unused local directory in a Visual Studio Developer Command Prompt (ordinary CMD syntax):

```cmd
git clone -c core.autocrlf=false --no-tags --single-branch --branch main https://github.com/Hyperbog/cx.git "C:\Projects\EFP_UPSTREAM_REVIEW"
cd /d "C:\Projects\EFP_UPSTREAM_REVIEW"
git status --porcelain
git rev-parse HEAD
git remote add upstream https://github.com/nwncxee/cx.git
git fetch --no-tags upstream main
git rev-parse FETCH_HEAD
```

Stop on any error or dirty checkout. Record the full starting EFP commit as OLD_CX and select the full reviewed upstream SHA as UPSTREAM_SHA. If a particular release tag is desired, fetch its exact tag ref without importing unrelated tags and resolve its commit with git rev-parse "FETCH_HEAD^{commit}". Do not assume a tag or latest main is compatible. The following placeholders must be replaced by those recorded hashes:

```cmd
git merge-base OLD_CX UPSTREAM_SHA
git log --oneline OLD_CX..UPSTREAM_SHA
git diff --stat OLD_CX...UPSTREAM_SHA
git diff --submodule=log OLD_CX...UPSTREAM_SHA
git diff --stat UPSTREAM_SHA...OLD_CX
```

Inspect the upstream changes AND EFP's changes since the common ancestor. Stop if ancestry is missing or unexpected. Record upstream release notes, game build support, overlapping changes and any new dependency or licensing requirements.

## 2. Compatibility checklist (required before publication)

| Area | Review |
| --- | --- |
| Native ABI and hooks | native/bootstrap_win.c, native/bootstrap.c, native/funchook-win-rel32.patch, native call signatures, hook targets and calling conventions; inspect tools/abi/check-win-symbols.py and vtable-slots.py against the intended executable using the appropriate local tools. ABI means the binary calling/interface contract. |
| Game build-specific offsets | managed/Framework/Builds/8193.37-17.tsv and any newly introduced build tables; confirm offsets, vtable slots, signatures and actual nwmain.exe identity. Never assume one game's offsets apply to another. |
| EFP integrations | ClientApi.cs, CameraDriveService.cs, StepGuardService.cs, FirstPersonHeadFilter.cs, FirstPersonVisibility.cs, JumpPhysics/JumpPositionService.cs, camera and animation services. Preserve ADR-001: fixed actor-root eye, no collision-driven eye retreat. |
| Dependencies | .gitmodules, funchook gitlink (M11: 88388db3c69e16c1560fee65c6857d75f5ce6fd5), native patch applicability, dependency pins, licenses, MSVC/.NET SDK and NativeAOT inputs. |
| Package | All five x64 PE DLLs: version.dll, cx_openal.dll, phonon.dll, shaderc_shared.dll, vma.dll; ZIP and individual SHA-256, exact source metadata, installer/rollback fixtures. |

READ: build-win-native.sh explicitly skips the executable symbol check on CI. A green package build therefore does not prove native ABI compatibility. Missing required local ABI evidence blocks gameplay acceptance; do not bypass it.

## 3. Integrate in an isolated local main checkout

Only after review and explicit approval:

```cmd
git merge --no-ff --no-commit UPSTREAM_SHA
git status
git diff --cached --stat
git diff --cached --check
git diff --cached --submodule=log
```

Stop for conflicts; inspect each resolution, especially native hooks, offsets and EFP movement/camera changes. Use git merge --abort to discard an incomplete merge. Do not auto-select all upstream or EFP versions. If already integrated, stop rather than manufacture a merge. After review, stage only approved resolutions, check for unresolved and unstaged changes, and commit with a Conventional Commit message identifying the upstream SHA and issue.

Initialize exact submodules with git submodule update --init --recursive; inspect git submodule status --recursive and require a clean tracked checkout. Record git rev-parse HEAD and git rev-parse "HEAD^{tree}". Check remote main still equals OLD_CX. With explicit authorization, push main normally (no force); a non-fast-forward rejection requires a fresh audit. Keep inherited fork Actions disabled.

## 4. Build and accept

Update only the distribution plan's reviewed direct_source commit and tree, with a distinct candidate version/revision and documented rationale. Keep the historical foundation field as provenance until a separately reviewed metadata migration changes its meaning. Push the distribution commit normally; its CI checks the pin, initializes submodules, runs installer fixtures, builds and validates the five-DLL package. Verify both jobs, manifest source identity and release ZIP digest. Failed CI: diagnose, at most two correction retries, then stop and reassess.

Require the [gameplay checklist](testing/CHECKLIST.md) on the selected game executable before gameplay approval. Record hashes, configuration, sanitized log excerpts and observed results in docs/testing/RESULTS; retest movement, walls, dialogue, combat, equipment, jumps and transitions. Keep issues #2–#6 open until actual evidence resolves them. A prerelease is not an accepted baseline.

## 5. Rollback

Before commit: git merge --abort if a merge is in progress. Before publishing: retain or discard only the isolated review workspace; remote state is unchanged. After publication: revert the distribution pin commit (or make a reviewed pin-restoration commit if later work exists); CI must rebuild from the former pin. Existing exact-commit releases and installed DLL backups remain available through [INSTALLER.md](INSTALLER.md).

If source main itself must be rolled back, review a new git revert -m 1 MERGE_COMMIT (replace the placeholder with the approved merge SHA; confirm first parent is the previous EFP main). Never reset or force-push remote main. A reverted merge remains in ancestry; future reintegration requires a deliberate reviewed revert-of-revert or corrective integration, not merely remerging the same upstream commit. Preserve all historic tags and releases.

Phase 2.5 acceptance: reviewed documentation and source paths; no actual upstream merge, new candidate build or installation.
