# NWN:EE Mods — Enhanced First Person

**Enhanced First Person** is an experimental, body-aware first-person camera and movement modification for **Neverwinter Nights: Enhanced Edition (NWN:EE)**, built on [NWNCX:EE](https://github.com/nwncxee/cx). It aims to make exploration and combat feel more natural in first person **without changing NWN's native character speeds, equipment, animation system, or server authority**.

**Current preserved milestone:** Fix 14D / **J4 World-Space Jump** with C3C camera clearance and R3 combat reticle. Windows gameplay-tested in a limited set of scenarios. **Development preview, not a broadly verified stable release.**

## What Enhanced First Person does

| Feature | Description |
| --- | --- |
| **First-person camera** | Mouse-look from the character's animated head/eye viewpoint, with camera-relative navigation and careful positioning near walls. |
| **Reticle** | Small central dot; stays **red in combat**. Two small **red side crescents** flash for approximately 160 ms when the selected target's damage event is reported. The small pending-action square beneath the dot is removed. |
| **Synchronized combat movement and animations** | Camera and player facing respond to combat and attack animation. The mod attempts to keep visible hands, arms, legs, shields, and weapons while keeping the head/torso from crossing the eye position. |
| **Running, walking, and strafing** | Camera-relative WASD input with native game walk/run rates and existing speed modifiers, including gameplay effects. No artificial slippery momentum or speed boost is added to ordinary ground movement. |
| **Jumping** | J4 world-space jump trajectory with airborne steering; landing responds to **walkable uphill and downhill terrain** instead of forcing the takeoff elevation. |
| **Clipping safeguards** | Adaptive first-person local-model clearance and world/wall safety logic. Body adjustments are **render-only**, not authoritative character repositioning. |
| **Combat feedback and diagnostics** | Existing action/hit feedback plus bounded camera, movement, position, and jump diagnostics used during development. |

See the [full feature reference and update history](docs/ENHANCED_FIRST_PERSON_FEATURES.md) for behavior, implementation boundaries, and what is *not* supported.

## Known limits

- **Requires NWNCX:EE.** Enhanced First Person is currently integrated into a **matching custom CX build**, not an independent plugin. Installing/updating stock CX may replace the modified `version.dll` and disable the mod. Do not mix DLLs from different CX builds.
- Landing on **arbitrary crates, furniture, and non-walkable placeables is not implemented**. Visually elevated objects are not necessarily valid supporting surfaces.
- The hit crescents use selected-target damage feedback, **not verified attacker attribution**; party-member damage may also trigger them.
- Tested behavior does **not** establish compatibility with every race, custom model, tileset, multiplayer server, or future NWNCX/game build. Native collision and server authority still apply.

## Source code

The [30-file annotated J4 source overlay](src/first-person/managed) is preserved here, with a [source integrity manifest](src/first-person/SOURCE_MANIFEST.json) and a [reconstruction/provenance report](docs/PUBLICATION_PROVENANCE.md). These files are **modifications to NWNCX:EE**, not an independently buildable C# project.

- [Feature reference and ongoing change history](docs/ENHANCED_FIRST_PERSON_FEATURES.md)
- [J4 technical behavior and test results](docs/FIRST_PERSON_J4.md)
- [Source code map](docs/FIRST_PERSON_CODEMAP.md)
- [Source integration, build and safety notes](docs/FIRST_PERSON_SOURCE.md)
- [M1 Enhanced First Person CX settings patch — unbuilt / untested](docs/M1_CX_SETTINGS_MENU.md)
- [Historical development and diagnostics](docs/DEVELOPMENT.md)
- [Technical references](docs/REFERENCES.md)

## Downloads and installation

There is **no stable public binary release yet**. Once a matching runtime has been packaged and verified for distribution, downloads and install instructions will appear under [GitHub Releases](https://github.com/Hyperbog/NWN-EE-Mods/releases).

**Never replace an existing CX installation without backing up all five runtime DLLs**: `version.dll`, `cx_openal.dll`, `phonon.dll`, `shaderc_shared.dll`, and `vma.dll`. Local configuration is normally in `Documents\Neverwinter Nights\cx.cfg`. Preserve saved games and existing configuration.

## Development policy

- Maintain **one documented feature reference**; update it whenever a feature is added, removed, or changed. Include the milestone and whether it has been tested.
- Preserve a last-known-working source and runtime before changes. Keep debugging patches and temporary installation archives out of the main source tree.
- Separate NWNCX upstream changes from Enhanced First Person's mod code. Revalidate hooks, build-specific offsets and the complete DLL set after upstream updates.
- Preserve source attribution and third-party license notices; do not publish local saves, user configuration, logs, or backup state.

This project depends on the [NWNCX:EE upstream project](https://github.com/nwncxee/cx) and community engine research. It is not affiliated with Beamdog or BioWare.