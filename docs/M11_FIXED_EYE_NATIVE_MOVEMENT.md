# M11 — Stable eye and native movement boundary

## Decision

User rejected collision-driven camera retreat and the resulting jitter. The target is the observable first-person behavior of Oblivion/Skyrim, not a claim about their undocumented engine internals. Minor wall clipping is explicitly acceptable; camera stability takes precedence. M5 is the retained functional baseline (mandatory Action Camera, dialogue camera hold). M6–M10 remain versioned but are not applied by the M11 build.

## Implementation

Driving first person has exactly one eye anchor: local creature world position + configured eye height. Mouse yaw/pitch supplies orientation. No animated head/attack/tether translation, yaw-dependent forward eye offset, wall-ray displacement, or collision smoothing is applied in Driving. The existing render-only local head/torso clearance and visibility publication remain, with zero wall offset; they do not move the camera or the gameplay creature. Other camera modes retain their existing behavior. Legacy world-camera collision controls are hidden from the settings interface.

Keyboard movement checks the requested direction before UpdateDriveMode, using the existing native TestDirectLine function and native personal-space/height arguments, including creature collision. A short 10 cm directional probe is the initial tuning choice. For combined forward/strafe input, retain a requested clear axis if the diagonal is blocked; this is not a general swept-capsule/continuous wall-slide solver. If fully blocked, present zero movement input to the native engine while preserving the actual held key slots, stop the active keyboard drive once, and re-evaluate the requested direction on subsequent frames. A clear direction resumes using the native changed-input latch. No repeated stop-packet retry loop. The new intent checks stand down in modal states, other camera modes and while airborne.

Before WalkUpdateLocation, check the next short segment of a keyboard-owned, single-waypoint client prediction; when it is obstructed or a keyboard stop was requested, shorten the existing waypoint to the safe desired position, allowing the native arrival procedure to run. Require matching player/area, native Driving=1, client provenance, one waypoint, correct cursor, no server correction, finite bounded endpoint and actual/desired agreement. Never overwrite a server-owned waypoint, animation ID, drive flag, array metadata or server position. Existing post-step walkmesh guard remains a safety net; it may still roll back unexpected native steps. NPC checks in that safety net are scoped to the recognized keyboard session. The 1.5-second stop ownership window and 2 cm agreement requirement intentionally reject ambiguous paths; unsupported paths can still exhibit persistent native walking. [m11drive] and [m11path] distinguish input blocking from local waypoint shortening.

## Evidence and limitations

Exact contextual patch replay against the five committed baseline patches succeeded for CameraService, CameraDriveService, StepGuardService, HeadBoneCamera and FirstPersonWorldGuard. Windows compilation, native calls and gameplay have not yet been verified. The eye no longer receives any collision displacement by design, but character/world replication and residual native rollback can still move the underlying anchor; stable runtime behavior is not yet established. A center-anchored eye and removal of attack camera movement may change perceived framing, body visibility and combat feel. The existing model-only clearance remains. This implementation may stop slightly early at walls or NPCs, and has no general continuous wall-slide solver. Native waypoint shortening is a bounded attempt at native completion, not proof that every stuck drive terminates. No through-wall targeting changes.

## Cloud release

The build plan now applies M1–M5 followed by M11. Previous source patches/releases and rollback snapshots remain available. GitHub Actions compiles/packages; installation is via the existing checksum-verifying release installer, with no local compilation. Do not install until the matching exact-commit package is published.
