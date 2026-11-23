# M1 offline rollback rehearsal. No writes to the game, source trees or saved backup.
# Windows PowerShell 5.1+; refuses an existing test folder and an existing report.
[CmdletBinding()]
param(
    [string]$GameBin = 'D:\SteamLibrary\steamapps\common\Neverwinter Nights\bin\win32',
    [string]$StageRoot = 'C:\Projects\NWN_FP_M1_J4_STAGE',
    [string]$BackupDir = 'C:\Projects\M1_PreM1_Runtime_Backup',
    [string]$TestDir = 'C:\Projects\M1_OfflineRollbackTest',
    [string]$ReportPath = 'C:\Projects\M1_OfflineRollbackTest.txt'
)
$ErrorActionPreference = 'Stop'
$GameBin = [IO.Path]::GetFullPath($GameBin)
$StageRoot = [IO.Path]::GetFullPath($StageRoot)
$BackupDir = [IO.Path]::GetFullPath($BackupDir)
$TestDir = [IO.Path]::GetFullPath($TestDir)
$ReportPath = [IO.Path]::GetFullPath($ReportPath)
$SourceRoot = [IO.Path]::GetFullPath('C:\Projects\cx')
$slash = [IO.Path]::DirectorySeparatorChar

function Contains-Path([string]$parent, [string]$child) {
    $prefix = $parent.TrimEnd([char[]]@([char]'\', [char]'/')) + $slash
    return $child.Equals($parent, [StringComparison]::OrdinalIgnoreCase) -or
           $child.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)
}
foreach ($protected in @($GameBin, $StageRoot, $BackupDir, $SourceRoot)) {
    if ((Contains-Path $protected $TestDir) -or (Contains-Path $TestDir $protected)) {
        throw "Test directory must be wholly separate from protected trees: $protected"
    }
    if (Contains-Path $protected $ReportPath) {
        throw "Report cannot be inside protected tree: $protected"
    }
}
if (Contains-Path $TestDir $ReportPath) {
    throw 'Report cannot be inside the test directory.'
}
if (Test-Path -LiteralPath $TestDir) { throw "Existing test directory: $TestDir" }
if (Test-Path -LiteralPath $ReportPath) { throw "Existing report: $ReportPath" }
foreach ($parent in @((Split-Path -Parent $TestDir), (Split-Path -Parent $ReportPath))) {
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        throw "Missing destination parent directory: $parent"
    }
}
$expected = [ordered]@{
    'version.dll' = @{ Original = 'b7d67f9cc95fdda93790f4e231d1f0f0066849c8a0645deef16ec5c0d5d7a3b0'; M1 = 'a3d65b433191ef652d5d03fc1ae3c6fa407f044c518c47d92111652d0079ac86' }
    'cx_openal.dll' = @{ Original = '3963b06e319180700be0bcc0d027336664bb3a4975876b4a5442f10746fab5b4'; M1 = '3963b06e319180700be0bcc0d027336664bb3a4975876b4a5442f10746fab5b4' }
    'phonon.dll' = @{ Original = 'ca3dbc01dbc24492717011e80f6a51404ca143ae344ca660971d2c983f1e058d'; M1 = 'ca3dbc01dbc24492717011e80f6a51404ca143ae344ca660971d2c983f1e058d' }
    'shaderc_shared.dll' = @{ Original = '8e13592eac48b94755e4aa4c41552b210b41ca906d0bfe35b0a6d47a97d0b7c6'; M1 = '8e13592eac48b94755e4aa4c41552b210b41ca906d0bfe35b0a6d47a97d0b7c6' }
    'vma.dll' = @{ Original = '504da73d9a8bb5acca40d8b563d8898c536329de07a1638f8cd9dbe1126d661e'; M1 = '504da73d9a8bb5acca40d8b563d8898c536329de07a1638f8cd9dbe1126d661e' }
}
if (-not (Test-Path -LiteralPath (Join-Path $GameBin 'nwmain.exe') -PathType Leaf)) {
    throw 'No nwmain.exe in the expected game directory.'
}
if (@(Get-Process -Name nwmain -ErrorAction SilentlyContinue).Count -ne 0) {
    throw 'Game is running; close it before conducting the rollback rehearsal.'
}
$stageFiles = Join-Path $StageRoot 'cx-windows-x64'
function Assert-Hash([string]$full, [string]$hash) {
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
        throw "Missing file: $full"
    }
    $actual = (Get-FileHash -LiteralPath $full -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -cne $hash) { throw "Checksum mismatch: $full expected=$hash actual=$actual" }
}
# Preflight all inputs before creating the scratch directory.
$baselineExeHash = '3b7cb1252e0edb2ce22d7971f333aade027039ae30a45b4bc64732c3e6bec73a'
Assert-Hash (Join-Path $GameBin 'nwmain.exe') $baselineExeHash
foreach ($name in $expected.Keys) {
    Assert-Hash (Join-Path $GameBin $name) $expected[$name].Original
    Assert-Hash (Join-Path $BackupDir $name) $expected[$name].Original
    Assert-Hash (Join-Path $stageFiles $name) $expected[$name].M1
}
$report = New-Object 'System.Collections.Generic.List[string]'
$report.Add('M1 OFFLINE ROLLBACK REHEARSAL (NO GAME MODIFICATIONS)')
$report.Add("Source backup: $BackupDir")
$report.Add("Stage package: $stageFiles")
$report.Add("Scratch directory: $TestDir")
[IO.Directory]::CreateDirectory($TestDir) | Out-Null
# Simulate installation in scratch only. No access to the real DLL destination.
foreach ($name in $expected.Keys) {
    $scratch = Join-Path $TestDir $name
    Copy-Item -LiteralPath (Join-Path $stageFiles $name) -Destination $scratch
    Assert-Hash $scratch $expected[$name].M1
    $report.Add("SIMULATED_M1: $name SHA256=$($expected[$name].M1)")
}
# Simulate rollback in scratch. Preserve the original backup unchanged.
foreach ($name in $expected.Keys) {
    $scratch = Join-Path $TestDir $name
    Copy-Item -LiteralPath (Join-Path $BackupDir $name) -Destination $scratch -Force
    Assert-Hash $scratch $expected[$name].Original
    $report.Add("SIMULATED_RESTORE: $name SHA256=$($expected[$name].Original)")
}
# Confirm no game file changed while the rehearsal ran.
Assert-Hash (Join-Path $GameBin 'nwmain.exe') $baselineExeHash
foreach ($name in $expected.Keys) {
    Assert-Hash (Join-Path $GameBin $name) $expected[$name].Original
}
$report.Add('RESULT: PASS - five staged DLLs copied into scratch, then five originals restored; every hash verified.')
$report.Add('Game binaries, CX source, cx.cfg and backup: NOT MODIFIED.')
$report.Add('LIMIT: actual game-directory installation/restoration and in-game behavior NOT TESTED.')
$body = [string]::Join([Environment]::NewLine, $report) + [Environment]::NewLine
[IO.File]::WriteAllText($ReportPath, $body, [Text.UTF8Encoding]::new($false))
Write-Host $body
Write-Host "REPORT: $ReportPath"
