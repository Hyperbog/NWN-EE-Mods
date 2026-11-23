# Enhanced First Person M1 - read-only source collection.
# Copies ONLY the 14 files flagged DIFFERENT by M1_SourceAudit.txt.
# Does not write to the CX checkout, change Git, or include DLLs/config/logs.
[CmdletBinding()]
param(
    [string]$CxRoot = 'C:\Projects\cx',
    [string]$OutZip = 'C:\Projects\M1_DriftSources.zip'
)
$ErrorActionPreference = 'Stop'
$CxRoot = [IO.Path]::GetFullPath($CxRoot)
$OutZip = [IO.Path]::GetFullPath($OutZip)
if (-not (Test-Path -LiteralPath $CxRoot -PathType Container)) {
    throw "Missing CX source directory: $CxRoot"
}
$sourcePrefix = $CxRoot.TrimEnd([char[]]@([char]'\', [char]'/')) + [IO.Path]::DirectorySeparatorChar
if ($OutZip.StartsWith($sourcePrefix, [StringComparison]::OrdinalIgnoreCase) -or $OutZip -ceq $CxRoot) {
    throw 'Archive output must be outside the CX source checkout.'
}
if (Test-Path -LiteralPath $OutZip) {
    throw "Refusing to overwrite existing archive: $OutZip"
}
if (-not (Test-Path -LiteralPath (Split-Path -Parent $OutZip) -PathType Container)) {
    throw 'Archive output directory does not exist.'
}

$relativePaths = @(
    'managed/Alloy/AlloyRenderer.Batches.cs',
    'managed/Alloy/Db/DbKeyhole.cs',
    'managed/Alloy/Scene/AlloyRenderer.DbPass.cs',
    'managed/Alloy/Scene/AlloyRenderer.DbStage.cs',
    'managed/Framework/ClientApi.cs',
    'managed/Services/Anim/PoseService.cs',
    'managed/Services/Camera/ActionFeedback.cs',
    'managed/Services/Camera/CameraDriveService.cs',
    'managed/Services/Camera/CameraKnobs.cs',
    'managed/Services/Camera/CameraService.cs',
    'managed/Services/Camera/HeadTrackService.cs',
    'managed/Services/Camera/MouseLookService.cs',
    'managed/Services/Camera/StepGuardService.cs',
    'managed/Services/Hotkeys/HotkeyServerLinkService.cs'
)
if ($relativePaths.Count -ne 14) { throw 'Expected exactly 14 source paths.' }
foreach ($relative in $relativePaths) {
    $full = Join-Path $CxRoot ($relative.Replace('/', [string][IO.Path]::DirectorySeparatorChar))
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
        throw "Required source file is missing: $relative"
    }
}

Add-Type -AssemblyName System.IO.Compression
$archiveStream = $null
$archive = $null
$completed = $false
try {
    $archiveStream = [IO.File]::Open($OutZip, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
    $archive = [IO.Compression.ZipArchive]::new($archiveStream, [IO.Compression.ZipArchiveMode]::Create, $false)
    foreach ($relative in $relativePaths) {
        $full = Join-Path $CxRoot ($relative.Replace('/', [string][IO.Path]::DirectorySeparatorChar))
        $entry = $archive.CreateEntry($relative, [IO.Compression.CompressionLevel]::Optimal)
        $input = $null
        $output = $null
        try {
            $input = [IO.File]::OpenRead($full)
            $output = $entry.Open()
            $input.CopyTo($output)
        } finally {
            if ($output -ne $null) { $output.Dispose() }
            if ($input -ne $null) { $input.Dispose() }
        }
        Write-Host "COPIED: $relative"
    }
    $completed = $true
} finally {
    if ($archive -ne $null) { $archive.Dispose() }
    if ($archiveStream -ne $null) { $archiveStream.Dispose() }
    if (-not $completed -and (Test-Path -LiteralPath $OutZip -PathType Leaf)) {
        Remove-Item -LiteralPath $OutZip -Force
    }
}
Write-Host "ARCHIVE: $OutZip"
Write-Host 'Contents: exactly 14 differing C# source files (no logs, config, DLLs, or working Git objects).'
Write-Host 'Upload this ZIP in the development conversation; do not commit the ZIP to GitHub.'
