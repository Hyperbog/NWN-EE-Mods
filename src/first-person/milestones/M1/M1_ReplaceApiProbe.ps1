# M1 File.Replace API probe, using disposable files only, on the game's D: volume.
# Never reads, writes, renames or replaces nwmain.exe, installed DLLs, CX source or backup.
[CmdletBinding()]
param(
    [string]$ScratchRoot = 'D:\SteamLibrary\steamapps\common\M1_ReplaceApiProbe',
    [string]$ReportPath = 'C:\Projects\M1_ReplaceApiProbe_Result.txt'
)
$ErrorActionPreference = 'Stop'
$ScratchRoot = [IO.Path]::GetFullPath($ScratchRoot)
$ReportPath = [IO.Path]::GetFullPath($ReportPath)
$sep = [string][IO.Path]::DirectorySeparatorChar
function Under([string]$path, [string]$parent) {
    $prefix = $parent.TrimEnd([char[]]@([char]'\', [char]'/')) + $sep
    return $path.Equals($parent, [StringComparison]::OrdinalIgnoreCase) -or
           $path.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)
}
$protected = @(
    'D:\SteamLibrary\steamapps\common\Neverwinter Nights',
    'C:\Projects\cx',
    'C:\Projects\NWN_FP_M1_J4_STAGE',
    'C:\Projects\M1_PreM1_Runtime_Backup'
)
foreach ($p in $protected) {
    $p = [IO.Path]::GetFullPath($p)
    if ((Under $ScratchRoot $p) -or (Under $p $ScratchRoot)) {
        throw "Scratch path must not overlap protected directory: $p"
    }
    if (Under $ReportPath $p) { throw "Report path overlaps protected directory: $p" }
}
if ((Under $ReportPath $ScratchRoot) -or (Under $ScratchRoot $ReportPath)) {
    throw 'Report and scratch destinations must not overlap.'
}
if (Test-Path -LiteralPath $ScratchRoot) { throw "Refusing existing scratch folder: $ScratchRoot" }
if (Test-Path -LiteralPath $ReportPath) { throw "Refusing existing report: $ReportPath" }
foreach ($parent in @((Split-Path -Parent $ScratchRoot), (Split-Path -Parent $ReportPath))) {
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        throw "Parent directory is missing: $parent"
    }
}
[void][IO.Directory]::CreateDirectory($ScratchRoot)
$lines = New-Object 'System.Collections.Generic.List[string]'
$lines.Add('M1 FILE.REPLACE API PROBE — SCRATCH ONLY')
$lines.Add("PowerShell: $($PSVersionTable.PSVersion.ToString())")
$lines.Add("CLR: $([Environment]::Version)")
$lines.Add("OS: $([Environment]::OSVersion.VersionString)")
$lines.Add("Scratch: $ScratchRoot")
$lines.Add('NO GAME FILES ACCESSED; NO DLLS INSTALLED')
foreach ($mode in @('NullBackup', 'NamedBackup')) {
    $dir = Join-Path $ScratchRoot $mode
    [void][IO.Directory]::CreateDirectory($dir)
    $source = Join-Path $dir 'source.tmp'
    $target = Join-Path $dir 'target.dll'
    $backup = Join-Path $dir 'prior-version.bak'
    [IO.File]::WriteAllText($source, 'NEW-' + $mode, [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText($target, 'OLD-' + $mode, [Text.UTF8Encoding]::new($false))
    try {
        if ($mode -eq 'NullBackup') {
            [IO.File]::Replace($source, $target, $null)
        } else {
            [IO.File]::Replace($source, $target, $backup)
        }
        $content = [IO.File]::ReadAllText($target)
        $backupValid = if ($mode -eq 'NamedBackup') {
            (Test-Path -LiteralPath $backup -PathType Leaf) -and
            ([IO.File]::ReadAllText($backup) -ceq ('OLD-' + $mode))
        } else { $true }
        $passed = ($content -ceq ('NEW-' + $mode)) -and $backupValid
        if ($passed) {
            $lines.Add("$mode : PASS (replacement content verified; named backup verified where applicable)")
        } else {
            $lines.Add("$mode : INCOMPLETE (target=$content backupValid=$backupValid)")
        }
    } catch {
        $type = $_.Exception.GetType().FullName
        $msg = $_.Exception.Message
        $inner = if ($_.Exception.InnerException) { $_.Exception.InnerException.Message } else { 'none' }
        $lines.Add("$mode : FAIL type=$type message=$msg inner=$inner")
    }
}
$lines.Add('Scratch files retained for inspection; source/game/backup untouched.')
$output = [string]::Join([Environment]::NewLine, $lines) + [Environment]::NewLine
[IO.File]::WriteAllText($ReportPath, $output, [Text.UTF8Encoding]::new($false))
Write-Host $output
Write-Host "REPORT: $ReportPath"
