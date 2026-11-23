# M1 read-only game installation preflight for the verified NativeAOT package.
# Never copies, renames, installs, deletes, or modifies any DLL or game file.
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GameBin,
    [string]$StageRoot = 'C:\Projects\NWN_FP_M1_J4_STAGE',
    [string]$ReportPath = 'C:\Projects\M1_GamePreflight.txt'
)
$ErrorActionPreference = 'Stop'
$GameBin = [IO.Path]::GetFullPath($GameBin)
$StageRoot = [IO.Path]::GetFullPath($StageRoot)
$ReportPath = [IO.Path]::GetFullPath($ReportPath)
$sep = [IO.Path]::DirectorySeparatorChar
function Is-Under([string]$child, [string]$parent) {
    $prefix = $parent.TrimEnd([char[]]@([char]'\', [char]'/')) + $sep
    return $child.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase) -or
           $child.Equals($parent, [StringComparison]::OrdinalIgnoreCase)
}
if (Is-Under $GameBin $StageRoot -or Is-Under $GameBin 'C:\Projects\cx') {
    throw 'GameBin must point to the real, separately installed game, not CX source or staging.'
}
if (Is-Under $ReportPath $StageRoot -or Is-Under $ReportPath $GameBin) {
    throw 'Report output must be outside both the source stage and game installation.'
}
if (Test-Path -LiteralPath $ReportPath) {
    throw "Refusing to overwrite existing report: $ReportPath"
}
if (-not (Test-Path -LiteralPath (Split-Path -Parent $ReportPath) -PathType Container)) {
    throw 'Report output parent directory does not exist.'
}
$exe = Join-Path $GameBin 'nwmain.exe'
if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) {
    throw "Expected nwmain.exe directly inside GameBin: $GameBin"
}
$running = @(Get-Process -Name 'nwmain' -ErrorAction SilentlyContinue)
if ($running.Count -ne 0) {
    throw 'nwmain.exe is currently running. Close the game before planning any DLL change.'
}
$packageDir = Join-Path $StageRoot 'cx-windows-x64'
$expected = [ordered]@{
    'version.dll'        = 'a3d65b433191ef652d5d03fc1ae3c6fa407f044c518c47d92111652d0079ac86'
    'cx_openal.dll'      = '3963b06e319180700be0bcc0d027336664bb3a4975876b4a5442f10746fab5b4'
    'phonon.dll'         = 'ca3dbc01dbc24492717011e80f6a51404ca143ae344ca660971d2c983f1e058d'
    'shaderc_shared.dll' = '8e13592eac48b94755e4aa4c41552b210b41ca906d0bfe35b0a6d47a97d0b7c6'
    'vma.dll'            = '504da73d9a8bb5acca40d8b563d8898c536329de07a1638f8cd9dbe1126d661e'
}
$lines = New-Object 'System.Collections.Generic.List[string]'
$lines.Add('M1 GAME PREFLIGHT — READ ONLY; NO INSTALLATION OR BACKUP MADE')
$lines.Add("Game bin: $GameBin")
$lines.Add("Stage: $StageRoot")
$lines.Add('Process nwmain.exe: NOT RUNNING')
$lines.Add("nwmain.exe SHA256=$((Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash.ToLowerInvariant())")
$lines.Add('')
$lines.Add('STAGED PACKAGE (must equal the verified M1 package):')
foreach ($name in $expected.Keys) {
    $p = Join-Path $packageDir $name
    if (-not (Test-Path -LiteralPath $p -PathType Leaf)) {
        throw "Missing staged package DLL: $name"
    }
    $h = (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($h -cne $expected[$name]) {
        throw "Staged DLL changed since M1 native artifact verification: $name"
    }
    $lines.Add("$name SHA256=$h  VERIFIED")
}
$lines.Add('')
$lines.Add('CURRENT INSTALLED GAME BIN DLLS (read only):')
foreach ($name in $expected.Keys) {
    $p = Join-Path $GameBin $name
    if (-not (Test-Path -LiteralPath $p -PathType Leaf)) {
        $lines.Add("$name MISSING")
        continue
    }
    $h = (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLowerInvariant()
    $size = (Get-Item -LiteralPath $p).Length
    $comparison = if ($h -ceq $expected[$name]) { 'SAME_AS_M1' } else { 'DIFFERENT_FROM_M1' }
    $lines.Add("$name bytes=$size SHA256=$h $comparison")
}
$lines.Add('')
$lines.Add('NO SOURCE, GAME, DLL, OR CONFIG FILES WERE CHANGED.')
$lines.Add('Next: verify full rollback snapshot before any reversible test installation.')
$report = [string]::Join([Environment]::NewLine, $lines)
[IO.File]::WriteAllText($ReportPath, $report + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))
Write-Host $report
Write-Host ''
Write-Host "REPORT: $ReportPath"
