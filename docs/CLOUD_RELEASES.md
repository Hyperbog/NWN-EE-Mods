# Cloud builds and release process

READ: [the workflow](../.github/workflows/efp-windows.yml) runs on source/build-related main pushes, manual dispatch and optional pull requests targeting main. Phase 2.4 (COMPILED: [45909430241](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45909430241)): the build checks out the exact CX commit and validates its tree against [BUILD_PLAN.json](../src/first-person/BUILD_PLAN.json), initializes pinned submodules, compiles NativeAOT on Windows and runs the existing five-DLL integrity checks in [cloud_build.py](../tools/cloud_build.py). No overlay or milestone patch replay occurs in the direct workflow. The manifest retains the distribution commit and original CX foundation, adds direct CX repository/commit/tree and records no replayed patches. Pull request jobs do not publish. Main builds publish commit-specific prereleases with a package, manifest and SHA256SUMS.

COMPILED: [run 45895431828](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45895431828), integrated main at `bc3b0b4a6c1a0624602344b0636ebdc4cc3e9763`, completed build and publish successfully. This does not mean its package has been installed or tested in game.

Phase 2.6 (COMPILED: [45910684322](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45910684322)): legacy reconstruction inputs and commands are removed from active main. The original `cx-build-base` branch remains a historical recovery reference, not a CI input. See [legacy recovery](history/LEGACY_RECONSTRUCTION.md) for exact checkpoint and rollback. The source fork's inherited Actions stay disabled; only the distribution repository builds and publishes. Do not force-push. Direct-main development is the current policy. No local Visual Studio build is required for the product owner.

Install only an exact-commit package explicitly chosen for testing; see [README](../README.md) and [STATUS.md](../STATUS.md). Do not select the latest package automatically. Preserve all five DLLs, cx.cfg, saves and rollback snapshot. The portable installer implementation is in main (READ); its synthetic Windows test is a build gate. See [installer guide](INSTALLER.md).

Future upstream integrations must follow [upstream synchronization](UPSTREAM_SYNC.md); only reviewed source pins trigger candidate builds. Do not automatically synchronize the fork.

[Historical cloud workflow](history/CLOUD_RELEASES.md) preserves the earlier bootstrap procedure; do not repeat it.

PACKAGED: [direct-source M11 prerelease](https://github.com/Hyperbog/NWN-EE-Mods/releases/tag/efp-M11-9bea65c9d83b700d68269592c840a03fb087e3f5) on distribution commit `9bea65c` is the first direct-source preview. Its release ZIP digest is `314a1f436de04d2b692506b966e136fdbe76cd13df7da2d8a9eb2754bb70f1c5`. The separate Actions artifact digest is `660326a284185a465b1b6c679ace4d5ba07de0e1ece9b2badbdb59c73b8f9063`. Neither digest is the installed version.dll checksum. The new preview has not been installed or gameplay-tested.

PACKAGED: [post-retirement M11 prerelease](https://github.com/Hyperbog/NWN-EE-Mods/releases/tag/efp-M11-c3312aa68d7ab017f0b09b291a345afe83685a7d) on distribution commit `c3312aa` passed after removing reconstruction inputs. Release ZIP SHA-256: `ef4047789eeed46ef1284ddb18291f86dbe15aebab4e30989e0e9c02b3f8064d` (CI manifest and GitHub asset digest agree). Separate Actions artifact SHA-256: `527351824ca30bbbb0784fc7d9ffc9e2e6a5b737bac52a7dfda7458a5967db1f` (upload log and GitHub artifact metadata agree). No new installation or gameplay acceptance.


## Animation-aware combat candidate

COMPILED/PACKAGED (2026-11-26 local, 2026-11-27 UTC): [run 45931914373](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45931914373) attempt 1 succeeded; build job 140286236880, publish job 140287956849. Installer fixture, pinned checkout, native build, five-DLL package, upload/download and publish passed. Source 4e675d4e8e45056db1e17f6e598f3cdd7de23263/tree c0dd20c6c874162182103bc43f49a8190a4101bd match plan and logged manifest; distribution b54673b2b192cad378e1b5d4d8e0edb0227ead19. [Exact prerelease](https://github.com/Hyperbog/NWN-EE-Mods/releases/tag/efp-M11-b54673b2b192cad378e1b5d4d8e0edb0227ead19) remains gameplay-unapproved. ZIP SHA-256 9ce531a449488a4fcd8310d47921f51f0100a690d8206d730bb7ab462c810071 matches logged manifest, publisher SHA256SUMS check and GitHub asset digest. Separate artifact 15168964116 SHA-256 a6910a31701ffca614a3a39525a7215a228e7a62cdee08300e8721db1a64f826 matches upload/download/API. No independent local download or DLL byte rehash performed. Native symbol check skipped because nwmain.exe absent; runtime self-checks and gameplay not executed in CI.

| DLL | Expected SHA-256 (CI manifest) |
| --- | --- |
| version.dll | 542dd2a7be85c936e784eaa4c1b73b5c5b3a60bc8952275e9ac0511bc122770a |
| cx_openal.dll | 3963b06e319180700be0bcc0d027336664bb3a4975876b4a5442f10746fab5b4 |
| phonon.dll | ca3dbc01dbc24492717011e80f6a51404ca143ae344ca660971d2c983f1e058d |
| shaderc_shared.dll | 8e13592eac48b94755e4aa4c41552b210b41ca906d0bfe35b0a6d47a97d0b7c6 |
| vma.dll | 504da73d9a8bb5acca40d8b563d8898c536329de07a1638f8cd9dbe1126d661e |

Phase 4.1E complete. Authorize only controlled test installation using exact distribution commit above and reviewed installer; restore original clearance configuration first. Record SWITCHED_AND_VERIFIED, all installed hashes and printed rollback path privately. Restore via same script -RestoreBackup and original WorkDir if necessary. Original M11 remains installed until user reports otherwise. Phase 4.1F begins with matched first/third-person combat per checklist revision 3; issue #5 and all other P1 remain open.
