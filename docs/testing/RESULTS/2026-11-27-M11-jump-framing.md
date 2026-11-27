# Issue #13 — Jump framing diagnostic observation

OBSERVED: diagnostic cx.log (1,030,903 bytes, 4,264 lines, SHA-256 c21e1477e654a73f23d1f5c820c902f2fb6f7ced68ee12858af8b1107080fac7), 2026-11-27 09:10:10–09:11:17 local. Startup identifies CX 9558f70498d48dc0f2dffe79812c460faa33341c, game 8193.37-17; CameraService.SelfCheck passed, separate pre-existing SSAO self-check failure. All 77 [efpjump] records match Alloy world snapshot 2560x1440 aspect 1.77778; 3 jumps at 60 vertical (33 records), 4 at 90 vertical (44). Requested/before/after/draw angle equal in every sample, projection scales constant within each setting (0.97428/1.73205 and 0.56250/1.00000), drawEyeDelta=0.0000 at recorded precision. Actor-relative eye changes 0.1573–0.1831 m at takeoff, 0.1335–0.1675 m at landing; airborne offset fixed (0,0,1.6500). Measured discontinuity supports eye handoff cause rather than sampled FOV change. No continuous presented-frame proof or independent DLL checksum. Owner explicitly approves horizontal player-facing FOV and modern FPS conventions. Separate lens conversion from jump handoff correction; no runtime changes in this checkpoint.

## Transition evidence

All distances below are Euclidean magnitudes of adjacent-frame actor-relative offsetStep, not actor displacement or camera world displacement.

| Jump | Vertical FOV | Takeoff log line | Takeoff m | Landing log line | Landing m |
| --- | ---: | ---: | ---: | ---: | ---: |
| 1 | 60 | 3030 | .1831 | 3165 | .1418 |
| 2 | 60 | 3174 | .1585 | 3195 | .1504 |
| 3 | 60 | 3203 | .1679 | 3225 | .1335 |
| 4 | 90 | 3427 | .1817 | 3441 | .1481 |
| 5 | 90 | 3449 | .1573 | 3465 | .1548 |
| 6 | 90 | 4173 | .1807 | 4195 | .1564 |
| 7 | 90 | 4209 | .1824 | 4222 | .1675 |

READ: CameraService.RestoreAnimatedEye excludes airborne state and falls back to actor world position + EyeHeight; both states use the same configured vertical FOV. This is the measured transition. Example jump 4 ground offset (-.0731,.1212,1.7640) -> takeoff (0,0,1.6500), actor rises .0404 m, eye offset step (.0731,-.1212,-.1140); world eye vertical change -.0736 m. At landing offset (-.0555,.1131,1.5722). No FOV compensation or physics modification indicated. Candidate approach: retain last valid actor-relative eye calibration across flight, resume fresh animated eye with bounded continuity blend, retain final local-model clearance and mouse authority, reset on invalid identity/area/gates; validate moving jumps, mouse turning, different rigs, landing and clipping before acceptance. Exact implementation pending separate review. Keep trace for correction comparison, remove once validated.

## Lens decision

See [ADR-004](../../decisions/ADR-004-horizontal-fov.md). Wide-angle edge stretch is expected from standard perspective, but log alone cannot quantify perceived distortion. Raw log/config not committed.