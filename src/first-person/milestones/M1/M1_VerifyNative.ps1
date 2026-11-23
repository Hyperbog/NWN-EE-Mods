# M1 NativeAOT package verification. Read-only for source/build/game directories.
# Writes only a text report outside the staging checkout. Windows PowerShell 5.1+.
[CmdletBinding()]
param(
    [string]$StageRoot = 'C:\Projects\NWN_FP_M1_J4_STAGE',
    [string]$ReportPath = 'C:\Projects\M1_NativeArtifacts.txt'
)
$ErrorActionPreference = 'Stop'
$StageRoot = [IO.Path]::GetFullPath($StageRoot)
$ReportPath = [IO.Path]::GetFullPath($ReportPath)
$stagePrefix = $StageRoot.TrimEnd([char[]]@([char]'\', [char]'/')) + [IO.Path]::DirectorySeparatorChar
if ($ReportPath.StartsWith($stagePrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Report must be outside the staging checkout.'
}
if (Test-Path -LiteralPath $ReportPath) {
    throw "Refusing to replace an existing report: $ReportPath"
}
if (-not (Test-Path -LiteralPath (Split-Path -Parent $ReportPath) -PathType Container)) {
    throw 'Report destination directory does not exist.'
}
$files = @('version.dll', 'cx_openal.dll', 'phonon.dll', 'shaderc_shared.dll', 'vma.dll')
$packageDir = Join-Path $StageRoot 'cx-windows-x64'
$zipPath = Join-Path $StageRoot 'cx-windows-x64.zip'
$sourcePath = Join-Path $StageRoot 'managed\Services\Camera\CameraKnobs.cs'
if (-not (Test-Path -LiteralPath $packageDir -PathType Container)) {
    throw "Missing NativeAOT package directory: $packageDir"
}
if (-not (Test-Path -LiteralPath $zipPath -PathType Leaf)) {
    throw "Missing NativeAOT package ZIP: $zipPath"
}
if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
    throw "Missing staged M1 camera source: $sourcePath"
}
$camera = [IO.File]::ReadAllText($sourcePath)
if (-not $camera.Contains('mode == 2 ? "Enhanced First Person" : submenu') -or
    -not $camera.Contains('mode == 2 ? Tier.User : Tier.ChatOnly')) {
    throw 'Staged M1 settings changes are not present in CameraKnobs.cs.'
}
foreach ($name in @('README.txt','LICENSES.txt')) {
    if (-not (Test-Path -LiteralPath (Join-Path $packageDir $name) -PathType Leaf)) {
        throw "Missing package metadata: $name"
    }
}
foreach ($name in $files) {
    if (-not (Test-Path -LiteralPath (Join-Path $packageDir $name) -PathType Leaf)) {
        throw "Missing package DLL: $name"
    }
}

function Get-PeMachine([string]$path) {
    $stream = [IO.File]::OpenRead($path)
    $reader = [IO.BinaryReader]::new($stream)
    try {
        if ($stream.Length -lt 64 -or $reader.ReadUInt16() -ne 0x5a4d) {
            throw "Invalid DOS header: $path"
        }
        [void]$stream.Seek(0x3c, [IO.SeekOrigin]::Begin)
        $offset = $reader.ReadInt32()
        if ($offset -lt 64 -or ($offset + 6) -gt $stream.Length) {
            throw "Invalid PE offset: $path"
        }
        [void]$stream.Seek($offset, [IO.SeekOrigin]::Begin)
        if ($reader.ReadUInt32() -ne 0x00004550) {
            throw "Invalid PE signature: $path"
        }
        return $reader.ReadUInt16()
    } finally {
        $reader.Dispose()
        $stream.Dispose()
    }
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead($zipPath)
try {
    $lines = New-Object 'System.Collections.Generic.List[string]'
    $lines.Add('M1 Windows NativeAOT artifact verification')
    $lines.Add('No installation performed. Original CX checkout and game files not accessed.')
    $lines.Add("Stage: $StageRoot")
    $lines.Add('Staged M1 camera settings markers: present')
    $lines.Add("Package ZIP: $zipPath")
    foreach ($name in $files) {
        $local = Join-Path $packageDir $name
        $machine = Get-PeMachine $local
        if ($machine -ne 0x8664) {
            throw ("Expected AMD64 PE machine 0x8664 for {0}, got 0x{1:X4}" -f $name, $machine)
        }
        $h = (Get-FileHash -LiteralPath $local -Algorithm SHA256).Hash.ToLowerInvariant()
        $size = (Get-Item -LiteralPath $local).Length
        $matches = @($zip.Entries | Where-Object { $_.FullName -ceq $name })
        if ($matches.Count -ne 1) {
            throw "Expected exactly one matching ZIP entry for $name; found $($matches.Count)."
        }
        $input = $matches[0].Open()
        $hash = [Security.Cryptography.SHA256]::Create()
        try {
            $zipHash = [BitConverter]::ToString($hash.ComputeHash($input)).Replace('-', '').ToLowerInvariant()
        } finally {
            $input.Dispose()
            $hash.Dispose()
        }
        if ($zipHash -cne $h -or $matches[0].Length -ne $size) {
            throw "ZIP and folder DLL mismatch: $name"
        }
        $lines.Add(("{0}  bytes={1}  PE=AMD64  ZIP=MATCH  SHA256={2}" -f $name, $size, $h))
    }
    $zipNames = @($zip.Entries | Where-Object { $_.FullName -match '[.]dll$' })
    if ($zipNames.Count -ne $files.Count) {
        throw "Unexpected DLL count in package ZIP: $($zipNames.Count)"
    }
    $lines.Add('VERIFIED: 5 AMD64 PE DLLs, exact matching SHA-256 in ZIP and package folder.')
    $lines.Add('NOT VERIFIED: CX runtime self-checks, game startup, menu behavior, movement/animation regressions.')
    $report = [string]::Join([Environment]::NewLine, $lines)
} finally {
    $zip.Dispose()
}
[IO.File]::WriteAllText($ReportPath, $report + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))
Write-Host $report
Write-Host ''
Write-Host "REPORT: $ReportPath"
