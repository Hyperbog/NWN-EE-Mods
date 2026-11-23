# NWN:EE Mods

Mod development for **Neverwinter Nights: Enhanced Edition**.

## First-Person Controller & Movement

An experimental first-person experience built with [NWNCX:EE](https://github.com/nwncxee/cx). The aim is to retain NWN's characters, equipment, combat and world while making first-person movement feel natural.

**Status:** Active development — no public stable release yet. Windows testing is ongoing.

### Working in local tests

- First-person mouse-look, centered aiming reticle and camera-relative WASD movement.
- Character facing follows horizontal camera rotation; strafing remains available.
- Physical jumping with airborne momentum and directional steering.
- Subtle attack-animation camera movement and experimental head-bone tracking.
- First-person wall-clearance testing and suppression of the keyhole effect.

These are development observations, **not** a claim of universal compatibility.

### Still being developed

- Preventing the local character's head, torso, armor and other equipment from clipping into the first-person camera while keeping appropriate body and weapon visibility.
- Refining jump/camera transitions and edge-case collision behavior.
- Compatibility with different races, phenotypes, animations, builds and custom content.
- Multiplayer/host-authoritative movement behavior.

## Project documentation

- [Development status and test plan](docs/DEVELOPMENT.md)
- [Technical references](docs/REFERENCES.md)

## Downloads and installation

There is **no stable public download yet**. Tested releases, installation instructions and compatibility notes will be provided through [GitHub Releases](https://github.com/Hyperbog/NWN-EE-Mods/releases) when ready. Experimental builds should not be mistaken for validated releases.

## Development and repository policy

- **Single branch:** work is maintained on `main`; Git commits and releases record milestones.
- **Clean history:** avoid separate version folders, temporary patch ZIPs, local backups, game files and generated binaries in the source tree.
- **Modular changes:** camera, player movement, animation, visibility and collision systems are tested independently and can be disabled or rolled back.
- **Preserve the baseline:** no unverified change should replace the last working version.

This project builds on NWNCX:EE and the NWN modding community's research. It is not affiliated with Beamdog or BioWare. Third-party code and assets remain subject to their respective licenses.


## Fix 14D — validated J4 first-person controller

The **J4 development snapshot** has been tested locally with a body-aware first-person camera, native-speed WASD control, a combat-red dot with red side-crescent hit feedback, and a world-space jump arc that lands on valid uphill or downhill walkable terrain. This is still an experimental source distribution, not a standalone NWN:EE module or a stable binary release.

- [J4 features, controls and known limits](docs/FIRST_PERSON_J4.md)
- [Source integration and publication notes](docs/FIRST_PERSON_SOURCE.md)
- [First-person source overlay](src/first-person/README.md)

The [30-file annotated J4 source overlay](src/first-person/managed) is published, with an [integrity manifest](src/first-person/SOURCE_MANIFEST.json), [source map](docs/FIRST_PERSON_CODEMAP.md) and [provenance report](docs/PUBLICATION_PROVENANCE.md). It depends on a matching NWNCX:EE build; a tested public binary release has not yet been published. The development package deliberately contains no game DLLs, save files, config secrets or private logs.
