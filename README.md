# Enhanced First Person (EFP) — Neverwinter Nights: Enhanced Edition

Experimental first-person camera, movement, jumping and combat-reticle modification integrated into [NWNCX:EE](https://github.com/nwncxee/cx). The target is responsive Oblivion/Skyrim-style first-person control: the eye follows the actor's position and mouse orientation, never retreats to avoid wall clipping. Minor wall clipping is acceptable.

## Current development state

**M11 development candidate — not an approved stable release.** See [STATUS.md](STATUS.md) for the authoritative evidence, exact candidate, compatible game build and known defects. The last observed dialogue baseline is M5-rc1; M11 was built, packaged, installed and gameplay-tested, but release acceptance was not met.

## Installation and rollback

Use the [M11 exact-commit preview release](https://github.com/Hyperbog/NWN-EE-Mods/releases/tag/efp-M11-7a26ce3a909f13f7c5dee2afbc022febc2616f4e). The original pinned M11 installer below is the known historical deployment procedure. Phase 1.3 portable installer passed Windows fixture CI ([45903157287](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45903157287)); see [portable installer guide](docs/INSTALLER.md). Do not install into another game build or mix runtime versions. Close NWN before changing runtime files. For the original tester only, in ordinary CMD:

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $p=Join-Path $env:TEMP 'Install-EFP-M11.ps1'; Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/7a26ce3a909f13f7c5dee2afbc022febc2616f4e/tools/Install-EFP.ps1' -OutFile $p; & $p -Version M11 -SourceCommit 7a26ce3a909f13f7c5dee2afbc022febc2616f4e"
```

Expected: installer checks the exact release and game hashes, snapshots all five DLLs, prints ROLLBACK BACKUP and SWITCHED_AND_VERIFIED. Confirm the installed version.dll checksum against STATUS.md. Preserve cx.cfg and saves. To undo, close NWN and use the exact rollback directory printed by that installation:

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\Install-EFP-M11.ps1" -RestoreBackup "PATH_PRINTED_BY_INSTALLER"
```

Replace the placeholder with the recorded backup path. If the backup or installer is unavailable or refuses, do not bypass checks. No local compilation required.

## Development and known limits

- [Current feature reference](docs/ENHANCED_FIRST_PERSON_FEATURES.md)
- [Version register](docs/FIRST_PERSON_VERSIONS.md)
- [Cloud build guide](docs/CLOUD_RELEASES.md)
- [Upstream synchronization procedure](docs/UPSTREAM_SYNC.md)
- [Historical records](docs/history/README.md)
- [Technical references](docs/REFERENCES.md)
- [Inactive diagnostic probes](tools/diagnostics/README.md)
- [Project brief and working agreement](docs/PROJECT_BRIEF.md)
- [Camera architecture decision](docs/decisions/ADR-001-fixed-actor-root-eye.md)
- [Gameplay acceptance checklist](docs/testing/CHECKLIST.md)
- [M11 test record](docs/testing/RESULTS/2026-11-26-M11.md)
- [Changelog](CHANGELOG.md) and [open issues](https://github.com/Hyperbog/NWN-EE-Mods/issues)

READ: Phase 2.4 direct-source CI pins the equivalent M11 commit/tree in [BUILD_PLAN.json](src/first-person/BUILD_PLAN.json) from [Hyperbog/cx](https://github.com/Hyperbog/cx). COMPILED: final direct-source CI [45910684322](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45910684322) passed after reconstruction retirement; historical overlay and patch inputs are retired from active main and preserved at the [legacy recovery checkpoint](docs/history/LEGACY_RECONSTRUCTION.md). The new package has not been installed or gameplay-tested. This is not a standalone C# plugin. The five matching runtime DLLs are distributed through Releases, not committed to Git. EFP contributions are under the [MIT license](LICENSE); the original NWNCX copyright and license are retained in [third-party notices](THIRD_PARTY_NOTICES.md). COMPILED: portable installer fixture CI passed; actual Steam/GOG discovery and installation remain unobserved. See [repository standards](docs/REPOSITORY_STANDARDS.md).

Development policy: active work is committed directly to `main`; see [repository standards](docs/REPOSITORY_STANDARDS.md). Optional PR CI remains available. The original pinned base branch is retained for historical recovery only.
