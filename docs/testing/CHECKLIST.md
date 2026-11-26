# Enhanced First Person gameplay acceptance checklist

Phase 0 candidate: M11, source commit `7a26ce3a909f13f7c5dee2afbc022febc2616f4e`.
Historical dialogue baseline: M5-rc1 (OBSERVED for dialogue only).
M11 has COMPILED and PACKAGED evidence from [run 45849781085](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45849781085); this is not gameplay evidence.

## Before testing

- Close NWN before any installation or rollback. Keep the installer-created previous-runtime backup, cx.cfg and existing saves. Use a disposable save for testing.
- Confirm installed version.dll SHA-256 matches the tested release. M11 expected: `fe81fb1b6cf5b58d920cb477000da8f4b0147cc062961af634c12be42a2cdcec`.
- Record release tag, game build, installed DLL hash, module/area, character race/model and test date. Start the game normally; no local compilation.
- Use PASS / FAIL / NOT TESTED. A PASS is an observed result, not an assumption. For a failure record the exact input sequence, expected versus actual, approximate time, and reproducibility (e.g. 2/3). Retain the relevant cx.log excerpt or screenshot; redact usernames and private paths before publishing. Stop if a crash, unusable controls or unsafe save behavior occurs.

## Scenarios

| ID | Scenario and reproduction | PASS condition |
| --- | --- | --- |
| 01 | Open EFP settings; change a noncritical setting, restart, check and restore it | Menu accessible; chosen setting persists; no accidental Action Camera disable |
| 02 | Stand idle; rotate mouse horizontally and vertically | Eye position stable relative to character; immediate view rotation; no head/torso-driven jitter |
| 03 | Walk, run, strafe both directions, reverse and use diagonals in clear space | Responsive camera-relative travel; correct visible locomotion; no unexpected turns |
| 04 | Release each movement key in clear space, including simultaneous releases | Character stops normally; no persistent walk/run animation |
| 05 | Hold forward against a wall for 10 seconds; release; wait 5 seconds | No sustained camera jitter or wall-driven displacement; walking ceases after release |
| 06 | Repeat at an oblique angle; rotate mouse while blocked | Eye remains stable; minor wall-edge clipping acceptable; no sudden pushback |
| 07 | Approach an inside corner; release, turn away, move out; repeat three times | No trapping or persistent walk; clear direction resumes movement |
| 08 | Press diagonal toward a wall, then try the unobstructed direction | Requested clear direction remains responsive; no camera movement from collision. Continuous automatic wall sliding is not yet an M11 requirement |
| 09 | Walk into a stationary NPC; hold 10 seconds, release, turn away | Stable eye; NPC not penetrated by sustained walking; stopping and escape responsive |
| 10 | Open and close NPC dialogue twice; select a reply | First-person view held, cursor usable, normal aiming restored |
| 11 | Perform melee attacks; ranged attacks if available | No collision-driven camera displacement; attacks and relevant reticle feedback work; no severe self-model obstruction |
| 12 | Equip and unequip helmet idle and following wall contact | No stuck walk/run or unexpected movement; body visibility acceptable |
| 13 | Jump on flat ground, uphill and downhill (three attempts each) | Expected jump input, trajectory and landing; no trapping or severe eye jump unrelated to character movement |
| 14 | Press Z to free and recapture cursor; use settings and chat | Cursor usable; mandatory Action Camera resumes; no movement while entering text |
| 15 | Save to a disposable slot, load it | No crash, camera and controls resume; original saves unaffected |
| 16 | Travel through an area transition | Camera and controls follow the new player location; no lingering offset or movement |

For 04–09, report the number of successful repetitions. Minor visual wall clipping alone is not a failure. A collision-induced camera pushback, persistent walking after key release, inability to move away, or sustained jitter is a failure.

## Rollback

If a blocking failure occurs, exit NWN. Use the existing Install-EFP.ps1 with the exact previous-runtime backup directory printed by the installation that is being undone:

```powershell
& "$env:TEMP\Install-EFP-M11.ps1" -RestoreBackup "PATH_PRINTED_BY_INSTALLER"
```

Replace the placeholder with the actual recorded backup path. Do not delete existing saves, cx.cfg or backups. If the installer is unavailable or refuses, stop rather than bypass its checks.

## Reporting

Report the release/hash, each scenario's PASS/FAIL/NOT TESTED, reproduction count and concise observation. The results may be submitted in chat first; a durable sanitized results document will follow. A build alone does not satisfy the gameplay acceptance criteria.
