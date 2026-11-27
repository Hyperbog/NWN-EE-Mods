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


## Issue #10 integration checkpoint

READ: Codex supplied Issue #10 patch applied verbatim to CX d4f8ac98b1d759d33724b37f547253fb61d1349c, tree bc058a44fe6b668f53937912f32a301d411613d7, parent 61787ce17747b0027e4e574d06000bbb2e58caaa. All four old blob identifiers and all hunk contexts/counts matched; resulting four blobs match provided abbreviated hashes (2b14c41, 9f3002e, 348bc60, cd75034). Full recursive tree comparison against parent confirms exactly four UI files changed, 95 additions and 149 deletions. Removes Advanced panel rows/disclosure/state and related tooltip handling; visible User rows and player-facing status remain, nav dots and Reset use visible User controls, hidden settings preserved. Codex reports managed Release compilation with zero errors (150 warnings outside changed files) and isolated Linux KnobPanel.SelfCheck PASS, not independently reproduced. Windows NativeAOT build, packaged release and gameplay remain pending. Distribution BUILD_PLAN remains on prior combat removal source pending separate compile/package gate. Test 720p/1080p layout, no Advanced controls, ordinary settings persistence, visible reset and hidden values preserved, and disabled Advanced master read-only notice. #10 remains open; #12 follows this isolated integration and verification. No other runtime changes.


## Issue #10 compiled/package checkpoint

COMPILED/PACKAGED: [Windows CI 45943802132](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45943802132), attempt 1, build 140323800841 and publish 140325582345 passed. Checkout and logged manifest match distribution 545eb66d7b1fd0c842443a463c84c30cc8a048bb, CX d4f8ac98b1d759d33724b37f547253fb61d1349c/tree bc058a44fe6b668f53937912f32a301d411613d7. [Exact prerelease](https://github.com/Hyperbog/NWN-EE-Mods/releases/tag/efp-M11-545eb66d7b1fd0c842443a463c84c30cc8a048bb), ZIP SHA-256 a0f1e5be82e7d45fe7eb9ac7df027359ad12baab7d2335938c71216964990ed9 matches CI manifest and GitHub asset metadata; publisher SHA256SUMS check passed. Actions artifact 15174221457 SHA-256 8da7c35f8d4d11062b30faf5b4056c2585c79f339bf56949b20e679dcebb5a95 agrees with upload/download logs and API. Installer fixtures passed. Only version.dll hash differs from previous package. No independent local binary rehash or in-game self-check; native symbol check skipped because runner lacks nwmain.exe.

| DLL | Expected SHA-256 |
| --- | --- |
| version.dll | 86950d122c0765986ca9e64eb9ea07bb32aef26b513b8f8e839aa96a21217370 |
| cx_openal.dll | 3963b06e319180700be0bcc0d027336664bb3a4975876b4a5442f10746fab5b4 |
| phonon.dll | ca3dbc01dbc24492717011e80f6a51404ca143ae344ca660971d2c983f1e058d |
| shaderc_shared.dll | 8e13592eac48b94755e4aa4c41552b210b41ca906d0bfe35b0a6d47a97d0b7c6 |
| vma.dll | 504da73d9a8bb5acca40d8b563d8898c536329de07a1638f8cd9dbe1126d661e |

Controlled installation authorized for exact release commit; close NWN, preserve config backup and installer rollback snapshot, capture successful installer output and fresh cx.log. Verify Advanced rows/disclosure absent across CX submenus, ordinary controls and status available, settings persist on restart, layout at 720p/1080p where supported, Reset affects displayed User controls only (back up and restore test settings; do not alter hidden engineering values), combat and camera immersion preserved. #10 remains open pending scoped observation. #12 death/load input investigation follows. Prior e28ea1e package retained; restore with pinned installer and printed backup if needed.


## Issue #10 observation and new FOV investigation

OBSERVED (2026-11-27): owner reports all seven Issue #10 checks PASS: Advanced absent, normal controls functional, restart persistence, layout, displayed-only Reset, combat synchronization, camera immersion. Scoped menu acceptance met; close #10 on observed behavior, reopen on recurrence. Exact installed hashes, fresh log and tested resolution count not supplied; no independent INSTALLED evidence. Source d4f8ac98, distribution release 545eb66, CI 45943802132. #12 next.

READ/OBSERVED: new #13 tracks stretching above ~60 FOV and apparent jump FOV change. Current slider is vertical degrees; rectilinear perspective at 16:9 yields ~91.5 horizontal at 60 vertical. Verify actual viewport/projection before altering semantics. Airborne RestoreAnimatedEye uses root+eye-height fallback, resets animated pose; same configured FOV written in active Driving grounded and airborne. Apparent zoom from eye-position handoff is plausible, actual renderer change unconfirmed. Record actual viewport/renderer and matched stationary jump/landmark samples; no speculative clamp, projection rewrite, or camera change. Preserve accepted baseline. Queue #13 after #12 unless owner redirects.


## Issue #13 diagnostic integration checkpoint

READ: owner authorizes isolated Issue #13 diagnostic integration before #12. Codex patch applied verbatim to CX 9558f70498d48dc0f2dffe79812c460faa33341c, tree 749203fbf376649e2fd7ad501a3a39724ab20cc6, parent d4f8ac98b1d759d33724b37f547253fb61d1349c. Both old blob prefixes matched; every hunk context and count matched; all three new blob prefixes matched (f343eaf, c787c25, 1ac133f). Complete recursive tree comparison confirms only RenderSnapshot.cs, CameraService.cs and new JumpFramingTrace.cs (134 added, 4 removed). Bounded [efpjump] trace (96 lines/session, existing general.logs gate) observes camera solve and matching Alloy world-view snapshot, requested/before/after FOV, draw FOV, viewport/aspect/projection scales, actor-relative eye changes and render eye delta. Native path reports native-unavailable; matching frame/camera does not establish identical solve invocation or final presented pixel geometry. No intended camera/jump/projection algorithm change. Codex reports Linux and Windows-targeted managed Release builds zero errors, CameraService.SelfCheck and separate off-game fixture PASS; not independently reproduced, fixture absent from diff. Windows NativeAOT and gameplay evidence pending. Temporary trace must be removed after verified correction; no player toggle. Prior accepted menu release 545eb66 remains pinned until compile/package checkpoint. #13 open, #12 remains queued; stationary wide-FOV distortion separate from jump handoff.
