# M1 pre-install rollback backup. Copies (does NOT replace) the installed five DLLs.
# Refuses changes from the validated preflight baseline, running NWN, or existing output.
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GameBin,
    [string]$BackupDir = 'C:\Projects\M1_PreM1_Runtime_Backup',
    [string]$ReportPath = 'C:\Projects\M1_BackupVerification.txt',
    [string]$StageRoot = 'C:\Projects\NWN_FP_M1_J4_STAGE'
)
$ErrorActionPreference = 'Stop'
$GameBin = [IO.Path]::GetFullPath($GameBin)
$BackupDir = [IO.Path]::GetFullPath($BackupDir)
$ReportPath = [IO.Path]::GetFullPath($ReportPath)
$StageRoot = [IO.Path]::GetFullPath($StageRoot)
$OriginalCx = [IO.Path]::GetFullPath('C:\Projects\cx')
$sep = [IO.Path]::DirectorySeparatorChar

function Is-Under([string]$child, [string]$parent) {
    $prefix = $parent.TrimEnd([char[]]@([char]'\', [char]'/')) + $sep
    return $child.Equals($parent, [StringComparison]::OrdinalIgnoreCase) -or
           $child.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)
}
foreach ($protected in @($GameBin, $StageRoot, $OriginalCx)) {
    if ((Is-Under $BackupDir $protected) -or (Is-Under $protected $BackupDir)) {
        throw "Backup destination must be separate from the game and source trees: $protected"
    }
    if (Is-Under $ReportPath $protected) {
        throw "Report destination must be outside the game and source trees: $protected"
    }
}
if (Is-Under $ReportPath $BackupDir) {
    throw 'Report path must be outside the rollback backup directory.'
}
if (Test-Path -LiteralPath $BackupDir) {
    throw "Backup directory exists: $BackupDir (refusing overwrite)"
}
if (Test-Path -LiteralPath $ReportPath) {
    throw "Verification report exists: $ReportPath (refusing overwrite)"
}
foreach ($parent in @((Split-Path -Parent $BackupDir), (Split-Path -Parent $ReportPath))) {
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        throw "Destination parent directory does not exist: $parent"
    }
}
if (-not (Test-Path -LiteralPath $GameBin -PathType Container)) {
    throw "Game directory does not exist: $GameBin"
}
if (@(Get-Process -Name nwmain -ErrorAction SilentlyContinue).Count -ne 0) {
    throw 'NWN is running. Close the game before making the rollback backup.'
}
$exe = Join-Path $GameBin 'nwmain.exe'
if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) {
    throw "nwmain.exe not found at: $GameBin"
}
$baselineExeSha = '3b7cb1252e0edb2ce22d7971f333aade027039ae30a45b4bc64732c3e6bec73a'
$exeSha = (Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash.ToLowerInvariant()
if ($exeSha -cne $baselineExeSha) {
    throw 'nwmain.exe hash no longer matches the audited M1 preflight. Refusing stale backup assumptions.'
}
$expected = [ordered]@{
    'version.dll'        = 'b7d67f9cc95fdda93790f4e231d1f0f0066849c8a0645deef16ec5c0d5d7a3b0'
    'cx_openal.dll'      = '3963b06e319180700be0bcc0d027336664bb3a4975876b4a5442f10746fab5b4'
    'phonon.dll'         = 'ca3dbc01dbc24492717011e80f6a51404ca143ae344ca660971d2c983f1e058d'
    'shaderc_shared.dll' = '8e13592eac48b94755e4aa4c41552b210b41ca906d0bfe35b0a6d47a97d0b7c6'
    'vma.dll'            = '504da73d9a8bb5acca40d8b563d8898c536329de07a1638f8cd9dbe1126d661e'
}
# Verify everything BEFORE creating any backup directory.
foreach ($name in $expected.Keys) {
    $source = Join-Path $GameBin $name
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "Installed DLL is missing: $name"
    }
    $actual = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -cne $expected[$name]) {
        throw "Installed $name hash changed since M1 game preflight. Refusing backup."
    }
}
# All baseline hashes match. Only writes are into the fresh backup and report.
[IO.Directory]::CreateDirectory($BackupDir) | Out-Null
$lines = New-Object 'System.Collections.Generic.List[string]'
$lines.Add('M1 INSTALLED RUNTIME ROLLBACK BACKUP - VERIFIED COPIES')
$lines.Add("Game bin: $GameBin")
$lines.Add("Backup directory: $BackupDir")
$lines.Add("nwmain.exe SHA256=$exeSha (not copied)")
$lines.Add('Original source checkout, game files, stage, and cx.cfg: NOT MODIFIED.')
$lines.Add('Contents: five backed-up original DLLs only; no DLLs installed.')
$lines.Add('')
foreach ($name in $expected.Keys) {
    $src = Join-Path $GameBin $name
    $dst = Join-Path $BackupDir $name
    Copy-Item -LiteralPath $src -Destination $dst -ErrorAction Stop
    $srcHash = (Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash.ToLowerInvariant()
    $dstHash = (Get-FileHash -LiteralPath $dst -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($srcHash -cne $expected[$name] -or $dstHash -cne $expected[$name]) {
        throw "COPY HASH MISMATCH: $name; retain partial backup for inspection; game unchanged."
    }
    $bytes = (Get-Item -LiteralPath $dst).Length
    $lines.Add("$name bytes=$bytes SHA256=$dstHash VERIFIED")
    Write-Host "VERIFIED BACKUP: $name"
}
$lines.Add('')
$lines.Add('RESULT: PASS - all five original installed DLLs independently verified in backup.')
$lines.Add('This backup has not yet been restored/tested. Do not install new DLLs until rollback is approved.')
$report = [string]::Join([Environment]::NewLine, $lines) + [Environment]::NewLine
$utf8 = [Text.UTF8Encoding]::new($false)
[IO.File]::WriteAllText((Join-Path $BackupDir 'BACKUP_MANIFEST.txt'), $report, $utf8)
[IO.File]::WriteAllText($ReportPath, $report, $utf8)
Write-Host ''
Write-Host $report
Write-Host "REPORT: $ReportPath"
