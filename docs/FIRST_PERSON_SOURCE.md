# Source publication and integration

## Repository layout

The commented source overlay is located under `src/first-person/managed/`, mirroring source paths in NWNCX's own `managed/` directory. It is **not** a standalone `.csproj` and cannot compile independently of [NWNCX:EE](https://github.com/nwncxee/cx).

The source package comprises 29 previously checkpointed first-person changes plus later C3C/D4/D5/R3/J4 additions. It must be exported from the **validated local working checkout** to preserve the exact combination of fixes. The existing `src/diagnostics/` probes are earlier historical experiments and should not be confused with the integrated J4 code.

The complete 30-file J4 source overlay is tracked under `src/first-person/managed/`, reconstructed from the pinned local checkpoint and exact C3C/D4/D5/R3/J4 fixtures. See `SOURCE_MANIFEST.json` for per-file implementation hashes. It still requires a compatible NWNCX:EE build.

## Safety rules for source publication

1. Publish only allowlisted source and documentation. **Never** add `version.dll`, `cx_openal.dll`, `cx.cfg`, raw `cx.log`, `state/` manifests, generated DLLs, or local backup files.
2. The local upstream checkout `C:\\Projects\\cx` must not be reset, cleaned, rebased, pulled, or pushed to `nwncxee/cx` merely to publish this mod.
3. Use a **separate clone** of `Hyperbog/NWN-EE-Mods` for the publication commit. Pull only the source files verified against the local J4 fixtures and previous checkpoint. Update `main` by normal fast-forward push, never `--force`.
4. Each public source file receives a detailed explanatory C# comment header. The publisher verifies the original implementation before inserting comments; comments do not alter the executable statements.
5. Retain NWNCX's MIT copyright and license notice for incorporated upstream source. No claim is made that all third-party assets or Neverwinter Nights game files are covered by that license.

## Building and testing

To build the mod, use the matching NWNCX checkout and Visual Studio 2026 x64 Native Tools Command Prompt. The published overlay alone is not sufficient: all upstream project dependencies, native hooks, build-specific symbol tables, and libraries are still required. Do not copy a new `version.dll` into the game until a complete Windows build succeeds and runtime backups are verified. All changes to a working installation should remain reversible.

### Key architecture notes

- `CameraService` and `UniversalEyeClearance`: first-person eye/body clearance, gated to the local player; no authoritative movement changes.
- `FirstPersonVisibility` and Alloy renderer hooks: local-player color-pass composition, not permanent hiding of the model.
- `MouseLookService`, `CameraKnobs`, `ActionFeedback`: first-person input, dot-reticle settings, combat coloring, and selected-target damage flash.
- `CameraDriveService`, `StepGuardService`, `HotkeyServerLinkService`: input/release tracing and engine/native walking observations; existing movement and StepGuard correction behavior preserved.
- `JumpPositionService` and `JumpWalkBridgeService`: airborne trajectory and post-native-walk application of Z; native ground updates and abnormal-height guards remain essential.

No complete J4 DLL release is currently published.