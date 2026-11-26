# ADR-001 — Fixed actor-root eye; wall clipping accepted

Status: Accepted product decision; M11 partial gameplay acceptance. Date: 2026-11-26.

An architecture decision record (ADR) preserves one design decision and its rationale.

## Context

OBSERVED: M6–M10 wall-camera corrections reduced clipping but caused unacceptable camera pushback/jitter and did not resolve all movement trapping. M11 straight-wall and angled-contact camera rotation tests passed, but corner escape and diagonal obstacle movement failed. Combat and vertical-contact observations remain unresolved.

## Decision

READ: the first-person eye is attached to the actor's world position plus configured eye height; orientation follows mouse input (dialogue retains held orientation). Do not move the eye independently in response to world collision or animation. Actual actor translation, elevation and jumping still move the camera. Minor visual wall clipping is acceptable. Character movement/collision, native animation and render-only presentation are separate concerns.

## Consequences

Prioritize movement prevention and escape, not camera retreat. Restore intended visible combat animation without violating the fixed-eye requirement. Do not claim full gameplay acceptance without OBSERVED evidence. Future changes must preserve camera stability during obstacle contact and test relevant regressions. Full wall sliding and support-surface physics are separate features, not assumed M11 capabilities.

See [status](../../STATUS.md), [results](../testing/RESULTS/2026-11-26-M11.md), and [issue #2](https://github.com/Hyperbog/NWN-EE-Mods/issues/2).
