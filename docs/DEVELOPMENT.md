# First-Person Mod — Development

## Current baseline

The first-person controller, mouse-look, character-facing lock, jump motor, airborne steering, attack camera response and first-person wall/keyhole adjustments have been exercised in local Windows builds.

These are **experimental observations**, not a shipped compatibility guarantee. The working baseline currently exists in the developer's local NWNCX:EE checkout; the complete tested source and redistributable build have not yet been published here.

## Priority: first-person character rendering

**Observed defect:** the camera can see through or intersect the local character's head, torso, clothing, armor, or other equipment, especially during attack animations and near walls.

Planned approach:

1. Instrument the renderer to identify the local player's current model, rig, animated parts, attachments and draw calls.
2. Distinguish head and torso meshes from hands, weapons and shields; support helmet replacements and custom models.
3. Apply *local-player, first-person, color-pass-only* visibility filtering; do not delete parts from the world.
4. Preserve shadows, NPC rendering, third-person character visibility, attack animation and equipment state.
5. Fail conservatively for unknown rigs; expose diagnostics and a switch to disable the experiment.

**Non-goal:** hide the whole character permanently. The intention is an immersive body-aware first-person view.

## Compatibility matrix

Test each milestone against:

| Area | Cases |
| --- | --- |
| Character | Different playable races, sexes, phenotypes and sizes |
| Equipment | No helmet, helmets, robes, heavy armor, cloaks, weapons and shields |
| Combat | One-handed, two-handed, dual-wield, ranged, unarmed/monk, spells and unusual animations |
| Movement | Stand, run, strafe, jump from standstill, moving jump, midair steering and landing |
| Geometry | Walls, corners, doors, ceilings, tight interiors, ramps and area transitions |
| View | Free look, 180° turns, look down, attack tracking, third-person switching |
| Content | Base-game models plus representative community/custom models |

Record **build revision, settings, appearance, equipment, animation, observed result and screenshot** for each failure.

## Release gates

A release requires: a reproducible Windows x64 build; passing automated smoke tests; reversible installation; no regression in first-person controls and jump physics; documented supported game/client configuration; and completed representative compatibility testing.

Local source backups and game DLLs belong outside this public repository. Once validated, publish cohesive source changes rather than a chain of numbered hotfix archives.

## Branch policy

Use **`main` only**. Development milestones are tracked by commits and, once stable, GitHub Releases. Do not create feature/fix branches.
