# NWN:EE Fix 14D — J4 first-person controller

## Scope and status

This project extends [NWNCX:EE](https://github.com/nwncxee/cx), not the stock NWN:EE module system. The custom source has been built and exercised locally on Windows. The complete source must be integrated into the matching NWNCX checkout and rebuilt; copying a single C# source file or a game DLL from another version is not a valid installation method.

**Tested gameplay baseline (November 22, 2026):** J4 jumping completed 23/23 observed trials (13 nearly level, 4 downhill, 6 uphill), with zero recorded jump safety aborts or position corrections. The C3C visual clearance sampler recorded no rejected poses in the same session. These results are not a guarantee for every tileset, custom model, multiplayer server, or game version.

## Features

- Body-aware **first-person eye/camera** follows the animated head and adjusts local-player color rendering for torso/head clearance. Model render displacement is local and render-only; it does not move the authoritative world character or alter the shadow/other actors' state.
- Mouse-look and camera-relative WASD driving preserve the native movement speeds, including movement modifiers, rather than replacing the engine with sliding/inertial physics.
- Centered dot reticle. **In combat the dot stays red.** When the existing selected-target damage event fires, two small **red side crescents** flash for about **160 ms**. The small pending-action square beneath the dot was removed.
- Airborne jump physics with the same impulse, gravity, and horizontal steering as the earlier prototype. **J4** anchors the ballistic height to takeoff elevation; it checks native walk elevation for contact so downhill flight can continue below launch height and uphill landings occur on higher walkable ground.
- J3 safety protections reject suspicious abrupt ground-reference changes. Unsupported falls exit to native movement within a bounded duration/drop.
- Bounded diagnostic traces D1–D5 investigate movement stop delays and native walk-position changes. These traces log state; they do not replace server-authoritative movement.

## Engine boundaries and non-goals

- First-person rendering and the local jump motion interact with **client engine internals**. The server remains authoritative; this is **not** a server-side generalized platforming system.
- The walk-height sample is a **ground proxy**, not a complete walkable-support query. A render mesh, crate, placeable, or table is **not** automatically a valid landing surface. Jumping onto arbitrary objects has **not** been implemented.
- The red crescent marker responds to a selected target's damage report. The event may reflect damage from other party members and is not an attacker-authenticated hit confirmation.
- No stable release, broad compatibility guarantee, or automated Windows CI validation is provided here.

## Evidence and diagnostics

| Revision | What it established |
| --- | --- |
| C3C | Adaptive local player body/eye visibility clearance in sampled attacks |
| D1–D4 | Continued movement after input release is not directly explained by the measured drive-update or inbound-dispatch window |
| D5 | Continued movement is measured inside `CNWCCreature::WalkUpdateLocation` |
| R3 | Combat-red dot with red open-top/bottom side crescents; no pending-action square |
| J1 | Original jump reused takeoff height and could clip or abort on inclines |
| J2–J3 | Terrain-relative jumping and bounded slope/height safety checks |
| J4 | Independent world-space jump arc; landing on rising/falling walkmesh terrain |

The raw `cx.log` files are intentionally excluded because they may include local system details. Numbers above describe limited user gameplay sessions, not exhaustive validation.

## Version compatibility and configuration

- NWNCX local checkpoint before J4: `2470f0d27be0a29c152456aa60222f1f4fc25c34`, derived from upstream base `b4b43a54ed68aa1072ce1715c0479b2fb127b5ef`.
- Do **not** blindly apply these offsets/patches to today's upstream `main`. The engine hooks and build-locked Windows RVAs must be revalidated for each game build.
- Game configuration is normally `%USERPROFILE%\\Documents\\Neverwinter Nights\\cx.cfg`; maintain a backup and do not overwrite it during source publication.
- Target reticle settings include `driving.reticle=1`, `driving.reticlestyle=1`, `driving.hitmarker=1`; other feedback can be separately disabled. Existing user settings may override defaults.

See [source integration](FIRST_PERSON_SOURCE.md).