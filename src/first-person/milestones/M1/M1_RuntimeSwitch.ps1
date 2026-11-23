# M1 guarded runtime switch. Replaces ONLY version.dll; never modifies cfg or source.
# Requires exact preflight and backup SHA-256 hashes. Windows PowerShell 5.1+.
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Status', 'InstallM1', 'RestoreOriginal')]
    [string]$Action,
    [string]$GameBin = 'D:\SteamLibrary\steamapps\common\Neverwinter Nights\bin\win32',
    [string]$StageRoot = 'C:\Projects\NWN_FP_M1_J4_STAGE',
    [string]$BackupDir = 'C:\Projects\M1_PreM1_Runtime_Backup',
    [string]$ReportPath = ''
)
$ErrorActionPreference = 'Stop'
$GameBin = [IO.Path]::GetFullPath($GameBin)
$StageRoot = [IO.Path]::GetFullPath($StageRoot)
$BackupDir = [IO.Path]::GetFullPath($BackupDir)
$CxRoot = [IO.Path]::GetFullPath('C:\Projects\cx')
if (-not $ReportPath) { $ReportPath = "C:\Projects\M1_RuntimeSwitch_$Action.txt" }
$ReportPath = [IO.Path]::GetFullPath($ReportPath)
$sep = [IO.Path]::DirectorySeparatorChar
function Within([string]$child, [string]$parent) {
    $prefix = $parent.TrimEnd([char[]]@([char]'\', [char]'/')) + $sep
    return $child.Equals($parent, [StringComparison]::OrdinalIgnoreCase) -or
           $child.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)
}
foreach ($other in @($StageRoot, $BackupDir, $CxRoot)) {
    if ((Within $GameBin $other) -or (Within $other $GameBin)) {
        throw "Game, source, stage, and backup directories must be separate: $other"
    }
    if (Within $ReportPath $other) { throw "Report cannot be under a source or backup path: $other" }
}
if (Within $ReportPath $GameBin) { throw 'Report path cannot be inside the game directory.' }
if (Test-Path -LiteralPath $ReportPath) {
    throw "Report already exists; refusing overwrite: $ReportPath"
}
if (-not (Test-Path -LiteralPath (Split-Path -Parent $ReportPath) -PathType Container)) {
    throw 'Report parent directory does not exist.'
}
$exe = Join-Path $GameBin 'nwmain.exe'
$exeSha = '3b7cb1252e0edb2ce22d7971f333aade027039ae30a45b4bc64732c3e6bec73a'
$old = [ordered]@{
    'version.dll' = 'b7d67f9cc95fdda93790f4e231d1f0f0066849c8a0645deef16ec5c0d5d7a3b0'
    'cx_openal.dll' = '3963b06e319180700be0bcc0d027336664bb3a4975876b4a5442f10746fab5b4'
    'phonon.dll' = 'ca3dbc01dbc24492717011e80f6a51404ca143ae344ca660971d2c983f1e058d'
    'shaderc_shared.dll' = '8e13592eac48b94755e4aa4c41552b210b41ca906d0bfe35b0a6d47a97d0b7c6'
    'vma.dll' = '504da73d9a8bb5acca40d8b563d8898c536329de07a1638f8cd9dbe1126d661e'
}
$new = [ordered]@{
    'version.dll' = 'a3d65b433191ef652d5d03fc1ae3c6fa407f044c518c47d92111652d0079ac86'
    'cx_openal.dll' = '3963b06e319180700be0bcc0d027336664bb3a4975876b4a5442f10746fab5b4'
    'phonon.dll' = 'ca3dbc01dbc24492717011e80f6a51404ca143ae344ca660971d2c983f1e058d'
    'shaderc_shared.dll' = '8e13592eac48b94755e4aa4c41552b210b41ca906d0bfe35b0a6d47a97d0b7c6'
    'vma.dll' = '504da73d9a8bb5acca40d8b563d8898c536329de07a1638f8cd9dbe1126d661e'
}
function Assert-Hash([string]$path, [string]$expected) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "File missing: $path" }
    $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -cne $expected) {
        throw "Checksum mismatch: $path; expected=$expected; actual=$actual"
    }
}
Assert-Hash $exe $exeSha
foreach ($name in $old.Keys) {
    Assert-Hash (Join-Path $BackupDir $name) $old[$name]
    if ($name -cne 'version.dll') {
        Assert-Hash (Join-Path $GameBin $name) $old[$name]
    }
}
if ($Action -eq 'InstallM1') {
    foreach ($name in $new.Keys) {
        Assert-Hash (Join-Path (Join-Path $StageRoot 'cx-windows-x64') $name) $new[$name]
    }
}
$target = Join-Path $GameBin 'version.dll'
if (-not (Test-Path -LiteralPath $target -PathType Leaf)) { throw 'Installed version.dll missing.' }
$current = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant()
if ($current -cne $old['version.dll'] -and $current -cne $new['version.dll']) {
    throw "Unrecognized installed version.dll checksum: $current. Refusing to overwrite an unknown build."
}
$desired = if ($Action -eq 'InstallM1') { $new['version.dll'] } else { $old['version.dll'] }
$before = $current
$state = 'READ_ONLY'
if ($Action -ne 'Status') {
    if (@(Get-Process -Name 'nwmain' -ErrorAction SilentlyContinue).Count -ne 0) {
        throw 'NWN is running. Exit the game before switching its runtime.'
    }
    if ($current -ceq $desired) {
        $state = 'ALREADY_DESIRED_VERSION'
    } else {
        $source = if ($Action -eq 'InstallM1') {
            Join-Path (Join-Path $StageRoot 'cx-windows-x64') 'version.dll'
        } else {
            Join-Path $BackupDir 'version.dll'
        }
        Assert-Hash $source $desired
        # Stage a verified copy on the SAME volume as the game; replace only version.dll.
        $temp = Join-Path $GameBin ('.m1-' + [guid]::NewGuid().ToString('N') + '.tmp')
        try {
            [IO.File]::Copy($source, $temp, $false)
            Assert-Hash $temp $desired
            [IO.File]::Replace($temp, $target, $null)
            Assert-Hash $target $desired
            $state = 'SWITCHED_AND_VERIFIED'
        } finally {
            if (Test-Path -LiteralPath $temp -PathType Leaf) {
                Remove-Item -LiteralPath $temp -Force
            }
        }
    }
}
$final = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant()
if ($Action -ne 'Status' -and $final -cne $desired) {
    throw 'Installed version.dll is not the intended build after switching.'
}
Assert-Hash $exe $exeSha
foreach ($name in $old.Keys) {
    Assert-Hash (Join-Path $BackupDir $name) $old[$name]
    if ($name -cne 'version.dll') {
        Assert-Hash (Join-Path $GameBin $name) $old[$name]
    }
}
$lines = @(
    'M1 GUARDED RUNTIME SWITCH',
    "Action: $Action",
    "Result: $state",
    "Game bin: $GameBin",
    "Original backup: $BackupDir",
    "nwmain.exe SHA256=$exeSha",
    "version.dll before SHA256=$before",
    "version.dll after SHA256=$final",
    'Four companion DLLs and five original backup DLLs: hashes verified',
    'cx.cfg, CX source files, and game executable: not modified',
    'Runtime startup and CX self-checks: NOT VERIFIED'
)
$output = [string]::Join([Environment]::NewLine, $lines) + [Environment]::NewLine
[IO.File]::WriteAllText($ReportPath, $output, [Text.UTF8Encoding]::new($false))
Write-Host $output
Write-Host "REPORT: $ReportPath"
