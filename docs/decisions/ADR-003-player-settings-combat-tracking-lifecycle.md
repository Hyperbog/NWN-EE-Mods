# ADR-003 — Player-facing settings, combat tracking and lifecycle controls

Status: Accepted product requirements; detailed implementation pending. Source reference CX 61787ce17747b0027e4e574d06000bbb2e58caaa. The five removal-candidate gameplay passes are repeated by the owner; not a new independently verified test run.

## Decisions

- [#10](https://github.com/Hyperbog/NWN-EE-Mods/issues/10): remove all Advanced-tier rows/disclosure from the CX in-game settings menu, not vanilla NWN menus. Keep meaningful player-facing settings. Internal tuning is not an alternate gameplay mode; rejected experiments remain removed. Do not silently rewrite user config. Review advanced-only groups, reset scope, nav dots, input and layout self-checks. Proposed reset scope: visible user settings only.
- [#11](https://github.com/Hyperbog/NWN-EE-Mods/issues/11): explicitly requested player setting for smooth tracking of the actual enemy engaged in automated combat. This is a requested feature, not an exception allowing rejected experiments. Manual mouse motion has immediate priority; suspend tracking until the reticle deliberately reacquires the current valid combat target. Aiming elsewhere never causes snap-back, including after mouse stops. Engaging another enemy transfers tracking only after actual native target changes; hovering alone must not issue combat actions. Clear/suspend on invalid/dead target, combat end, death, loading, area/player changes, dialogue, cutscene, UI and manual cursor release. Preserve animation-aware eye position and native combat. Setting default and smoothing details remain implementation decisions, not established user choices.
- [#12](https://github.com/Hyperbog/NWN-EE-Mods/issues/12): death must release relative mouse capture promptly, making native menu clickable. Loading/resuming valid living gameplay returns to first-person action-camera controls automatically. No capture while dead/loading or UI owns input. Reset stale target/drive/cursor state at verified lifecycle transitions; respect deliberate manual release during ordinary play. Preserve dialogue/cutscene and normal UI. No automatic menu clicking.

## READ evidence

KnobPanel.cs has Advanced disclosure/layout and nav visibility/dot logic; KnobPanel.SelfCheck.cs tests disclosure and Reset. TabTargetService.AimPoint/LockedOn drives existing hard lock and movement semantics, so reuse of hard lock without changes would conflict with mouse authority. ActionFeedback samples CNWCCreature.AiTarget and attack state; validate authoritative native state independent of feedback settings. MouseLookService.OnActionEvent processes relative motion; ActionGateOpen lacks explicit death predicate, SetAction(false) releases relative capture. GameGate.InGame can remain true while menus are visible; do not equate it with living controllable player. These are integration points, not confirmed root causes.

## Sequencing

Recommended: #12 lifecycle safety first, #10 menu cleanup, #4 remains investigation (previous next target), #11 combat tracking after input ownership is stable. Independent changes, compile/package/observed gate for each; do not combine runtime changes. Preserve source and release baseline and record missing installed hash. Other P1 issues remain open. No runtime edits in this decision commit.
