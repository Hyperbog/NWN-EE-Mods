# Portable installer (Phase 1.3)

## Current install or exact-version rollback

[Designated Phase 13C.2 rollback release](https://github.com/Hyperbog/NWN-EE-Mods/releases/tag/efp-M11-6e9dafd9215c4a86b903ef8c1e54e39fd005fbdd) — distribution `6e9dafd9215c4a86b903ef8c1e54e39fd005fbdd`, CX `0ae674ac58cd0cf2579d8f99d832f52fa04968e7`, tree `17c95a8484b1825aa8bd8296ede84508f410581b`. NWN:EE 8193.37-17, nwmain.exe SHA-256 `3b7cb1252e0edb2ce22d7971f333aade027039ae30a45b4bc64732c3e6bec73a`; ZIP SHA-256 `73509022036694eff19fd97f9b0919daaf5417668cd100ce2683dd3ff9b2f421`; version.dll SHA-256 `24f9d257199b6673395c2f5c2b5a1e7653bee9fc42e70c071a31d1bfe73600b6`.

Prerequisite: all five existing CX DLLs must be present (`version.dll`, `cx_openal.dll`, `phonon.dll`, `shaderc_shared.dll`, `vma.dll`). A fresh game without CX cannot use this replacement installer; no separately verified bootstrap is documented here. Stop and obtain a reviewed bootstrap procedure rather than copying or deleting DLLs. Do not follow the upstream README embedded in the published ZIP.

READ: tools/Install-EFP.ps1 accepts an exact SourceCommit (required for install), optional Version, GamePath (installation root or bin\win32), WorkDir (default %LOCALAPPDATA%\NWN_EFP_Packages), and ExpectedExeSha256 (one or more explicitly supplied 64-digit hashes; defaults to the known M11 executable). The pinned distribution commit's BUILD_PLAN.json locates the exact release and validates even an explicitly supplied Version. The downloaded manifest must agree on version, distribution commit, original base and package. Phase 2.4 (COMPILED: [45909430241](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45909430241)): for direct-source plans, the installer also requires the matching CX repository, commit and tree; historical plans without direct-source metadata retain the legacy manifest contract. Historical installers remain accessible at their original commits. Never choose latest automatically.

Steam: registry installation roots and libraryfolders.vdf, plus standard Program Files locations. GOG: game and uninstall registry entries matching Neverwinter Nights Enhanced Edition, plus a conventional directory. Discovery is best-effort and requires exactly one executable path; otherwise specify GamePath. Only absolute local Windows drive directories are supported; reparse-point directory paths are refused.

The existing five-DLL hash checks, backup, File.Replace and recovery code remain in place. Existing CX DLLs must all be present. Close the game first. Never enroll an unknown executable hash merely to bypass a refusal; compatibility must be established separately.

COMPILED: Windows fixture CI [45903157287](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45903157287) passed on correction `e967f1f`. Save and review the [commit-pinned portable installer](https://github.com/Hyperbog/NWN-EE-Mods/blob/1d56d9c4d8fac89134bed93da28604ce1a000296/tools/Install-EFP.ps1) as `Install-EFP.ps1`. From ordinary CMD, substitute your actual absolute paths:

    powershell -NoProfile -ExecutionPolicy Bypass -File "PATH_TO_REVIEWED_INSTALLER.ps1" -SourceCommit 6e9dafd9215c4a86b903ef8c1e54e39fd005fbdd -GamePath "PATH_TO_GAME_ROOT_OR_BIN_WIN32"

If a custom backup location is needed, append -WorkDir "ABSOLUTE_WORK_DIRECTORY". Record the printed ROLLBACK BACKUP directory. Expected output: SWITCHED_AND_VERIFIED and version.dll SHA-256 matching the current identity above. Verify all five installed DLLs against the exact release manifest. This reinstalls the named published package; it does not restore your personal pre-install runtime.

## Restore your own pre-install snapshot

To undo a switch, close NWN and use the same installer that created your snapshot and its printed backup path. Do not delete runtime DLLs:

    powershell -NoProfile -ExecutionPolicy Bypass -File "PATH_TO_REVIEWED_INSTALLER.ps1" -RestoreBackup "PRINTED_BACKUP_DIRECTORY"

Supply the original -WorkDir if non-default. For a legacy backup created under C:\Projects\NWN_EFP_Packages, explicitly pass that directory as -WorkDir; restore reads the recorded game location and checks its executable and DLL hashes. Supply the original ExpectedExeSha256 allowlist if customized. Do not bypass a refusal.

CI uses disposable synthetic files and mocked network/process inputs, not an installed game. Tests cover syntax, explicit game root/custom working directory, omitted version, running-process and checksum refusal, preservation of DLLs on rejection, all five backups, restore and untouched configuration/save. Actual Steam/GOG detection and installation on the user's machine are not yet observed. The historical M11 release and original installer remain available; no installation is requested for this phase.
