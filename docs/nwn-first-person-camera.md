# NWN:EE / NWNCX first-person camera — maintenance handoff

**Checkpoint prepared:** 2026-11-22. **Branch policy:** `main` only; no feature branches. **Repository:** https://github.com/nwncxee/cx. **Known original local base:** `b4b43a54ed68aa1072ce1715c0479b2fb127b5ef`. The remote `main` had advanced to `323470cbc12eb9dcacfd19718a215c127f2e83ed` at the prior verification. The local baseline and upstream `main` must not be conflated.

## Goal

First-person NWN:EE camera showing the whole player model, tracking the animated head at adjustable eye height, maintaining safe clearance near walls, and preserving combat camera motion. No permanent head/body hiding. No model or camera piercing world geometry. Preserve third-person behavior and network/gameplay position.

## Environment and important paths

- Windows; Visual Studio 2026 Community x64 Native Tools prompt.
- CX checkout: `C:\Projects\cx` (local `main`; VERIFY before editing).
- Game DLL directory: `D:\SteamLibrary\steamapps\common\Neverwinter Nights\bin\win32`.
- User settings: `%USERPROFILE%\Documents\Neverwinter Nights\cx.cfg` — never overwrite without backup. In-game `/driving` and `/fpvisibility` commands did **not** work in this configuration; do not request them.
- Active candidate package: `C:\Projects\NWN_FP_HeadEyeSync_Fix14D_C2R1` (verify locally). Prior packages and their `state/` manifests are rollback dependencies; do not delete.
- CX log: `%USERPROFILE%\Documents\Neverwinter Nights\logs\cx.log` **location to verify** (user previously uploaded `cx.log`; do not assume this exact log path).

## History and validated boundaries

- Fix 14B: improved sword attack camera clipping. Preserve attack camera logic.
- Fix 14C: read-only `Fix14CProbe` of movement/input, `StepGuard` refusals, head map. It samples movement only, **not** per-frame attack clearances. `anim=2` = WALK. Walking/running in place at obstacles had been reported; not confirmed fixed.
- Fix 14D-A: movement tether after wall guard could push camera into wall; superseded.
- Fix 14D-B1: tether calculation before wall guard and smoother recovery; visibility config reset tool optional; no permanent hiding.
- Fix 14D-C1: 13 bounded ray samples and `FirstPersonWorldGuard.LastEyeCorrection` for future visual correction, **not** a true swept sphere or capsule.
- Fix 14D-C2: head-eye tracking during jumping, attack clearance, and experimental local-player **color-pass render-only** displacement following wall correction. `fphead.up`, `fphead.forward`, `fphead.eyelock` and `fphead.modelbackmax` configurable. Non-color passes restage normal transforms. Server-authoritative position unchanged.
- Fix 14D-C2R1: gameplay code unchanged from C2; accepts CRLF/BOM for upstream renderer preflight. User reported significant improvement, mild visual jitter looking straight down while jumping, and **monk unarmed lunge still puts character in front of camera**. User's uploaded 2026-11-22 `cx.log` confirms Fix14C active and player head attachment `PMO2_HEAD001` at `head_g`, but did not capture attack geometry clearance. **Exact native build/install status must be checked using local output and manifests; do not infer from a log's version banner.**

## Current known remaining work

**Next: Fix 14D-C3 — attack-specific diagnostic and universal melee head/torso clearance.** Instrument the exact attack frame: engine animation name/id, head and upper torso world positions, final constrained camera position, eye-to-head mesh-front clearance, local render shift, wall correction, and attachments. Preserve the C2R1 renderer, Fix14B sword behavior, movement and authoritative creature positions. Diagnose monk attacks, then implement a reversible narrowly scoped correction. Avoid merely expanding animation-ID whitelists without observing actual attack behavior.

**Secondary:** slight render jitter while jumping and looking straight down; blocked walking/running-in-place state may still need separate investigation. No evidence those are resolved.

## Local checkpoint scope — audit of 2026-11-22 12:54

The main-only candidate set contains 28 first-person-related C# source changes.
Two other locally changed service files are deliberately **excluded** from the
first-person checkpoint: `managed/Services/CombatText/CombatTextService.cs` and
`managed/Services/Quickbar/QuickbarService.Cx.cs`. They stay modified/untracked
outside the commit, and a new checkout restored from the first-person commit alone
may not reproduce unrelated local changes. Keep a separate backup of those
files if their behavior matters. The audit reports 45 historical backup/original
files that also remain uncommitted. Do not clean those files from the working tree.

The corrected `NWN_FP_Main_Checkpoint_20261122_R1` checkpoint script exempts
only those two explicitly excluded services, and still refuses any other
unexpected managed source modifications. Its source review export includes both
tracked changes and untracked new source, without staging files during audit.

## Safety protocol

1. Run read-only Git audit before each new code patch; stay on **local** `main`. Do not merge/rebase/pull/fetch-reset during feature debugging. Upstream `main` has moved since the original base.
2. No `git reset --hard`, `git clean`, blanket `git add -A`, unchecked `git checkout` or replacement of game DLLs.
3. Checksum-guard source patches; keep backups and rollback manifests. Build, then install only on successful Windows native build. Close NWN during DLL installs.
4. Keep one consolidated Git checkpoint per **validated development phase**, not one commit per failed experiment. Local commits are **not** automatic GitHub updates; remote push requires separate explicit authorization and a safe remote plan.
5. Do not track `*.dll`, build outputs, `*.bak`, `cx.cfg`, `cx.log`, `state/`, patch ZIPs or generated tests/logs. The main branch may still contain intentional older upstream files; no mass deletion.
6. For a new ChatGPT chat, attach this handoff and the local `state/SESSION_HANDOFF.md` created by the checkpoint tool, plus latest `cx.log` / build error when relevant. Refer to local commit SHA; remote GitHub cannot see a local-only commit.

## Resume prompt

> Continue the NWN:EE first-person camera project from the attached handoff and Git checkpoint. Stay on **main**, preserve C2R1, and do not overwrite source, config, DLLs, backups or the existing Fix14B combat camera. Next phase is C3: per-frame monk-lunge head/torso/camera clearance diagnostics, then isolated universal attack-safe correction. First inspect the handoff and `state/SESSION_HANDOFF.md`; verify local Git status and exact package baseline. Do not assume local commits were pushed to GitHub.
