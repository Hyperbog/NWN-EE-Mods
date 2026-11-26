# EFP version register

[STATUS.md](../STATUS.md) is authoritative. Milestone names identify historical source checkpoints, not independent stable releases. See [the archived register](history/FIRST_PERSON_VERSIONS.md) for original records.

| Milestone | Role | Historical record |
|---|---|---|
| J4 | OBSERVED: terrain-jump checkpoint (23/23 reported completed jumps in the earlier test session) | [J4](history/FIRST_PERSON_J4.md) |
| M1 | READ: EFP settings integration | [M1](history/M1_CX_SETTINGS_MENU.md) |
| M2 | READ: menu clarity | [M2](history/M2_SETTINGS_AUDIT.md) |
| M3 | READ: baked controls and turn correction | [M3](history/M3_BAKED_CONTROLS_AND_TURN.md) |
| M4 | READ: mandatory Action Camera | [M4](history/M4_ACTION_CAMERA.md) |
| M5 | OBSERVED: M5-rc1 NPC dialogue accepted; no global baseline | [M5](history/M5_NPC_DIALOGUE_CAMERA.md) |
| M6 | READ: retired wall release experiment | [M6](history/M6_WALL_RELEASE.md) |
| M7 | READ: retired wall near-plane experiment | [M7](history/M7_WALL_NEAR_PLANE.md) |
| M8 | READ: retired stable wall-contact experiment | [M8](history/M8_STABLE_WALL_CONTACT.md) |
| M9 | READ: retired blocked-drive recovery experiment | [M9](history/M9_BLOCKED_DRIVE_RECOVERY.md) |
| M10 | READ: retired stationary-eye/local-path experiment | [M10](history/M10_STATIONARY_EYE_AND_LOCAL_PATH.md) |
| M11 | OBSERVED: installed candidate; gameplay acceptance not met | [M11](history/M11_FIXED_EYE_NATIVE_MOVEMENT.md), [results](testing/RESULTS/2026-11-26-M11.md) |

## Current build and installed candidate

READ: [BUILD_PLAN.json](../src/first-person/BUILD_PLAN.json) pins [CX M11](https://github.com/Hyperbog/cx/commit/b7895eda58cb1124e98a27109a1acc79e8544c6b) directly. M1–M5 and M11 are preserved as Git commits and annotated tags; M6–M10 are retired historical experiments. See [legacy recovery](history/LEGACY_RECONSTRUCTION.md). COMPILED: direct-source CI [45909430241](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45909430241) passed; its preview has not been installed or gameplay-tested.

COMPILED: original M11 run [45849781085](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45849781085); integrated main run [45895431828](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45895431828) succeeded, including publication.

INSTALLED: the tested runtime remains the original M11 release at source commit `7a26ce3a909f13f7c5dee2afbc022febc2616f4e`, with version.dll SHA-256 `fe81fb1b6cf5b58d920cb477000da8f4b0147cc062961af634c12be42a2cdcec`. The later build is not the installed/tested binary. Do not infer behavioral acceptance from compilation or publication. See [STATUS.md](../STATUS.md) for evidence and the [README](../README.md) for pinned installation/rollback.

Historical local stage commands are not current installation guidance. Preserve existing releases and source records; semantic version migration is later work.
