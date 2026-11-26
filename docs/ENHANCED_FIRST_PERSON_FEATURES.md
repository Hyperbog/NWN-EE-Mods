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

READ: M11 uses the creature's world position plus configured eye height and mouse orientation. It bypasses animation-driven camera motion and world-camera retreat in Driving. Local-model clearance remains render-only. Native directional walkability preflight and a guarded local-path completion attempt operate separately. J4 uses native ground elevation as a proxy, not a general support-surface solver. The inherited R3 red combat dot and selected-target damage crescents do not establish attacker attribution.

READ: full continuous wall sliding, arbitrary furniture/NPC surface support, universal race/model/tileset compatibility and standalone-plugin integration are not established features. See [issues](https://github.com/Hyperbog/NWN-EE-Mods/issues), [test results](testing/RESULTS/2026-11-26-M11.md) and [ADR-001](decisions/ADR-001-fixed-actor-root-eye.md).
