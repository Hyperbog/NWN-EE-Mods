# M1 guarded runtime switch Fix1: named-backup File.Replace (null backup fails on this Windows).
# Supports a scratch-only SelfTest before any live change; never changes cx.cfg or CX source.
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('SelfTest', 'Status', 'InstallM1', 'RestoreOriginal')]
    [string]$Action,
    [string]$ReportPath = ''
)
$ErrorActionPreference = 'Stop'
$game = 'D:\SteamLibrary\steamapps\common\Neverwinter Nights\bin\win32'
$stage = 'C:\Projects\NWN_FP_M1_J4_STAGE\cx-windows-x64'
$original = 'C:\Projects\M1_PreM1_Runtime_Backup'
$scratch = 'D:\SteamLibrary\steamapps\common\M1_RuntimeSwitchFix1_SelfTest'
$exeHash = '3b7cb1252e0edb2ce22d7971f333aade027039ae30a45b4bc64732c3e6bec73a'
$old = [ordered]@{
    'version.dll' = 'b7d67f9cc95fdda93790f4e231d1f0f0066849c8a0645deef16ec5c0d5d7a3b0'
    'cx_openal.dll' = '3963b06e319180700be0bcc0d027336664bb3a4975876b4a5442f10746fab5b4'
    'phonon.dll' = 'ca3dbc01dbc24492717011e80f6a51404ca143ae344ca660971d2c983f1e058d'
    'shaderc_shared.dll' = '8e13592eac48b94755e4aa4c41552b210b41ca906d0bfe35b0a6d47a97d0b7c6'
    'vma.dll' = '504da73d9a8bb5acca40d8b563d8898c536329de07a1638f8cd9dbe1126d661e'
}
$newVersion = 'a3d65b433191ef652d5d03fc1ae3c6fa407f044c518c47d92111652d0079ac86'
if (-not $ReportPath) { $ReportPath = "C:\Projects\M1_RuntimeSwitchFix1_$Action.txt" }
$ReportPath = [IO.Path]::GetFullPath($ReportPath)
$sep = [string][IO.Path]::DirectorySeparatorChar
function Under([string]$candidate, [string]$parent) {
    $parent = [IO.Path]::GetFullPath($parent)
    $candidate = [IO.Path]::GetFullPath($candidate)
    $prefix = $parent.TrimEnd([char[]]@([char]'\', [char]'/')) + $sep
    return $candidate.Equals($parent, [StringComparison]::OrdinalIgnoreCase) -or
           $candidate.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)
}
foreach ($p in @($game, $stage, $original, 'C:\Projects\cx', $scratch)) {
    if (Under $ReportPath $p) { throw "Report must not be inside protected or scratch tree: $p" }
}
if (Test-Path -LiteralPath $ReportPath) { throw "Report already exists: $ReportPath" }
if (-not (Test-Path -LiteralPath (Split-Path -Parent $ReportPath) -PathType Container)) {
    throw 'Report output directory does not exist.'
}
function Assert-Hash([string]$path, [string]$hash) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing file: $path" }
    $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -cne $hash) {
        throw "SHA256 mismatch: $path expected=$hash actual=$actual"
    }
}
function Write-Report([string[]]$lines) {
    $body = [string]::Join([Environment]::NewLine, $lines) + [Environment]::NewLine
    [IO.File]::WriteAllText($ReportPath, $body, [Text.UTF8Encoding]::new($false))
    Write-Host $body
    Write-Host "REPORT: $ReportPath"
}
if ($Action -eq 'SelfTest') {
    if (Under $scratch $game -or Under $scratch $stage -or Under $scratch $original) {
        throw 'Scratch overlaps a protected path.'
    }
    if (Test-Path -LiteralPath $scratch) { throw "Scratch already exists: $scratch" }
    if (-not (Test-Path -LiteralPath (Split-Path -Parent $scratch) -PathType Container)) {
        throw 'Scratch parent directory missing.'
    }
    [void][IO.Directory]::CreateDirectory($scratch)
    $source = Join-Path $scratch 'new.tmp'
    $target = Join-Path $scratch 'old.dll'
    $backup = Join-Path $scratch 'old.named-backup.bak'
    [IO.File]::WriteAllText($source, 'M1-FIX1-NEW')
    [IO.File]::WriteAllText($target, 'M1-FIX1-OLD')
    [IO.File]::Replace($source, $target, $backup)
    if ([IO.File]::ReadAllText($target) -cne 'M1-FIX1-NEW' -or
        [IO.File]::ReadAllText($backup) -cne 'M1-FIX1-OLD') {
        throw 'SelfTest named-backup replacement content verification failed.'
    }
    Write-Report @(
        'M1 RUNTIME SWITCH FIX1 SELFTEST: PASS',
        "Scratch: $scratch",
        'Named-backup File.Replace succeeded; destination and backup contents verified.',
        'No game executable, DLL, backup, source or cx.cfg files accessed or modified.',
        'Live installation and runtime startup: NOT TESTED.'
    )
    return
}
# Live-path preflight. The original backup and all four companion DLLs are pinned.
Assert-Hash (Join-Path $game 'nwmain.exe') $exeHash
foreach ($name in $old.Keys) {
    Assert-Hash (Join-Path $original $name) $old[$name]
    if ($name -cne 'version.dll') { Assert-Hash (Join-Path $game $name) $old[$name] }
}
$target = Join-Path $game 'version.dll'
if (-not (Test-Path -LiteralPath $target -PathType Leaf)) { throw 'Installed version.dll missing.' }
$before = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant()
if ($before -cne $old['version.dll'] -and $before -cne $newVersion) {
    throw "Unknown installed version.dll SHA256=$before; refusing change."
}
$desired = if ($Action -eq 'InstallM1') { $newVersion } else { $old['version.dll'] }
$result = 'READ_ONLY'
$switchBackup = ''
if ($Action -ne 'Status') {
    if (@(Get-Process -Name nwmain -ErrorAction SilentlyContinue).Count -ne 0) {
        throw 'NWN is running; close it before switching version.dll.'
    }
    if ($Action -eq 'InstallM1') {
        Assert-Hash (Join-Path $stage 'version.dll') $newVersion
        foreach ($name in $old.Keys) {
            if ($name -cne 'version.dll') { Assert-Hash (Join-Path $stage $name) $old[$name] }
        }
    }
    if ($before -ceq $desired) {
        $result = 'ALREADY_DESIRED_VERSION'
    } else {
        $from = if ($Action -eq 'InstallM1') { Join-Path $stage 'version.dll' } else { Join-Path $original 'version.dll' }
        Assert-Hash $from $desired
        $id = [guid]::NewGuid().ToString('N')
        $temp = Join-Path $game ('.m1fix1-' + $id + '.tmp')
        $switchBackup = Join-Path $game ('.m1fix1-' + $id + '.previous-version.dll.bak')
        try {
            [IO.File]::Copy($from, $temp, $false)
            Assert-Hash $temp $desired
            # The named backup is essential: this Windows/CLR rejects File.Replace(..., $null).
            [IO.File]::Replace($temp, $target, $switchBackup)
            Assert-Hash $target $desired
            Assert-Hash $switchBackup $before
            $result = 'SWITCHED_AND_VERIFIED'
        } finally {
            if (Test-Path -LiteralPath $temp -PathType Leaf) {
                Remove-Item -LiteralPath $temp -Force
            }
            # Never delete the named displaced-DLL backup; leave it for independent recovery.
        }
    }
}
$after = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant()
if ($Action -ne 'Status' -and $after -cne $desired) {
    throw "Post-switch version.dll hash is unexpected: $after"
}
Assert-Hash (Join-Path $game 'nwmain.exe') $exeHash
foreach ($name in $old.Keys) {
    Assert-Hash (Join-Path $original $name) $old[$name]
    if ($name -cne 'version.dll') { Assert-Hash (Join-Path $game $name) $old[$name] }
}
Write-Report @(
    'M1 GUARDED RUNTIME SWITCH FIX1',
    "Action: $Action",
    "Result: $result",
    "Game bin: $game",
    "Original backup: $original",
    "version.dll before SHA256=$before",
    "version.dll after SHA256=$after",
    "Named displaced-DLL backup: $switchBackup",
    'Four companion DLLs and five original backup DLLs: independently verified',
    'Original source checkout and cx.cfg: not modified',
    'Runtime startup, CX self-checks and gameplay: NOT VERIFIED'
)
