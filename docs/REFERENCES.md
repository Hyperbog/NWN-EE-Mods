# Technical references

This is a **curated index**, not a mirror of upstream code or copyrighted game assets.

## Engine integration

- [NWNCX:EE](https://github.com/nwncxee/cx) — existing client hook, camera, Alloy rendering, collision and animation-service architecture.
- [NWNX:EE](https://nwnxee.github.io/unified/) — separate server-side extensions, important when evaluating authoritative movement.

## Models, rigs and animation

- [NWN Wiki: Models](https://nwn.wiki/spaces/NWN1/pages/38175602/Models) — model format, hierarchy, skinmesh and tool references.
- [NWN Wiki: Model Special Nodes](https://nwn.wiki/spaces/NWN1/pages/38176272/Model%2BSpecial%2BNodes) — head/torso/hand nodes and special attachments.
- [NWN Wiki: Part-Based Models (Creatures)](https://nwn.wiki/spaces/NWN1/pages/49447501/Part-Based%2BModels%2BCreatures) — dynamic player body and equipment assembly.
- [NWN Wiki: Animations](https://nwn.wiki/pages/viewpage.action?pageId=138346514) — animation conventions, supermodels and inheritance.

## Tools and reproducibility

- [neverwinter.nim](https://github.com/niv/neverwinter.nim) — inspect/extract game resources and automate content checks.
- [NWN Model Web Viewer](https://github.com/dunahan/nwn_mdl_webviewer) — useful reference for model inspection; verify supported assets before adopting.
- [Nasher](https://github.com/squattingmonk/nasher) — source-controlled NWN module/content workflows.
- [NWN Wiki: Content Load Order](https://nwn.wiki/spaces/NWN1/pages/38174823/Content%2BLoad%2BOrder) — diagnose overrides, HAKs and asset priority.

## Historical manuals

Two manuals inform the project's model/animation research but **predate Enhanced Edition**; their engine-version-specific claims require separate verification:

- *Neverwinter Nights Custom Content Guide v3.0* — heads and helmets (pp. 94–95), creature animations (pp. 109–125), skin and bones (pp. 128–132), dynamic character models (pp. 136–141).
- *The Builders Project's Aurora Toolset Manual v1.06* — creature appearance (pp. 62–63), creature events, and equipment creation.

The manuals are research references, **not included in this repository**. Do not upload or redistribute third-party PDFs without permission.

## Project practice

Prefer inspecting real in-game part IDs, current game assets and the pinned upstream implementation to assuming every playable appearance has the same head node or mesh boundaries.
