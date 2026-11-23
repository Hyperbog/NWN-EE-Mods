# M1 settings-only reconciler. PowerShell 5.1+. Preview unless -Apply.
[CmdletBinding()]
param(
    [string]$CxRoot = 'C:\Projects\cx',
    [switch]$Apply
)
$ErrorActionPreference = 'Stop'
$relative = 'managed\Services\Camera\CameraKnobs.cs'
$target = Join-Path $CxRoot $relative
if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
    throw "Missing source: $target"
}
$original = [IO.File]::ReadAllBytes($target)
$sha = [Security.Cryptography.SHA256]::Create()
try { $originalHash = [BitConverter]::ToString($sha.ComputeHash($original)).Replace('-', '').ToLowerInvariant() }
finally { $sha.Dispose() }
$bom = $original.Length -ge 3 -and $original[0] -eq 239 -and $original[1] -eq 187 -and $original[2] -eq 191
$utf8 = [System.Text.UTF8Encoding]::new($false, $true)
if ($bom) { $sourceText = $utf8.GetString($original, 3, $original.Length - 3) }
else { $sourceText = $utf8.GetString($original) }
$crlf = [string]([char]13) + [string]([char]10)
$newline = if ($sourceText.Contains($crlf)) { $crlf } else { [string]([char]10) }
if (-not $sourceText.Contains('internal CameraModeKnobs(string name, string submenu, int mode,')) {
    throw 'The local CameraModeKnobs constructor does not match the J4 layout. Refusing to change it.'
}

# Exact declaration fragments; no renderer, movement, collision, or J4 jump edits.
$edits = @(
    @('submenu', 'KnobGroup.Declare(name, "Controls", submenu, master:', 'KnobGroup.Declare(name, "Controls", mode == 2 ? "Enhanced First Person" : submenu, master:'),
    @('firstperson', 'FirstPerson = G.Toggle("firstperson", "Eye-level first-person camera", false, Tier.ChatOnly,', 'FirstPerson = G.Toggle("firstperson", "Eye-level first-person camera", false, mode == 2 ? Tier.User : Tier.ChatOnly,'),
    @('offset X', 'OffsetX = G.Slider("offsetx", "Sideways offset", -10f, 10f, 0.25f, 0f, "m",', 'OffsetX = G.Slider("offsetx", "Sideways offset", -10f, 10f, 0.25f, 0f, "m", mode == 2 ? Tier.Advanced : Tier.User,'),
    @('offset Y', 'OffsetY = G.Slider("offsety", "Height offset", -10f, 10f, 0.25f, 0f, "m",', 'OffsetY = G.Slider("offsety", "Height offset", -10f, 10f, 0.25f, 0f, "m", mode == 2 ? Tier.Advanced : Tier.User,'),
    @('recenter', 'Recenter = G.Toggle("recenter", "Swing behind you as you move", moveDefault,', 'Recenter = G.Toggle("recenter", "Swing behind you as you move", moveDefault, mode == 2 ? Tier.Advanced : Tier.User,'),
    @('right drag', 'Right = G.Toggle("right", "Right-drag looks around", false,', 'Right = G.Toggle("right", "Right-drag looks around", false, mode == 2 ? Tier.Advanced : Tier.User,'),
    @('clean reticle', 'CleanReticle = G.Toggle("cleanreticle", "No target or attack squares", false, Tier.ChatOnly,', 'CleanReticle = G.Toggle("cleanreticle", "No target or attack squares", false, mode == 2 ? Tier.Advanced : Tier.ChatOnly,'),
    @('hit crescents', 'HitMarker = G.Toggle("hitmarker", "Brief side arcs on target damage", true, Tier.ChatOnly,', 'HitMarker = G.Toggle("hitmarker", "Brief side arcs on target damage", true, mode == 2 ? Tier.User : Tier.ChatOnly,'),
    @('reticle', 'Reticle = G.Toggle("reticle", "Show first-person reticle", true, Tier.ChatOnly,', 'Reticle = G.Toggle("reticle", "Show first-person reticle", true, mode == 2 ? Tier.User : Tier.ChatOnly,'),
    @('reticle style', 'ReticleStyle = G.Slider("reticlestyle", "First-person reticle style", 0, 4, 1, 1, "", Tier.ChatOnly,', 'ReticleStyle = G.Slider("reticlestyle", "First-person reticle style", 0, 4, 1, 1, "", mode == 2 ? Tier.Advanced : Tier.ChatOnly,'),
    @('head tracking', 'HeadTrack = G.Toggle("headtrack", "Head follows the crosshair", true, Tier.Advanced,', 'HeadTrack = G.Toggle("headtrack", "Head follows the crosshair", true, mode == 2 ? Tier.User : Tier.Advanced,')
)
function Count-Literal([string]$haystack, [string]$needle) {
    return [regex]::Matches($haystack, [regex]::Escape($needle)).Count
}
$missing = @()
$done = 0
foreach ($edit in $edits) {
    $old = Count-Literal $sourceText $edit[1]
    $new = Count-Literal $sourceText $edit[2]
    if ($old -eq 1 -and $new -eq 0) { continue }
    if ($old -eq 0 -and $new -eq 1) { $done++; continue }
    $missing += "$($edit[0]): old=$old new=$new"
}
$section = '        G.Section("Enhanced First Person");'
$hasSection = Count-Literal $sourceText $section
if ($hasSection -gt 1) { $missing += "first-person section: count=$hasSection" }
if ($missing.Count -gt 0 -or ($done -gt 0 -and $done -ne $edits.Count) -or
    ($done -eq $edits.Count -and $hasSection -ne 1) -or
    ($done -eq 0 -and $hasSection -ne 0)) {
    Write-Host 'M1 refused. Source differs in required declarations; no files changed.'
    foreach ($line in $missing) { Write-Host "  $line" }
    if ($done -gt 0) { Write-Host "  Already-M1 declarations: $done / $($edits.Count)" }
    Write-Host '  Inspect relevant local declarations with:'
    Write-Host '  Select-String -LiteralPath "C:\Projects\cx\managed\Services\Camera\CameraKnobs.cs" -Pattern "FirstPerson =","KnobGroup.Declare(name","HitMarker =","Reticle =","HeadTrack ="'
    exit 2
}
if ($done -eq $edits.Count) {
    Write-Host 'M1 already applied: no changes needed.'
    exit 0
}

$updated = $sourceText
foreach ($edit in $edits) {
    $updated = $updated.Replace($edit[1], $edit[2])
}
$anchor = '        FirstPerson = G.Toggle("firstperson"'
if ((Count-Literal $updated $anchor) -ne 1) {
    throw 'Cannot safely place first-person section heading.'
}
$updated = $updated.Replace($anchor, $section + $newline + $anchor)
if ($updated -eq $sourceText) { throw 'Internal error: no proposed changes.' }

# Preserve original knob names, key order, encoding and untouched source text.
$oldKeys = [regex]::Matches($sourceText, 'G\.(?:Toggle|Slider|Text|Dropdown)\("([^"]+)"')
$newKeys = [regex]::Matches($updated, 'G\.(?:Toggle|Slider|Text|Dropdown)\("([^"]+)"')
if ($oldKeys.Count -ne $newKeys.Count) { throw 'Knob declaration count changed.' }
for ($i = 0; $i -lt $oldKeys.Count; $i++) {
    if ($oldKeys[$i].Groups[1].Value -cne $newKeys[$i].Groups[1].Value) {
        throw "Knob keys changed at $i."
    }
}
Write-Host "M1 validated: $($edits.Count) narrow replacements and one section heading."
Write-Host "Original SHA-256: $originalHash"
foreach ($edit in $edits) {
    Write-Host "  $($edit[0]): $($edit[1])"
    Write-Host "           -> $($edit[2])"
}
if (-not $Apply) {
    Write-Host 'PREVIEW ONLY: no files written.'
    Write-Host 'Apply with: powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Projects\M1_Reconcile.ps1" -Apply'
    exit 0
}
$now = [IO.File]::ReadAllBytes($target)
if ([Convert]::ToBase64String($now) -cne [Convert]::ToBase64String($original)) {
    throw 'CameraKnobs.cs changed since validation; refusing to overwrite it.'
}
$backupDir = Join-Path (Split-Path -Parent $CxRoot) 'NWN_FP_M1_BACKUPS'
[IO.Directory]::CreateDirectory($backupDir) | Out-Null
$backup = Join-Path $backupDir ("CameraKnobs.preM1." + $originalHash.Substring(0,12) + "." + (Get-Date -Format 'yyyyMMdd_HHmmss_fff') + ".cs")
$payload = $utf8.GetBytes($updated)
if ($bom) {
    $outputBytes = New-Object byte[] ($payload.Length + 3)
    [Array]::Copy([byte[]](239, 187, 191), 0, $outputBytes, 0, 3)
    [Array]::Copy($payload, 0, $outputBytes, 3, $payload.Length)
} else {
    $outputBytes = $payload
}
$temp = "$target.m1tmp"
if (Test-Path -LiteralPath $temp) { throw "Temporary file already exists: $temp" }
try {
    [IO.File]::WriteAllBytes($temp, $outputBytes)
    [IO.File]::Replace($temp, $target, $backup)
} finally {
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force }
}
Write-Host "APPLIED: $relative"
Write-Host "Backup: $backup"
Write-Host 'Review with: git -C "C:\Projects\cx" diff -- managed/Services/Camera/CameraKnobs.cs'
Write-Host 'Do not install DLLs before the matching CX Windows build and gameplay checks.'
