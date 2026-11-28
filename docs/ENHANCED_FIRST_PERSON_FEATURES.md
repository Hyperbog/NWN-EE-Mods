# Enhanced First Person — Current feature reference

[STATUS.md](../STATUS.md) is authoritative for the current candidate and evidence. This reference describes M11, not J4 or retired M6–M10. Earlier feature wording remains in Git history.

| Feature | Evidence | Current behavior and limits |
|---|---|---|
| Eye and mouse-look | OBSERVED | Idle camera, straight wall contact and angled-contact rotation passed reported tests. The eye follows the actor, not collision retreat. Minor clipping accepted. |
| Action Camera and Z | OBSERVED | Cursor release/recapture and NPC dialogue passed. |
| Ground movement | OBSERVED | Clear-space walk/run/strafe/diagonal and ordinary key-release tests passed; angled-wall escape and diagonal obstacle movement failed. |
| Collision | OBSERVED | Living NPC ground contact passed; dead NPC/remains trapping reported. No confirmed cause. |
| Combat | OBSERVED | Initial checklist passed, but user reports missing combat animation. Clarification required; not accepted. |
| Jumping | OBSERVED | Flat/slope tests passed; NPC landing/height clipping reported. Extended vertical-contact testing required. |
| Settings, equipment, save/load, area transition | OBSERVED | Reported checklist passes in tested session. |

READ: the active continuous-eye source uses the mapped live animated rig through ground and flight, with calibrated actor-root fallback for invalid samples. Mouse aim and zero collision-driven eye retreat remain; local-model clearance is render-only. Driving exposes horizontal FOV (`driving.hfov`, default 90), converted to vertical degrees at the camera boundary; the legacy vertical key is preserved. Native directional walkability preflight and a guarded local-path completion attempt operate separately. J4 uses native ground elevation as a proxy, not a general support-surface solver. The inherited R3 red combat dot and selected-target damage crescents do not establish attacker attribution. See [ADR-002](decisions/ADR-002-animation-aware-eye.md), [ADR-004](decisions/ADR-004-horizontal-fov.md) and [STATUS.md](../STATUS.md). The table records historical observations, not new gameplay acceptance.

READ: full continuous wall sliding, arbitrary furniture/NPC surface support, universal race/model/tileset compatibility and standalone-plugin integration are not established features. See [issues](https://github.com/Hyperbog/NWN-EE-Mods/issues), [test results](testing/RESULTS/2026-11-26-M11.md) and [ADR-001](decisions/ADR-001-fixed-actor-root-eye.md).
