# Portable installer (Phase 1.3)

READ: tools/Install-EFP.ps1 accepts an exact SourceCommit (required for install), optional Version, GamePath (installation root or bin\win32), WorkDir (default %LOCALAPPDATA%\NWN_EFP_Packages), and ExpectedExeSha256 (one or more explicitly supplied 64-digit hashes; defaults to the known M11 executable). The pinned distribution commit's BUILD_PLAN.json locates the exact release and validates even an explicitly supplied Version. The downloaded manifest must agree on version, distribution commit, original base and package. Phase 2.4 READ (CI pending): for direct-source plans, the installer also requires the matching CX repository, commit and tree; historical plans without direct-source metadata retain the legacy manifest contract. Historical installers remain accessible at their original commits. Never choose latest automatically.

Steam: registry installation roots and libraryfolders.vdf, plus standard Program Files locations. GOG: game and uninstall registry entries matching Neverwinter Nights Enhanced Edition, plus a conventional directory. Discovery is best-effort and requires exactly one executable path; otherwise specify GamePath. Only absolute local Windows drive directories are supported; reparse-point directory paths are refused.

The existing five-DLL hash checks, backup, File.Replace and recovery code remain in place. Existing CX DLLs must all be present. Close the game first. Never enroll an unknown executable hash merely to bypass a refusal; compatibility must be established separately.

COMPILED: Windows fixture CI [45903157287](https://github.com/Hyperbog/NWN-EE-Mods/actions/runs/45903157287) passed on correction `e967f1f`. For a future installation, run a reviewed, commit-pinned copy of the script from ordinary CMD, for example:

    powershell -NoProfile -ExecutionPolicy Bypass -File "PATH_TO_REVIEWED_INSTALLER.ps1" -SourceCommit 7a26ce3a909f13f7c5dee2afbc022febc2616f4e

If discovery fails, append -GamePath "PATH_TO_GAME_ROOT_OR_BIN_WIN32". If a custom backup location is needed, append -WorkDir "ABSOLUTE_WORK_DIRECTORY". Record the printed ROLLBACK BACKUP directory. Expected output: SWITCHED_AND_VERIFIED and version.dll SHA256 matching STATUS.md for the selected original M11 package.

Restore using the same installer and printed backup path:

    powershell -NoProfile -ExecutionPolicy Bypass -File "PATH_TO_REVIEWED_INSTALLER.ps1" -RestoreBackup "PRINTED_BACKUP_DIRECTORY"

Supply the original -WorkDir if non-default. For a legacy backup created under C:\Projects\NWN_EFP_Packages, explicitly pass that directory as -WorkDir; restore reads the recorded game location and checks its executable and DLL hashes. Supply the original ExpectedExeSha256 allowlist if customized. Do not bypass a refusal.

CI uses disposable synthetic files and mocked network/process inputs, not an installed game. Tests cover syntax, explicit game root/custom working directory, omitted version, running-process and checksum refusal, preservation of DLLs on rejection, all five backups, restore and untouched configuration/save. Actual Steam/GOG detection and installation on the user's machine are not yet observed. The historical M11 release and original installer remain available; no installation is requested for this phase.
