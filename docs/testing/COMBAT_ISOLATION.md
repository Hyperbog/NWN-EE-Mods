# Issue #5 — Combat regression isolation (Phase 4.1C)

READ/OBSERVED. R3 runtime is verified historical reference; J4 is the full-source proxy. New R3 archive SHA-256 `50e2b7127bb667b275e679eb974fad1db3c03a6761341fe9d7345894dbc4fa65`; CRC, 15 immutable checksums, all five R2 backup hashes pass. All 26 non-directory file contents equal previously recovered R3 archive (directory entry representation differs). No new source evidence.

## Existing M11 logs reexamined

cx.1.log has 196 C3C animation samples, none in 201–205; cx.log has 240 (cap reached), four in 201–205, no C3C rejection lines in either. IDs 201–205 are the historical helpers' selection range, not proof of every attack type or clip playback. Sanitized excerpts from cx.log (2026-11-26, -05:00):

| Line | Time | anim | requested/extra m | trusted | rejected | wall |
| --- | --- | --- | --- | --- | --- | --- |
| 3018 | 19:24:20.184 | 202 | 0.375 | 1 | 0 | 0 |
| 3038 | 19:24:22.043 | 205 | 0.309 | 1 | 0 | 0 |
| 3054 | 19:24:22.377 | 205 | 0.977 | 1 | 0 | 0 |
| 3069 | 19:24:22.712 | 205 | 0.556 | 1 | 0 | 0 |

All four printed eye coordinates identical to two decimals. These samples show native animation field enters recognized melee states and variable solver-requested displacement. Not proof of clip progress, actual rendered correction, weapon trajectory, collision or causal link to scenario 11. No exact scenario correlation. Maximum requested correction 0.977 m across second log; actual renderer acceptance not logged.

## Source-backed mechanism

M11 [CameraService 418–440](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Camera/CameraService.cs#L418-L440) fixes eye, passes zero wall correction into [UniversalEyeClearance 203–237](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Camera/UniversalEyeClearance.cs#L203-L237). The solver calculates max of projected head/torso clearance needs, returns backward translation; validated correction bypasses wall-only limit. [FirstPersonVisibility 114–168](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Services/Camera/FirstPersonVisibility.cs#L114-L168) uses identity, freshness, sequence and eye-lock gates; same shift is returned for matching body and run-root equipment. [DbStage 291–305](https://github.com/Hyperbog/cx/blob/b7895eda58cb1124e98a27109a1acc79e8544c6b/managed/Alloy/Scene/AlloyRenderer.DbStage.cs#L291-L305) adds translation only to color record, not animation transforms. Hypothesis: large changing shared translation/framing may obscure apparent attack motion; cannot establish actual animation suppression. Separate missing historical camera motion remains confirmed difference. Native attack field present does not guarantee visible playback.

## Isolation experiment (no new build)

Use installed M11, disposable save, open space, same character, weapon, target, view direction. Note initial fpclear.enabled and keep other settings unchanged. Through existing Advanced setting "Keep animated local model behind eye" (group Adaptive first-person core clearance), compare enabled vs disabled, and restore original value. Stop if severe self-model obstruction; no wall/contact/jump experiment. Fresh sessions preferred (240-line diagnostic cap); copy logs after closing NWN and before next session overwrites/rotates them. For each condition attempt three sword/melee attacks if safe, note target damage/attack execution, visible body/weapon movement and timing, head/torso obstruction, whether missing effect is camera motion, and timestamps. Keep fixed eye in both; no legacy runtime installation. If control unavailable, stop and report, do not change other settings.

If disabling correction restores synchronized visible animation, isolate render presentation and design a replacement using actual rig/attachment transforms without moving actor/eye. If no improvement, compare attack playback/pose and missing eye response with bounded read-only telemetry; if obstructed, inconclusive. Restore original settings; report results even if inconclusive. No claim of root cause or Phase 4.1D implementation yet. Preserve ADR-001. No runtime/source change.
