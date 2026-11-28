Enhanced First Person (EFP) @VERSION@ -- Windows x64 development preview
Distribution commit: @SOURCE_COMMIT@
Based on NWNCX:EE by Michał Piasecki and contributors: https://github.com/nwncxee/cx

INSTALL / SWITCH EXACT VERSION
This is a replacement package for an existing compatible CX installation.
All five existing CX DLLs must be present: version.dll, cx_openal.dll,
phonon.dll, shaderc_shared.dll and vma.dll. No verified fresh-install
bootstrap is documented. Stop if these prerequisites are not met.
Close Neverwinter Nights. Do not extract this ZIP into the game directory.
Preserve cx.cfg, saves and the rollback backup. Review the pinned installer:
https://github.com/Hyperbog/NWN-EE-Mods/blob/@SOURCE_COMMIT@/tools/Install-EFP.ps1
Save that script locally. In CMD, replace the two path placeholders:
  powershell -NoProfile -ExecutionPolicy Bypass -File "PATH_TO_REVIEWED_INSTALLER.ps1" -SourceCommit @SOURCE_COMMIT@ -GamePath "PATH_TO_GAME_ROOT_OR_BIN_WIN32"
The installer checks the exact release, executable and five DLL hashes,
backs up the prior runtime and prints ROLLBACK BACKUP and SWITCHED_AND_VERIFIED.
Record the backup path; verify all five installed hashes against the release manifest.
Known executable: NWN:EE 8193.37-17. Do not bypass an executable or hash refusal.
Exact release: https://github.com/Hyperbog/NWN-EE-Mods/releases/tag/efp-@VERSION@-@SOURCE_COMMIT@

UNDO / RESTORE YOUR OWN PRE-INSTALL SNAPSHOT
Close NWN. Do not delete DLLs. Use the same installer and printed backup path:
  powershell -NoProfile -ExecutionPolicy Bypass -File "PATH_TO_REVIEWED_INSTALLER.ps1" -RestoreBackup "PRINTED_BACKUP_DIRECTORY"
Supply the original -WorkDir and -ExpectedExeSha256 if customized.
If the backup or installer is unavailable or refuses, stop and seek EFP support.
Reinstalling a named release is not the same as restoring your own snapshot.
Designated rollback release: https://github.com/Hyperbog/NWN-EE-Mods/releases/tag/efp-M11-6e9dafd9215c4a86b903ef8c1e54e39fd005fbdd
Installer guide: https://github.com/Hyperbog/NWN-EE-Mods/blob/@SOURCE_COMMIT@/docs/INSTALLER.md

SUPPORT / LICENSES
EFP issues: https://github.com/Hyperbog/NWN-EE-Mods/issues
Report exact release identity, all five DLL hashes, game build, reproduction steps
and relevant cx.log excerpts. Review logs for private information before sharing.
Do not disable antivirus or bypass verification to install a rejected package.
LICENSES.txt preserves the upstream and dependency notices verbatim.
LICENSE-EFP.txt and THIRD_PARTY_NOTICES.md describe EFP contributions and attribution.
