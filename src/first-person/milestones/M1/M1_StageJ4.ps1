# M1 J4 staging builder: creates a separate source checkout, never changes C:\Projects\cx.
# Downloads 30 pinned J4 C# overlay files and verifies manifest SHA-256 before overlay.
# Applies committed M1 menu patch only inside the staging checkout. No DLL installation.
[CmdletBinding()]
param(
    [string]$SourceRoot = 'C:\Projects\cx',
    [string]$StageRoot = 'C:\Projects\NWN_FP_M1_J4_STAGE'
)
$ErrorActionPreference = 'Stop'
$SourceRoot = [IO.Path]::GetFullPath($SourceRoot)
$StageRoot = [IO.Path]::GetFullPath($StageRoot)
$sep = [string][IO.Path]::DirectorySeparatorChar
$from = $SourceRoot.TrimEnd([char[]]@([char]'\', [char]'/')) + $sep
$to = $StageRoot.TrimEnd([char[]]@([char]'\', [char]'/')) + $sep
if ($StageRoot -eq $SourceRoot -or
    $StageRoot.StartsWith($from, [StringComparison]::OrdinalIgnoreCase) -or
    $SourceRoot.StartsWith($to, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Stage and source must be separate non-nested paths.'
}
if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) {
    throw "CX source checkout not found: $SourceRoot"
}
if (Test-Path -LiteralPath $StageRoot) {
    throw "Refusing to overwrite any existing staging location: $StageRoot"
}
if (-not (Test-Path -LiteralPath (Split-Path -Parent $StageRoot) -PathType Container)) {
    throw 'The staging parent directory does not exist.'
}

# The audited local Git checkpoint. Clone ignores its 1123 uncommitted modified source entries.
$checkpoint = '2470f0d27be0a29c152456aa60222f1f4fc25c34'
$head = (& git -C $SourceRoot rev-parse --verify HEAD)
if ($LASTEXITCODE -ne 0 -or "$head".Trim() -cne $checkpoint) {
    throw "Expected pinned local HEAD $checkpoint; got $head. No staging changes made."
}
Write-Host "Cloning committed checkpoint $checkpoint into separate staging folder..."
& git clone --local --no-hardlinks -- $SourceRoot $StageRoot
if ($LASTEXITCODE -ne 0) { throw 'Local clone failed; source checkout was not modified.' }
$stageHead = (& git -C $StageRoot rev-parse --verify HEAD)
if ($LASTEXITCODE -ne 0 -or "$stageHead".Trim() -cne $checkpoint) {
    throw 'Staging clone HEAD does not match the pinned checkpoint.'
}

# Pin both provenance and M1 patch to immutable public GitHub commits.
$publication = '796a222cec17dfefe455ae42c8a97e149c33cee4'
$patchCommit = '55bb687c0116fadd6ddb6ff6a56dae5a034df318'
$publicRoot = 'https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/'
$cache = Join-Path $StageRoot '.m1_download'
[IO.Directory]::CreateDirectory($cache) | Out-Null
$manifestPath = Join-Path $cache 'SOURCE_MANIFEST.json'
$patchPath = Join-Path $cache 'M1_CX_Settings.patch'
Invoke-WebRequest -UseBasicParsing -Uri ($publicRoot + $publication + '/src/first-person/SOURCE_MANIFEST.json') -OutFile $manifestPath
$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$entries = @($manifest.modules.PSObject.Properties | Sort-Object Name)
if ($entries.Count -ne 30) {
    throw "Expected 30 J4 source files, found $($entries.Count)."
}
$utf8 = [Text.UTF8Encoding]::new($false, $true)
$crlf = [string]([char]13) + [string]([char]10)
$lf = [string]([char]10)
function Hash-NormalizedFile([string]$file) {
    $bytes = [IO.File]::ReadAllBytes($file)
    $text = $utf8.GetString($bytes)
    if ($text.Length -gt 0 -and $text[0] -eq [char]0xFEFF) { $text = $text.Substring(1) }
    $text = $text.Replace($crlf, $lf)
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        return [BitConverter]::ToString($sha.ComputeHash($utf8.GetBytes($text))).Replace('-', '').ToLowerInvariant()
    } finally { $sha.Dispose() }
}
$downloads = @()
$idx = 0
foreach ($item in $entries) {
    $relative = [string]$item.Name
    if ($relative -notmatch '^managed/[A-Za-z0-9_./-]+[.]cs$' -or $relative.Contains('..')) {
        throw "Unsafe manifest source path: $relative"
    }
    $expected = [string]$item.Value.published_sha256_lf
    if ($expected -notmatch '^[a-f0-9]{64}$') { throw "Invalid manifest checksum: $relative" }
    $tmp = Join-Path $cache ('j4_{0:D2}.cs' -f $idx)
    $uri = $publicRoot + $publication + '/src/first-person/' + $relative
    Invoke-WebRequest -UseBasicParsing -Uri $uri -OutFile $tmp
    $actual = Hash-NormalizedFile $tmp
    if ($actual -cne $expected) {
        throw "J4 checksum mismatch for $relative; refusing all source replacement."
    }
    $downloads += [pscustomobject]@{ Relative = $relative; Temp = $tmp }
    Write-Host "VERIFIED J4: $relative"
    $idx++
}

# All 30 downloads passed checksums; write ONLY into the separate staging clone.
foreach ($item in $downloads) {
    $dest = Join-Path $StageRoot ($item.Relative.Replace('/', $sep))
    $dir = Split-Path -Parent $dest
    [IO.Directory]::CreateDirectory($dir) | Out-Null
    Copy-Item -LiteralPath $item.Temp -Destination $dest -Force
}
Invoke-WebRequest -UseBasicParsing -Uri ($publicRoot + $patchCommit + '/src/first-person/milestones/M1/EnhancedFirstPerson_CX_Settings.patch') -OutFile $patchPath
& git -C $StageRoot apply --check $patchPath
if ($LASTEXITCODE -ne 0) { throw 'M1 patch does not apply to staged J4; no original source touched.' }
& git -C $StageRoot apply $patchPath
if ($LASTEXITCODE -ne 0) { throw 'M1 patch failed in isolated staging checkout.' }
$camera = Join-Path $StageRoot 'managed\Services\Camera\CameraKnobs.cs'
$text = [IO.File]::ReadAllText($camera, $utf8)
if (-not $text.Contains('mode == 2 ? "Enhanced First Person" : submenu') -or
    -not $text.Contains('mode == 2 ? Tier.User : Tier.ChatOnly')) {
    throw 'M1 staged source validation failed.'
}
Remove-Item -LiteralPath $cache -Recurse -Force
Write-Host ''
Write-Host 'STAGING READY: source overlay and M1 patch validated in a SEPARATE checkout.'
Write-Host "Stage: $StageRoot"
Write-Host 'Original CX checkout, installed DLLs, and cx.cfg: unchanged.'
Write-Host 'Build and in-game behavior: NOT TESTED. Do not install DLLs from this stage.'
Write-Host 'Inspect: git -C "C:\Projects\NWN_FP_M1_J4_STAGE" status --short'
