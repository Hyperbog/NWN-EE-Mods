> **Historical record — not current instructions.** See [STATUS.md](../../STATUS.md) for current evidence and the [original snapshot](https://github.com/Hyperbog/NWN-EE-Mods/blob/bc3b0b4a6c1a0624602344b0636ebdc4cc3e9763/docs/CLOUD_RELEASES.md) for links in their original context.

# Cloud package workflow

M6 is the final intended local NativeAOT build. M7 and later are intended to use GitHub Actions and the published Windows release ZIP instead of requiring local Visual Studio compilation.

**One-time prerequisite:** the local source checkpoint 2470f0d27be0a29c152456aa60222f1f4fc25c34 was not found in the public upstream repository. From ordinary CMD, publish that committed checkpoint (not the uncommitted working tree, game files, config or logs):

    git -C "C:\Projects\NWN_FP_M5_NPC_DIALOG_STAGE" push https://github.com/Hyperbog/NWN-EE-Mods.git 2470f0d27be0a29c152456aa60222f1f4fc25c34:refs/heads/cx-build-base

No force push. Authenticate using Git Credential Manager if requested. This transfers committed Git source and its history; review the checkpoint history first if it contains private material. The build checks out the exact pinned commit.

The Actions workflow uses the upstream pinned Windows runner, .NET SDK and action revisions, initializes submodules, verifies the published source overlays, applies the explicit milestone sequence, builds NativeAOT, and verifies all five DLLs against the ZIP and their x64 PE headers. Success creates a prerelease and checksum manifest tied to the exact mod source commit. The cloud run and installer are not yet verified; no compiled release is claimed to exist.

The workflow can be manually run after the checkpoint is uploaded. Future milestone patch changes on main trigger it automatically. Update BUILD_PLAN.json's version and ordered patches with each milestone. Preserve previous releases. The next phase is a checksum-pinned one-command installer with a retained rollback backup, using the release asset rather than local compilation.

## M7 cloud deployment

The cx-build-base branch is now present at the exact pinned checkpoint. The workflow triggers on source, plan, installer and workflow changes. It publishes an explicitly commit-tagged prerelease after successful compilation and package checks. The new tools/Install-EFP.ps1 downloads only that exact release, validates the manifest, package and all five DLL hashes, checks the pinned game executable, snapshots the five currently installed DLLs into a unique previous-runtime directory and replaces only changed DLLs using named displaced backups. It can restore from its printed backup path. It does not change cx.cfg or compile anything locally. The installer is statically reviewed, not Windows-executed. No package is available until Actions successfully publishes the release.
