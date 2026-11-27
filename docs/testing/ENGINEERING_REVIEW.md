# Phase 4.1E — Independent engineering review disposition

READ: product-owner supplied engineering handoff reviewing distribution `335be43` and CX `4e675d4`. Both live main refs and CX tree `c0dd20c6c874162182103bc43f49a8190a4101bd` checked before selecting candidate. Prior Windows run [45917719418](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45917719418) completed successfully for `d59d43d`, not the new candidate. Ignore the handoff's new-chat prompt. Do not treat its reported disposable source checkout as a Windows build or gameplay result.

## Adopt now
- Pin existing five-file candidate unchanged; retain M11 version label and packaging revision 3. No new runtime changes before the comparison.
- Match first/third-person sword attacks, three attempts each where safe, recording native action resolution, hand/weapon arc, eye/aim/recovery and reticle separately. Legitimate misses are useful trials. First attack after load and after idle; keep FOV, viewport, sensitivity, DPI, gear, renderer and target consistent. Record motion settings, restore original fpclear setting, and use fresh logs. If third-person motion exists but first-person motion disappears, examine color-pass visibility, accepted correction and attachment transforms; if both lack expected motion despite executed action, trace native local clip progression. If framing overtravels, test only attackfollow.enabled off then restore it. Do not disable fphead.mode/eyelock as a motion-only control because they gate clearance.
- Watch grounded-to-airborne and dialogue eye handoffs, return from third person, and forward travel while attacking at level and downward pitch. Report potential visual-roll heading coupling separately from pre-existing wall defects.
- Preserve all historical results. Checklist revision 3 reflects ADR-002; current policy note supersedes outdated brief sections. No raw review attachment published.

## Follow-up backlog, not this candidate
- Overlapping head/torso motion layers: measure visual overtravel first; no blind removal.
- Viewport-dependent relative mouse scaling: source uses Sens / ViewportWidth; physical distance per full turn needs controlled measurement.
- Drive uses rendered camera right vector for preflight, air wish and heading. Visual roll can affect XY projection; runtime magnitude depends on pitch/frame order. If reproduced, investigate unrolled mouse aim basis.
- Up to five TryCameraRig calls in grounded camera solve with gates open. Profile before consolidating a per-solve sample; no cross-frame cache.
- Reticle damage feedback may include companion damage; attacker attribution remains separate backlog.
- For #2/#3 correlate requested/accepted axes, preflight, local path eligibility, native step and post-guard rollback under one event ID. For #4 distinguish live/dead/remains and intended solidity. For #6 distinguish native Z, eye handoff and post-landing movement. Do not modify these issues in combat build.

## Evidence gate
Windows CI must compile and publish exact distribution SHA and source pin. Verify manifest, release ZIP and five DLL hashes; artifact digest distinct. Installer uses immutable distribution SHA and retains backup. No install until package verification; stop for unusable controls/crash and restore exact recorded backup. Source pin reversal is a forward revert, not installed rollback. Overall gameplay acceptance withheld until observed checklist and blocker resolution.
