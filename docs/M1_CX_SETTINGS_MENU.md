# M1 — Enhanced First Person in CX settings

**Status (2026-11-22): staged J4+M1 managed and NativeAOT builds passed; all five packaged AMD64 DLLs verified by SHA-256 against the ZIP. Game installation preflight, CX self-checks and in-game testing pending.** This is a settings-panel-only integration for the preserved J4 custom CX lineage. It is not a new DLL or a motion-blur implementation.

## What it changes

The existing **Driving** camera group's CX settings submenu moves under **Controls → Enhanced First Person** in `/settings`. It remains the `driving` knob group; existing `driving.*` keys, chat commands and values in `cx.cfg` are unchanged. Chase and Top-down stay in their existing submenus.

The Driving submenu exposes the following controls as ordinary rows: eye-level first person (`driving.firstperson`), mouse sensitivity (`driving.sens`), head tracking (`driving.headtrack`), reticle visibility (`driving.reticle`), and side-crescent target-damage feedback (`driving.hitmarker`). Action camera (`driving.action`) and the existing CX camera master (`driving.enabled`) remain separately controllable; all three switches are needed for the normal first-person path. Reticle style and clean-reticle presentation become **Advanced** rows.

Four existing Driving-only controls—camera offset X/Y, recenter, and right-drag—move to **Advanced**. This keeps the CX panel's maximum of 14 default-visible rows. No defaults, values, key names, input handlers, renderer passes, native collision, J4 jump, C3C clearance, or combat animations are modified.

## Applying to the matching development checkout

1. Keep your last-known-working J4 source, five-DLL runtime, and `cx.cfg` backed up. **Do not merge newer upstream CX DLLs into J4.** This patch is not a replacement for your working local changes.
2. Obtain [the M1 patch](../src/first-person/milestones/M1/EnhancedFirstPerson_CX_Settings.patch) and save it locally, e.g. `C:\Projects\M1_CX_Settings.patch`.
3. In a Git Bash or a Visual Studio command prompt with Git available, check before applying:

```cmd
git -C "C:\Projects\cx" apply --check "C:\Projects\M1_CX_Settings.patch"
git -C "C:\Projects\cx" apply "C:\Projects\M1_CX_Settings.patch"
git -C "C:\Projects\cx" diff -- managed/Services/Camera/CameraKnobs.cs
```

**If `--check` fails, stop:** your local source has drifted from the published J4 overlay. Do not use `--reject`, `--3way`, reset, clean, or force. Preserve your local audit and modified files for reconciliation. The published 30-file J4 archive and its SHA-256 manifest must remain untouched.

To undo this exact patch (only if the patched file has not been edited further):

```cmd
git -C "C:\Projects\cx" apply -R --check "C:\Projects\M1_CX_Settings.patch"
git -C "C:\Projects\cx" apply -R "C:\Projects\M1_CX_Settings.patch"
```

## Verification before installation

Build only against the compatible pinned CX source. Run CX's settings self-check: registry uniqueness, 14 User rows in the Driving submenu, and correct persisted legacy keys. Verify `/settings` visibility, toggle and slider persistence after restart, action-camera prerequisites, Chase/Top-down stability, disabled/re-enabled options, walk/run, blocked-wall contact, jumping, attacks and helmet swaps. Do not replace any game DLLs before a successful matching Windows build and reversible installer test.

**Not yet verified:** build, actual UI rendering, game persistence, input-release behavior, and runtime regression results. MB1 adjustable motion blur is a separate future milestone.


## M1 local source reconciliation (2026-11-22)

A local `git apply --check` reported **hunk failure at CameraKnobs.cs:142**. This establishes a mismatch between the published J4 source and the developer's live `C:\Projects\cx` checkout, not a failed build. The check did not change the local file. Do not apply with relaxed hunk context or replace the local source with the archived copy.

Use the [M1 source reconciler](../src/first-person/milestones/M1/M1_Reconcile.ps1) for a declaration-only alternative. Download it into `C:\Projects\M1_Reconcile.ps1`. First run with **no arguments** to preview and validate all 11 expected declarations. It refuses mismatched or partially applied declarations; only after a successful preview, use `-Apply`. Application saves the previous source bytes in `C:\Projects\NWN_FP_M1_BACKUPS` before writing. Unrelated local edits are preserved, and the originally published archive and its manifest are not changed.

The reconciler has been checked against the published J4 source, **not** the inaccessible Windows working tree. Build/runtime verification remains pending. If validation reports missing or ambiguous declarations, stop and collect the local matching source lines; do not force a patch.

## M1 local reconciler refusal — source audit required (2026-11-22)

The actual read-only PowerShell preview returned:

```text
M1 refused. Source differs in required declarations; no files changed.
  firstperson: old=0 new=0
  clean reticle: old=0 new=0
  hit crescents: old=0 new=0
  reticle: old=0 new=0
  reticle style: old=0 new=0
```

These five camera and reticle declaration fragments do **not** appear in upstream CX's pinned `b4b43a54` `CameraKnobs.cs`, but do appear in the published J4 overlay. The local working checkout may therefore be from an older or divergent source stage; this is a *hypothesis*, not yet a full source comparison. An installed J4 runtime does not establish that today's on-disk C# matches that build.

**Do not use `M1_Reconcile.ps1 -Apply`, the original M1 patch, or relaxed / forced patching.** Instead, inspect the actual local file and Git status. In Visual Studio Developer Command Prompt run:

```cmd
git -C "C:\Projects\cx" status --short -- managed/Services/Camera/CameraKnobs.cs
git -C "C:\Projects\cx" rev-parse --short HEAD
powershell -NoProfile -Command "Select-String -LiteralPath 'C:\Projects\cx\managed\Services\Camera\CameraKnobs.cs' -Pattern 'FirstPerson','Reticle','HitMarker','CleanReticle','HeadTrack','KnobGroup.Declare','Action = G.Toggle','CameraModeKnobs' | Select-Object LineNumber,Line | Format-Table -Wrap -AutoSize"
```

Send the command output and preferably the unmodified `C:\Projects\cx\managed\Services\Camera\CameraKnobs.cs` file through the development conversation. Treat the published J4 overlay as **reference evidence**, not as an instruction to replace the local file. Do not share private `cx.cfg`, `cx.log`, or runtime DLLs. Rebuild and in-game verification remain blocked until an exact-source reconciliation.

## Verified uploaded CameraKnobs.cs and full working-tree audit (2026-11-22)

The uploaded working-copy file's Git blob ID is **e5f3ffdca4ac8d13f02b2c6630a65143537b9f11**. This matches **exactly** the current upstream CX file at revision **66fcc820ef746fdf155b81309f63e7da52d5c865**, not the pinned J4 overlay. The file's SHA-256 is **ef6c5794fcbcd2a2e7b6710b6f552149b72dd455dfc0e825edbdede55a65665e**. The earlier suggestion that the file was simply older source was wrong. It is a *newer upstream camera configuration file* without J4's first-person, reticle and hit-crescent declarations.

This does not establish whether other working-copy files still contain J4. The repository's complete J4 overlay was constructed from the original pin plus post-checkpoint fixtures, whereas a newer upstream CX module may have materially different APIs. Never paste or overwrite J4 CameraKnobs.cs into this current upstream file without checking dependency compatibility.

### Read-only source-lineage audit

Use [M1_SourceAudit.ps1](../src/first-person/milestones/M1/M1_SourceAudit.ps1) rather than applying M1. Download this script outside the checkout, and run it from Visual Studio Developer Command Prompt:

```cmd
powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/main/src/first-person/milestones/M1/M1_SourceAudit.ps1' -OutFile 'C:\\Projects\\M1_SourceAudit.ps1'"
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\\Projects\\M1_SourceAudit.ps1"
```

The audit reads the current `HEAD`, branch, tracked modified-source count and **30 source-file SHA-256 comparisons** against the J4 manifest. It makes **no writes to the CX source or Git repository**. It writes only `C:\\Projects\\M1_SourceAudit.txt` outside the checkout; send that report in the development conversation. The script's PowerShell runtime and local Windows compatibility are not yet independently tested.

**M1 status: blocked pending full source comparison.** The previous M1 patch and reconciler are retained as artifacts with explicit application refusal; do not run `-Apply` against the newer upstream file. Keep existing DLLs, local source edits, configuration and all game assets unchanged.

See [M1 audit results](M1_SOURCE_AUDIT_RESULTS.md) for the verified 16/14/0 split, the exact 14-file upstream comparison, and the separate-stage source reconstruction instructions. The live CX checkout is not to be modified until a reproducible build is verified.

The stage is ready for the [managed compile-only gate](M1_SOURCE_AUDIT_RESULTS.md#next-gate-managed-compile-only-test). The original live CX checkout has not been overwritten.
