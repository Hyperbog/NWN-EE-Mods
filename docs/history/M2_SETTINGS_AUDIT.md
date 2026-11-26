> **Historical record — not current instructions.** See [STATUS.md](../../STATUS.md) for current evidence and the [original snapshot](https://github.com/Hyperbog/NWN-EE-Mods/blob/bc3b0b4a6c1a0624602344b0636ebdc4cc3e9763/docs/M2_SETTINGS_AUDIT.md) for links in their original context.

# M2 — Enhanced First Person menu and toggle audit (source review)

**Scope:** preserved J4 + the verified M1 settings UI, no movement or renderer changes. **Observed in game:** M1 menu opens. **Not yet observed:** whether the head-aim animation changes when the setting is toggled, whether each effect works at runtime, or whether M2 builds.

| Toggle | Source reader / condition | Expected in-game test |
| --- | --- | --- |
| CX Driving camera (master) | CameraService / CameraDriveService master gates | Switch off only in a disposable save; compare stock Driving view |
| Eye-level First Person | CameraService first-person camera branch; needs Action Camera setting | With Action Camera enabled, switch eye-level view off and on |
| Move in camera direction | CameraDriveService requires camera and Drive knob | Compare forward motion in safe open area |
| Face camera while moving | CameraDriveService; **forced on** under first-person Action Camera | Test outside first-person aiming; moved to Advanced in M2 |
| Turn keys move sideways | CameraDriveService SideRun; overridden by first-person strafing | Test outside first-person aiming |
| Recenter camera | CameraService; explicitly suppressed during active first-person aiming | Test outside first-person aiming |
| Enable mouse-look | MouseLookService gate with immediate MasterChanged | Turning off disables CX captured input; standard middle drag remains |
| Right-drag camera | MouseLookService; only while action camera not capturing | Test with Action Camera off |
| Invert vertical mouse | MouseLookService TiltCamera sign in drag and action paths | Confirm look up/down reverses |
| Action Camera | MouseLookService ActionWanted/ActionChanged, subject to game/UI-focus gates | Close panel, confirm cursor capture and action-camera key |
| Aim assist | AimAssist target selection, requires an eligible nearby object | Aim slightly off a nearby creature, door or placeable |
| Cast at aimed target | Action-camera spell/feat/item targeting paths | Test safe targeted ability; ground-targeted abilities still require ground selection |
| Show aiming reticle | Crosshair draw path reads Reticle.V while action active | Confirm reticle disappears and reappears without losing interaction |
| Clean reticle | Crosshair/ActionFeedback reads CleanReticle.V | Compare target brackets and attack square when visible |
| Hit marks on target damage | ActionFeedback damage event and HitMarker.V | Attack a target and compare brief side arcs |
| Character head aims toward camera | HeadTrackService.Wanted reads HeadTrack.V AND ActionHeld AND hook armed | Verify diagnostic status, then observe visible third-person character/head; first-person view may hide head |

## Key finding: two different head systems

`driving.headtrack` controls the **character's look-at animation**, read live in `HeadTrackService.Wanted`; it does not control camera positioning. `fphead.mode` controls **camera translation from animated head-bone samples**. Because these are separate implementations, the old label `Head follows the crosshair` suggested the wrong behavior. The M2 label is `Turn character's head toward aim` and its help text explains the active-Action-Camera requirement. The Driving panel's status will also show the current head-animation knob state and cumulative drive/write counts, which can aid diagnosis but do not independently prove a visible head pose.

**Other confirmed mismatch:** `driving.face` is overridden by the first-person action movement path, regardless of its knob value. M2 moves it to Advanced for Driving and explains that it affects non-first-person movement. No movement algorithm was changed. The former Alt-to-free-cursor description contradicts the J4 source, where the optional release key is **Z**; M2 corrects that label/help (this control remains chat-only).

## M2 code change and safety

[M2_MenuClarity.patch](../src/first-person/milestones/M2/M2_MenuClarity.patch) changes only `managed/Services/Camera/CameraKnobs.cs` when applied **after** M1. It revises Driving-mode labels and help text while preserving Chase/Top Down wording; updates the Driving panel's head-aim status; and makes the ineffective-first-person `driving.face` control Advanced. It does **not** rename keys, change values/defaults, modify collision or animation hooks, or implement motion blur.

Use [M2_StageClarity.ps1](../src/first-person/milestones/M2/M2_StageClarity.ps1) to produce a separate source stage. The script refuses an existing destination, checks the M1 source markers, applies the patch with `git apply --check`, then verifies the revised labels and writes a report. The user must run it on Windows; there is no build/runtime pass yet.

**Next gate:** stage M2; run managed compilation, NativeAOT native Windows build, package checks and separate reversible installation. Do **not** replace the currently installed M1 `version.dll` until checks pass. Request `cx.log` during a test session if the head-aim toggle still appears ineffective. The subsequent MB1 motion-blur milestone remains separate from this settings repair.
