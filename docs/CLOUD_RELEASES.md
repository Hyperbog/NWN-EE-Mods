# Cloud builds and release process

READ: [the workflow](../.github/workflows/efp-windows.yml) runs on source/build-related main pushes, manual dispatch and optional pull requests targeting main. Phase 2.4 (READ; CI pending): the build checks out the exact CX commit and validates its tree against [BUILD_PLAN.json](../src/first-person/BUILD_PLAN.json), initializes pinned submodules, compiles NativeAOT on Windows and runs the existing five-DLL integrity checks in [cloud_build.py](../tools/cloud_build.py). No overlay or milestone patch replay occurs in the direct workflow. The manifest retains the distribution commit and original CX foundation, adds direct CX repository/commit/tree and records no replayed patches. Pull request jobs do not publish. Main builds publish commit-specific prereleases with a package, manifest and SHA256SUMS.

COMPILED: [run 45895431828](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45895431828), integrated main at `bc3b0b4a6c1a0624602344b0636ebdc4cc3e9763`, completed build and publish successfully. This does not mean its package has been installed or tested in game.

The pinned `cx-build-base` branch and legacy reconstruction inputs are retained for rollback until Phase 2.6. The source fork's inherited Actions stay disabled; only the distribution repository builds and publishes. To roll back the migration, revert its distribution commit; do not force-push. Direct-main development is the current policy. No local Visual Studio build is required for the product owner.

Install only an exact-commit package explicitly chosen for testing; see [README](../README.md) and [STATUS.md](../STATUS.md). Do not select the latest package automatically. Preserve all five DLLs, cx.cfg, saves and rollback snapshot. The portable installer implementation is in main (READ); its synthetic Windows test is a build gate. See [installer guide](INSTALLER.md).

[Historical cloud workflow](history/CLOUD_RELEASES.md) preserves the earlier bootstrap procedure; do not repeat it.
