# M3 NativeAOT artifact verifier: read-only stage/game/source; writes one text report.
# PowerShell 5.1+. Does not install any DLL.
[CmdletBinding()]
param(
    [string]$StageRoot = 'C:\Projects\NWN_FP_M3_BAKED_STAGE',
    [string]$ReportPath = 'C:\Projects\M3_NativeArtifacts.txt'
)
$ErrorActionPreference = 'Stop'
$StageRoot = [IO.Path]::GetFullPath($StageRoot)
$ReportPath = [IO.Path]::GetFullPath($ReportPath)
$protected = @($StageRoot, 'C:\Projects\cx', 'C:\Projects\M1_PreM1_Runtime_Backup',
    'D:\SteamLibrary\steamapps\common\Neverwinter Nights')
foreach ($root in $protected) {
    $root = [IO.Path]::GetFullPath($root)
    $prefix = $root.TrimEnd([char[]]@([char]'\', [char]'/')) + [IO.Path]::DirectorySeparatorChar
    if ($ReportPath.Equals($root, [StringComparison]::OrdinalIgnoreCase) -or
        $ReportPath.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing report inside a protected directory: $root"
    }
}
if (Test-Path -LiteralPath $ReportPath) { throw "Report exists: $ReportPath" }
if (-not (Test-Path -LiteralPath (Split-Path -Parent $ReportPath) -PathType Container)) {
    throw 'Report destination parent is missing.'
}
$source = Join-Path $StageRoot 'managed\Services\Camera\CameraKnobs.cs'
if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "M3 source missing: $source" }
$expectedSource = '59881B5270A25F62D75EEFEF82DCE186A262B309D02D24A7563CF793D35250DC'
$sourceSha = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
if ($sourceSha -cne $expectedSource) { throw "M3 source hash mismatch: $sourceSha" }
$src = [IO.File]::ReadAllText($source)
if (-not $src.Contains('internal bool FirstPersonActive => _mode == 2 || FirstPerson.V;') -or
    -not $src.Contains('internal float ZoomLag => _mode == 2 ? 0f : LagZoom.V;')) {
    throw 'M3 built-in camera-source markers missing.'
}
$pkg = Join-Path $StageRoot 'cx-windows-x64'
$archive = Join-Path $StageRoot 'cx-windows-x64.zip'
if (-not (Test-Path -LiteralPath $pkg -PathType Container) -or
    -not (Test-Path -LiteralPath $archive -PathType Leaf)) {
    throw 'M3 package directory or ZIP missing.'
}
$files = @('version.dll', 'cx_openal.dll', 'phonon.dll', 'shaderc_shared.dll', 'vma.dll')
$expectedCompanions = [ordered]@{
    'cx_openal.dll' = '3963b06e319180700be0bcc0d027336664bb3a4975876b4a5442f10746fab5b4'
    'phonon.dll' = 'ca3dbc01dbc24492717011e80f6a51404ca143ae344ca660971d2c983f1e058d'
    'shaderc_shared.dll' = '8e13592eac48b94755e4aa4c41552b210b41ca906d0bfe35b0a6d47a97d0b7c6'
    'vma.dll' = '504da73d9a8bb5acca40d8b563d8898c536329de07a1638f8cd9dbe1126d661e'
}
function Get-Machine([string]$path) {
    $stream = [IO.File]::OpenRead($path)
    $reader = [IO.BinaryReader]::new($stream)
    try {
        if ($stream.Length -lt 64 -or $reader.ReadUInt16() -ne 0x5a4d) { throw "Invalid DOS header: $path" }
        [void]$stream.Seek(0x3c, [IO.SeekOrigin]::Begin)
        $offset = $reader.ReadInt32()
        if ($offset -lt 64 -or ($offset + 6) -gt $stream.Length) { throw "Invalid PE offset: $path" }
        [void]$stream.Seek($offset, [IO.SeekOrigin]::Begin)
        if ($reader.ReadUInt32() -ne 0x00004550) { throw "Invalid PE signature: $path" }
        return $reader.ReadUInt16()
    } finally { $reader.Dispose(); $stream.Dispose() }
}
function Get-ZipSha([object]$zip, [string]$name) {
    $matches = @($zip.Entries | Where-Object { $_.FullName -ceq $name })
    if ($matches.Count -ne 1) { throw "ZIP entry missing/duplicated: $name" }
    $stream = $matches[0].Open()
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $digest = [BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-', '').ToLowerInvariant()
        return @{ Hash = $digest; Size = $matches[0].Length }
    } finally { $stream.Dispose(); $sha.Dispose() }
}
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead($archive)
try {
    $lines = [Collections.Generic.List[string]]::new()
    $lines.Add('M3 NativeAOT package verification - READ ONLY')
    $lines.Add("Stage: $StageRoot")
    $lines.Add("M3 CameraKnobs SHA256=$sourceSha VERIFIED")
    foreach ($name in $files) {
        $path = Join-Path $pkg $name
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Package file missing: $name" }
        $machine = Get-Machine $path
        if ($machine -ne 0x8664) { throw ("Not AMD64 PE: {0} machine=0x{1:X4}" -f $name,$machine) }
        $sha = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
        $size = (Get-Item -LiteralPath $path).Length
        $packed = Get-ZipSha $zip $name
        if ($sha -cne $packed.Hash -or $size -ne $packed.Size) { throw "ZIP mismatch: $name" }
        if ($expectedCompanions.Contains($name) -and $sha -cne $expectedCompanions[$name]) {
            throw "Companion DLL changed from verified M1 baseline: $name; DO NOT INSTALL"
        }
        if ($name -ceq 'version.dll' -and
            $sha -ceq 'a3d65b433191ef652d5d03fc1ae3c6fa407f044c518c47d92111652d0079ac86') {
            throw 'M3 version.dll equals M1 version.dll; stale package suspected.'
        }
        $lines.Add("$name bytes=$size PE=AMD64 ZIP=MATCH SHA256=$sha")
    }
    foreach ($name in @('README.txt', 'LICENSES.txt')) {
        $path = Join-Path $pkg $name
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Metadata missing: $name" }
        $sha = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
        $packed = Get-ZipSha $zip $name
        if ($sha -cne $packed.Hash -or (Get-Item -LiteralPath $path).Length -ne $packed.Size) {
            throw "ZIP metadata mismatch: $name"
        }
    }
    $names = @($zip.Entries | Where-Object { $_.FullName -match '[.]dll$' })
    if ($names.Count -ne 5) { throw "Unexpected DLL count in ZIP: $($names.Count)" }
    $lines.Add('RESULT: PASS - five AMD64 PE files, ZIP hashes, metadata and M1 companion baselines verified')
    $lines.Add('No game DLL, cx.cfg, backup, or CX checkout was accessed or modified.')
    $lines.Add('NOT TESTED: M3 startup, self-checks, mouse turning, movement or animations.')
    $report = [string]::Join([Environment]::NewLine, $lines) + [Environment]::NewLine
} finally { $zip.Dispose() }
[IO.File]::WriteAllText($ReportPath, $report, [Text.UTF8Encoding]::new($false))
Write-Host $report
Write-Host "REPORT: $ReportPath"
