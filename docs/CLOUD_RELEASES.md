# Cloud builds and release process

READ: [the workflow](../.github/workflows/efp-windows.yml) runs on source/build-related main pushes, manual dispatch and optional pull requests targeting main. The build checks out the pinned CX checkpoint and submodules, reconstructs overlays and patches according to [BUILD_PLAN.json](../src/first-person/BUILD_PLAN.json), compiles NativeAOT on Windows and runs the five-DLL integrity checks in [cloud_build.py](../tools/cloud_build.py). Pull request jobs do not publish. Main builds publish commit-specific prereleases with a package, manifest and SHA256SUMS.

COMPILED: [run 45895431828](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45895431828), integrated main at `bc3b0b4a6c1a0624602344b0636ebdc4cc3e9763`, completed build and publish successfully. This does not mean its package has been installed or tested in game.

The pinned `cx-build-base` branch is a build input, not an active development branch. Do not delete it while the current workflow depends on it. Direct-main development is the current policy. No local Visual Studio build is required for the product owner.

Install only an exact-commit package explicitly chosen for testing; see [README](../README.md) and [STATUS.md](../STATUS.md). Do not select the latest package automatically. Preserve all five DLLs, cx.cfg, saves and rollback snapshot. Installer portability is Phase 1.3.

[Historical cloud workflow](history/CLOUD_RELEASES.md) preserves the earlier bootstrap procedure; do not repeat it.
