> **Historical record — not current instructions.** See [STATUS.md](../../STATUS.md) for current evidence and the [original snapshot](https://github.com/Hyperbog/NWN-EE-Mods/blob/bc3b0b4a6c1a0624602344b0636ebdc4cc3e9763/docs/PUBLICATION_PROVENANCE.md) for links in their original context.

# Enhanced First Person — source provenance

This repository directory stores the **tested J4 local modification overlay**, not a copy of all upstream NWNCX:EE source code.

Upstream source: https://github.com/nwncxee/cx

Base local checkpoint: `2470f0d27be0a29c152456aa60222f1f4fc25c34` (based on upstream `b4b43a54ed68aa1072ce1715c0479b2fb127b5ef`).

The complete overlay has 30 C# files: 19 directly from the checkpoint (including the correct new modules), 10 from validated later source fixtures, and one D4 inbound-observer modification to the checkpoint version of HotkeyServerLinkService (the D4 file is included in the 30). Each annotated file's implementation can be verified with `src/first-person/SOURCE_MANIFEST.json`.

IMPORTANT: the later uploaded `cx.zip` contains a custom runtime with J4 markers, but its source tree differs from the working patched source in certain files. We therefore preserve recovered source from known code fixtures instead of claiming the ZIP source alone matches its runtime. The source reconstruction was verified at file hash level, not by a fresh Windows compilation or game test.

There is no standalone plugin and no permission to replace upstream NWNCX binaries automatically. The mod requires a compatible NWNCX build.
