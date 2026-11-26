# Legacy reconstruction — historical recovery only

READ: Phase 2.6 removes obsolete reconstruction inputs from active main after independent M11 source equivalence and successful direct-source CI [45909430241](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45909430241). No runtime source changes.

## Immutable recovery references

- [Pre-retirement distribution checkpoint 5aa3b7f](https://github.com/Hyperbog/NWN-EE-Mods/tree/5aa3b7fee93d34b180398957fa6c819f36df0f91)
- [Original overlay, manifest and all milestones M1–M11](https://github.com/Hyperbog/NWN-EE-Mods/tree/5aa3b7fee93d34b180398957fa6c819f36df0f91/src/first-person)
- [Historical reconstruction tooling](https://github.com/Hyperbog/NWN-EE-Mods/blob/5aa3b7fee93d34b180398957fa6c819f36df0f91/tools/cloud_build.py)
- [Last pre-direct-build distribution checkpoint](https://github.com/Hyperbog/NWN-EE-Mods/tree/0d15330f87eda8ca94c10ba49027f7ced2b8f10a)
- [Original installed M11 release](https://github.com/Hyperbog/NWN-EE-Mods/releases/tag/efp-M11-7a26ce3a909f13f7c5dee2afbc022febc2616f4e)
- [First direct-source M11 release](https://github.com/Hyperbog/NWN-EE-Mods/releases/tag/efp-M11-9bea65c9d83b700d68269592c840a03fb087e3f5)
- [Equivalent CX source](https://github.com/Hyperbog/cx/commit/b7895eda58cb1124e98a27109a1acc79e8544c6b), tree `13e2a83859a4e711e90931df5c9a21ec5e2eeae1`.

The legacy branch `cx-build-base` remains pinned to `2470f0d27be0a29c152456aa60222f1f4fc25c34` to preserve historical checkout and rollback commands. It is not an active development branch or a direct CI input. Historical releases, tags, and installer scripts remain accessible at their original commits; old installer plan URLs are commit-pinned. No archived scripts are current deployment instructions.

## Recovery policy

If the retirement commit needs rollback, inspect main and use a reviewed git revert of that commit (no force-push). This restores the previous direct workflow with optional reconstruction tools. For a full historical build, inspect the pre-direct checkpoint in an isolated checkout; its workflow and source inputs remain available. Do not restore archived files merely to implement new EFP changes. Do not delete historic refs or releases. Keep the installed M11 and its rollback backup untouched.

Active build guidance: [CLOUD_RELEASES.md](../CLOUD_RELEASES.md). Current evidence: [STATUS.md](../../STATUS.md).
