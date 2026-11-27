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


## Attack-follow removal candidate

COMPILED/PACKAGED: [Windows CI 45939756819](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45939756819), attempt 1, both build (140311108403) and publish (140312670606) passed. Checkout and CI manifest match distribution e28ea1efc74ad7d06b5f7f71737512b20d09d93f, CX 61787ce17747b0027e4e574d06000bbb2e58caaa, tree 32a9a8ce432ca3bc9824074e75dacdb88fd2945c. [Exact prerelease](https://github.com/Hyperbog/NWN-EE-Mods/releases/tag/efp-M11-e28ea1efc74ad7d06b5f7f71737512b20d09d93f) ZIP SHA-256 db0a43d1fe3fab39781a6111eeb30dfd7f5fc46b5853c607481ba7796a420f68 agrees with CI manifest and GitHub asset digest; publish SHA256SUMS check passed. Actions artifact 15172267859 SHA-256 3264eb45acf5bed71dde26be18c865c131a7b9fa062f80dd1584596f141c8fbb matches upload/download logs and API. Five DLLs verified by CI; only version.dll hash differs from previous combat package. No independent local binary rehash performed. Native symbol check skipped (nwmain.exe absent on runner); in-game checks pending.

| DLL | Expected SHA-256 |
| --- | --- |
| version.dll | eabe6cb06ed25ac175eab31004d39b21124d7614f9d93b747ca9308ecdee8e34 |
| cx_openal.dll | 3963b06e319180700be0bcc0d027336664bb3a4975876b4a5442f10746fab5b4 |
| phonon.dll | ca3dbc01dbc24492717011e80f6a51404ca143ae344ca660971d2c983f1e058d |
| shaderc_shared.dll | 8e13592eac48b94755e4aa4c41552b210b41ca906d0bfe35b0a6d47a97d0b7c6 |
| vma.dll | 504da73d9a8bb5acca40d8b563d8898c536329de07a1638f8cd9dbe1126d661e |

Controlled installation authorized for exact distribution commit above. Preserve config and rollback snapshot; after installation back up cx.cfg and remove only obsolete attackfollow.* keys if present with game closed. Generic unknown-key preservation unchanged. Test lunge, head/torso synchronization, locomotion immersion and absence of retired controls; record exact installed hashes, startup log and gameplay. If rollback necessary use same reviewed installer, -RestoreBackup and original WorkDir; older combat build requires attackfollow.enabled=0 restored explicitly. Issue #9 open until observed verification. Issue #4 next; no global acceptance.


## Advanced settings removal candidate

COMPILED/PACKAGED: [Windows CI 45943802132](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45943802132), attempt 1, build 140323800841 and publish 140325582345 passed. Checkout and logged manifest match distribution 545eb66d7b1fd0c842443a463c84c30cc8a048bb, CX d4f8ac98b1d759d33724b37f547253fb61d1349c/tree bc058a44fe6b668f53937912f32a301d411613d7. [Exact prerelease](https://github.com/Hyperbog/NWN-EE-Mods/releases/tag/efp-M11-545eb66d7b1fd0c842443a463c84c30cc8a048bb), ZIP SHA-256 a0f1e5be82e7d45fe7eb9ac7df027359ad12baab7d2335938c71216964990ed9 matches CI manifest and GitHub asset metadata; publisher SHA256SUMS check passed. Actions artifact 15174221457 SHA-256 8da7c35f8d4d11062b30faf5b4056c2585c79f339bf56949b20e679dcebb5a95 agrees with upload/download logs and API. Installer fixtures passed. Only version.dll hash differs from previous package. No independent local binary rehash or in-game self-check; native symbol check skipped because runner lacks nwmain.exe.

| DLL | Expected SHA-256 |
| --- | --- |
| version.dll | 86950d122c0765986ca9e64eb9ea07bb32aef26b513b8f8e839aa96a21217370 |
| cx_openal.dll | 3963b06e319180700be0bcc0d027336664bb3a4975876b4a5442f10746fab5b4 |
| phonon.dll | ca3dbc01dbc24492717011e80f6a51404ca143ae344ca660971d2c983f1e058d |
| shaderc_shared.dll | 8e13592eac48b94755e4aa4c41552b210b41ca906d0bfe35b0a6d47a97d0b7c6 |
| vma.dll | 504da73d9a8bb5acca40d8b563d8898c536329de07a1638f8cd9dbe1126d661e |

Controlled installation authorized for exact release commit; close NWN, preserve config backup and installer rollback snapshot, capture successful installer output and fresh cx.log. Verify Advanced rows/disclosure absent across CX submenus, ordinary controls and status available, settings persist on restart, layout at 720p/1080p where supported, Reset affects displayed User controls only (back up and restore test settings; do not alter hidden engineering values), combat and camera immersion preserved. #10 remains open pending scoped observation. #12 death/load input investigation follows. Prior e28ea1e package retained; restore with pinned installer and printed backup if needed.
