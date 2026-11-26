# Enhanced First Person source pin

READ: Runtime development lives in [Hyperbog/cx](https://github.com/Hyperbog/cx) on main. [BUILD_PLAN.json](BUILD_PLAN.json) pins the exact source commit and tree used by distribution CI; the original foundation SHA remains provenance and the plan path remains stable for the installer.

Phase 2.6 removes the legacy overlay, source manifest and milestone files from active main. All original files remain at the [immutable pre-retirement checkpoint](https://github.com/Hyperbog/NWN-EE-Mods/tree/5aa3b7fee93d34b180398957fa6c819f36df0f91/src/first-person). The original NWNCX [license](LICENSE-NWNCX.txt) is retained. Do not replay archived milestone scripts on an active checkout or installation.

See [cloud build guide](../../docs/CLOUD_RELEASES.md), [upstream synchronization](../../docs/UPSTREAM_SYNC.md) and [legacy recovery guide](../../docs/history/LEGACY_RECONSTRUCTION.md).
