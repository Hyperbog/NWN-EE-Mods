# Build a separate M2 settings-clarity source stage from the verified M1 working tree.
# This never changes the installed game, original CX checkout or source M1 stage.
[CmdletBinding()]
param(
    [string]$M1Root = 'C:\Projects\NWN_FP_M1_J4_STAGE',
    [string]$M2Root = 'C:\Projects\NWN_FP_M2_SETTINGS_STAGE',
    [string]$PatchPath = 'C:\Projects\M2_MenuClarity.patch',
    [string]$ReportPath = 'C:\Projects\M2_SettingsStageReport.txt'
)
$ErrorActionPreference = 'Stop'
foreach ($name in @('M1Root','M2Root','PatchPath','ReportPath')) {
    Set-Variable -Name $name -Value ([IO.Path]::GetFullPath((Get-Variable -Name $name -ValueOnly)))
}
if (-not (Test-Path -LiteralPath $M1Root -PathType Container)) { throw 'M1 stage is missing.' }
if (Test-Path -LiteralPath $M2Root) { throw 'Refusing to replace an existing M2 stage.' }
if (Test-Path -LiteralPath $ReportPath) { throw 'Refusing to replace an existing M2 report.' }
if (-not (Test-Path -LiteralPath $PatchPath -PathType Leaf)) { throw "Patch missing: $PatchPath" }
$original = [IO.Path]::GetFullPath('C:\Projects\cx')
$game = [IO.Path]::GetFullPath('D:\SteamLibrary\steamapps\common\Neverwinter Nights')
if ($M2Root -eq $M1Root -or $M2Root -eq $original -or $M2Root.StartsWith($game + '\', [StringComparison]::OrdinalIgnoreCase)) {
    throw 'M2 destination must be a separate staging directory.'
}
$sourceCamera = Join-Path $M1Root 'managed\Services\Camera\CameraKnobs.cs'
if (-not (Test-Path -LiteralPath $sourceCamera -PathType Leaf)) { throw 'M1 camera source missing.' }
$camera = [IO.File]::ReadAllText($sourceCamera)
if (-not $camera.Contains('mode == 2 ? "Enhanced First Person" : submenu') -or
    -not $camera.Contains('mode == 2 ? Tier.User : Tier.ChatOnly')) {
    throw 'M1 patched camera source was not found; refusing to stage unrelated source.'
}
$exclude = @(
    (Join-Path $M1Root 'build'),
    (Join-Path $M1Root 'cx-windows-x64'),
    (Join-Path $M1Root 'managed\bin'),
    (Join-Path $M1Root 'managed\obj')
)
& robocopy.exe $M1Root $M2Root /E /R:0 /W:0 /XD $exclude /XF 'cx-windows-x64.zip' 'build-managed-win.log' | Out-Null
$rc = $LASTEXITCODE
if ($rc -ge 8) { throw "Robocopy failed with exit code $rc; stage may be partial." }
& git.exe -C $M2Root apply --check $PatchPath
if ($LASTEXITCODE -ne 0) { throw 'Git patch preflight failed; M2 stage left for inspection.' }
& git.exe -C $M2Root apply $PatchPath
if ($LASTEXITCODE -ne 0) { throw 'Git patch application failed; M2 stage left for inspection.' }
$targetCamera = Join-Path $M2Root 'managed\Services\Camera\CameraKnobs.cs'
$now = [IO.File]::ReadAllText($targetCamera)
if (-not $now.Contains("Turn character's head toward aim") -or
    -not $now.Contains('HeadTrackService.Fragment') -or
    -not $now.Contains('mode == 2 ? Tier.Advanced : Tier.User')) {
    throw 'M2 source content did not meet the expected settings audit markers.'
}
$hash = (Get-FileHash -LiteralPath $targetCamera -Algorithm SHA256).Hash
$report = "M2 SETTINGS STAGE: PASS" + [Environment]::NewLine +
    "M1 source: $M1Root" + [Environment]::NewLine +
    "M2 stage: $M2Root" + [Environment]::NewLine +
    "M2 CameraKnobs SHA256: $hash" + [Environment]::NewLine +
    "Original CX, M1 stage, game DLLs, and cx.cfg: NOT MODIFIED" + [Environment]::NewLine +
    "Managed build, NativeAOT build, runtime and menu behavior: NOT TESTED" + [Environment]::NewLine
[IO.File]::WriteAllText($ReportPath, $report, [Text.UTF8Encoding]::new($false))
Write-Host $report
Write-Host "REPORT: $ReportPath"
