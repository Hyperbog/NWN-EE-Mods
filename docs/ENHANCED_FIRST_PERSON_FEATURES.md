# Enhanced First Person — Feature Reference

**Maintained description of the mod:** update this document when gameplay behavior or a feature changes. The current milestone is **Fix 14D / J4**, with the **C3C** camera safety improvements, **R3** combat reticle, and **D1–D5** diagnostics. This is a source-preserved experimental Windows build, not a stable compatibility-certified release.

## Current feature inventory

### 1. First-person camera — implemented, locally tested

- Places the camera near the local character's eye and samples the **animated head**, rather than treating every race and animation as a fixed-height static camera.
- Supports mouse-look, camera-relative navigation, character facing, and interaction through the existing NWN client systems.
- Includes camera-versus-world precautions near walls and first-person self-occlusion handling.
- Keeps the character's native collision/authoritative world position distinct from **render-only** first-person presentation changes.

**Limits:** custom skeletal rigs, appearance replacements, unusual animations and edge-case world geometry require more testing.

### 2. Reticle and combat hit indication — implemented, locally tested

- Minimal centered **dot**, instead of a large crosshair.
- The dot stays **red throughout the engine-reported combat state**, not only while hovering over a hostile target.
- On a relevant selected-target damage event, two small red side crescents, shaped approximately like **( • )**, appear around the dot and fade after about **160 ms**. The top/bottom of the imagined circle remain open.
- The former small pending-action square below the dot is removed.
- Other contextual colors and optional action feedback remain available outside the combat-red override.

**Important:** the original damage event identifies the damaged target, not the actual attacker. Damage inflicted by an ally may trigger the marker; this is *not* an independently verified personal hit confirmation.

### 3. Synchronized combat camera and character movement — implemented, locally tested

- Coordinates character facing with the first-person view, while the engine continues to choose and play ordinary combat animations.
- Tracks animated head/body motion so the camera and visible character are better aligned during attacks.
- Preserves the desired first-person visibility of hands, arms, legs, armor, shields, and weapons while keeping the central head/torso from crossing the viewpoint.
- Uses **C3C adaptive local-character core clearance** during problem poses. Clearance operates on the local rendered presentation, not on the true player position or other characters.

**Limits:** this is not a replacement combat animation system, a new hitbox model, or a guarantee that every custom attack animation will be clear.

### 4. Running, walking, and strafing — implemented, locally tested

- Camera-relative **WASD** navigation, strafing, and camera-driven character facing.
- Uses the native game **walk/run speeds** and NWN movement effects; no arbitrary sprint speed, acceleration model, or sliding physics is introduced for normal ground travel.
- Keeps the native collision, movement-update loop and authority in place. StepGuard continues to protect the existing walking path.
- **D1–D5** trace release-to-stop timing, outgoing/incoming message boundaries, and position changes. Tests located continued walking inside `CNWCCreature::WalkUpdateLocation` rather than proving that a missing network message causes the delay.

**Limits:** the engine can still advance its native walk destination briefly after input release. These diagnostics do not change that behavior.

### 5. Jumping and terrain-aware landings — implemented as J4, locally tested

- Airborne jump with controlled steering and a **world-space ballistic arc** anchored to takeoff height.
- Detects contact using validated *native walking-elevation samples* so uphill terrain can cause an earlier landing while downhill travel can continue farther below takeoff height.
- Retains the J3 safeguard against implausible native height changes and bounded unsupported falls.
- A November 22, 2026 Windows session recorded **23/23 completed jumps** (13 flat/nearly flat, 4 downhill, 6 uphill), **zero** jump safety aborts and **zero** position-correction events.

**Limits:** the ground elevation is still a **proxy**, not a full surface/collision-support query. Standing or jumping onto arbitrary furniture, crates, and decorative objects is **not implemented**.

### 6. Clipping, visibility, and safety — implemented, locally tested

- Adaptive body-camera clearance for the local player, including head/torso overlap during certain animations.
- Keeps normal character position, server-facing movement, other actor rendering, and shadows separate from the first-person body presentation.
- World/wall and walkmesh checks help avoid invalid transitions; protections are conservative and need continued testing against new area geometry.
- J4's most recent session included **75 C3C animation-clearance samples** with no recorded clearance shortfalls or rejected poses.

**Limits:** these sampled results do not prove universal collision correctness.

### 7. Diagnostics and configuration — development feature

- Log traces for camera, animation, movement release, position updates, and jump/terrain contacts.
- Configurable first-person reticle, hit marker and optional UI feedback. The `cx.cfg` file belongs to each player and is not included in source control.
- Diagnostics are for reproducing behavior; do not publish raw `cx.log` files that contain local machine or session details.


### 8. In-game CX settings — M1 source patch ready; not yet built or tested

An isolated [M1 patch](M1_CX_SETTINGS_MENU.md), with a [source-drift reconciler](../src/first-person/milestones/M1/M1_Reconcile.ps1), reorganizes the existing Driving-mode CX knob rows into a **Controls → Enhanced First Person** submenu. It exposes the current `driving.firstperson`, sensitivity, head tracking, reticle, and hit-marker values without introducing duplicate configuration keys. This does **not** alter J4 jumping, movement, animation, camera synchronization, or C3C protection. The preserved 30-file J4 source archive is unchanged. **A committed patch is not proof of a working in-game menu; local integration, Windows build, and gameplay tests remain pending.** **The isolated J4+M1 checkout passes managed C# compilation, native Windows packaging, and five-DLL ZIP/PE/SHA-256 verification. Runtime self-checks, the in-game settings menu and gameplay safety remain unverified; original CX and installed game DLLs are unchanged.**

## Dependencies, installation, and compatibility

This mod **depends on [NWNCX:EE](https://github.com/nwncxee/cx)**. The J4 mod is integrated into a matching custom NWNCX:EE runtime and is *not* a standalone NWScript module or an independent drop-in plugin. A newer upstream release may overwrite the custom `version.dll`, requiring integration and another tested build. Never combine DLLs from different builds. See [source integration](FIRST_PERSON_SOURCE.md).

The 30-file modified source overlay is published under [src/first-person/managed](../src/first-person/managed) with [integrity data](../src/first-person/SOURCE_MANIFEST.json). The separate CX project supplies the underlying engine hooks, native libraries and build system. The source overlay has been preserved and hash-checked; that does not constitute a fresh Windows build of the reconstructed source.

## Feature change history

| Milestone | Current behavior |
| --- | --- |
| **C3C** | Adaptive render-only local body/torso clearance, preserving attack limbs |
| **D1–D5** | Read-only tracing of movement release and native walking-position changes |
| **R1–R3** | Minimal dot, compact red side crescents, combat-red dot, removal of pending-action square |
| **J1–J3** | Diagnosed and guarded terrain-relative jumping and elevation discontinuities |
| **J4 — current working milestone** | Independent jump arc with validated native terrain-contact landings uphill and downhill |
| **M1 — CX settings source patch** | Driving-mode settings submenu exposed through existing knobs; patch committed, build and in-game validation pending |

## How this reference is maintained

For each gameplay change, update the **affected feature section**, its **status/limits**, and the **change-history table**. Where applicable, add a short test result and link to the relevant source commit. Keep planned features clearly distinguished from implemented features; never describe an experimental interaction as universally supported.

**Not implemented or verified as of M1:** arbitrary object/platform jumping; guaranteed compatibility with every NWN:EE model, server and future CX build; independently attributable personal hit confirmations; tested M1 in-game menu; velocity-based adjustable motion blur.