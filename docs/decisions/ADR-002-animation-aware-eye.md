# ADR-002 — Animation-aware first-person eye and combat framing

Status: Accepted product direction, implementation and gameplay verification pending. Date: 2026-11-26.

## Context

[ADR-001](ADR-001-fixed-actor-root-eye.md) resolved unacceptable wall-driven camera retreat/jitter by fixing the eye to the actor root. Its prohibition on animation-driven eye displacement is now superseded by explicit product-owner clarification following the [Phase 4.1C test](../testing/COMBAT_ISOLATION.md). R3 is the verified historical behavioral reference; J4 is the later complete-source comparator, not exact R3 source.

OBSERVED: disabling adaptive model clearance did not restore acceptable combat presentation. The owner reports clipping, off-center view, camera behind character and no combat animation. Four screenshots show foreground self-model obstruction and intersecting equipment/geometry in the reported test. Still images cannot establish playback timing or exact camera transform. Actual test config/log and restoration not independently verified.

## Decision

Restore the J4-style animation-aware first-person eye: use the existing mapped animated head and torso pose, appearance-relative eye calibration and synchronized attack framing. Mouse yaw/pitch remain the aiming reference; historical bounded pose-driven camera response (including roll if required for the approved experience) may be evaluated, not arbitrary animation yaw/pitch. No race/weapon-specific offset tables or synthetic attack animation timing. Retain native body/attachment animation and the shared, render-only adaptive clearance pipeline; evaluate against the final animation-aware eye. Unsupported/invalid rigs fall back safely to calibrated actor-root eye.

Retain ADR-001's prohibition on collision-driven eye retreat/pushback and its separation of camera, native movement and local model presentation. Do not restore FirstPersonWorldGuard.Resolve in Driving, regress NPC dialogue hold or cursor ownership, change actor position/physics, overwrite native animation state or alter pathfinding as part of this isolated combat repair. Preserve jump translation without double-applying world displacement. Keep other gameplay issues open. Use existing verified historical implementation as the first comparator before refactoring; do not stack new speculative motion systems.

## Acceptance and scope

Phase 4.1D: targeted camera integration, validate finite/identity gates, reset on model/area changes, preserve M11 input/facing ownership and dialogue, validate fallback and avoid double-counting animation/jump translation. Compile/package separately and verify on multiple tested character/equipment variations, sword/melee attacks, idle/look, walking/running, jumps, walls/corners, dialogue, equipment changes, third-person restoration and reticle. No universal compatibility claim or confirmed native playback root cause. No runtime change in this decision commit.
