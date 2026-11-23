# M3 safety gate: back up installed M1 before any M3 installation.
# Read-only game/source. Only creates a fresh backup directory and report.
[CmdletBinding()]
param(
 [string]$GameBin='D:\SteamLibrary\steamapps\common\Neverwinter Nights\bin\win32',
 [string]$M3Stage='C:\Projects\NWN_FP_M3_BAKED_STAGE',
 [string]$OriginalBackup='C:\Projects\M1_PreM1_Runtime_Backup',
 [string]$BackupDir='C:\Projects\M3_PreM3_M1_Runtime_Backup',
 [string]$ReportPath='C:\Projects\M3_M1_BackupVerification.txt'
)
$ErrorActionPreference='Stop'
$GameBin=[IO.Path]::GetFullPath($GameBin)
$M3Stage=[IO.Path]::GetFullPath($M3Stage)
$OriginalBackup=[IO.Path]::GetFullPath($OriginalBackup)
$BackupDir=[IO.Path]::GetFullPath($BackupDir)
$ReportPath=[IO.Path]::GetFullPath($ReportPath)
function Under([string]$child,[string]$parent) {
 $prefix=$parent.TrimEnd([char[]]@([char]'\',[char]'/'))+[IO.Path]::DirectorySeparatorChar
 return $child.Equals($parent,[StringComparison]::OrdinalIgnoreCase) -or $child.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)
}
foreach($p in @($GameBin,$M3Stage,$OriginalBackup,'C:\Projects\cx','C:\Projects\NWN_FP_M1_J4_STAGE','C:\Projects\NWN_FP_M2_SETTINGS_STAGE')){
 $p=[IO.Path]::GetFullPath($p)
 if((Under $BackupDir $p) -or (Under $p $BackupDir)){throw "Backup destination overlaps protected data: $p"}
 if(Under $ReportPath $p){throw "Report destination overlaps protected data: $p"}
}
if((Under $ReportPath $BackupDir) -or (Under $BackupDir $ReportPath)){throw 'Backup and report destinations overlap.'}
if(Test-Path -LiteralPath $BackupDir){throw "Refusing existing backup: $BackupDir"}
if(Test-Path -LiteralPath $ReportPath){throw "Refusing existing report: $ReportPath"}
foreach($p in @((Split-Path -Parent $BackupDir),(Split-Path -Parent $ReportPath))){
 if(-not(Test-Path -LiteralPath $p -PathType Container)){throw "Missing output parent: $p"}
}
if(@(Get-Process -Name nwmain -ErrorAction SilentlyContinue).Count -ne 0){throw 'NWN is still running. Close the game.'}
$exe='3b7cb1252e0edb2ce22d7971f333aade027039ae30a45b4bc64732c3e6bec73a'
$old='b7d67f9cc95fdda93790f4e231d1f0f0066849c8a0645deef16ec5c0d5d7a3b0'
$m1='a3d65b433191ef652d5d03fc1ae3c6fa407f044c518c47d92111652d0079ac86'
$m3='1ec40d2fd60454dc92e8bfd29ca591600fba0db1d3f5e2ccc4232b09868e891d'
$companions=[ordered]@{
 'cx_openal.dll'='3963b06e319180700be0bcc0d027336664bb3a4975876b4a5442f10746fab5b4'
 'phonon.dll'='ca3dbc01dbc24492717011e80f6a51404ca143ae344ca660971d2c983f1e058d'
 'shaderc_shared.dll'='8e13592eac48b94755e4aa4c41552b210b41ca906d0bfe35b0a6d47a97d0b7c6'
 'vma.dll'='504da73d9a8bb5acca40d8b563d8898c536329de07a1638f8cd9dbe1126d661e'
}
function Assert-Hash([string]$path,[string]$expected){
 if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "File missing: $path"}
 $sha=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
 if($sha -cne $expected){throw "SHA256 mismatch: $path expected=$expected actual=$sha"}
}
# Preflight every dependency before writing.
Assert-Hash (Join-Path $GameBin 'nwmain.exe') $exe
Assert-Hash (Join-Path $GameBin 'version.dll') $m1
Assert-Hash (Join-Path $OriginalBackup 'version.dll') $old
Assert-Hash (Join-Path (Join-Path $M3Stage 'cx-windows-x64') 'version.dll') $m3
Assert-Hash (Join-Path $M3Stage 'managed\Services\Camera\CameraKnobs.cs') '59881B5270A25F62D75EEFEF82DCE186A262B309D02D24A7563CF793D35250DC'
foreach($n in $companions.Keys){
 Assert-Hash (Join-Path $GameBin $n) $companions[$n]
 Assert-Hash (Join-Path $OriginalBackup $n) $companions[$n]
 Assert-Hash (Join-Path (Join-Path $M3Stage 'cx-windows-x64') $n) $companions[$n]
}
[void][IO.Directory]::CreateDirectory($BackupDir)
$expected=[ordered]@{'version.dll'=$m1}
foreach($n in $companions.Keys){$expected[$n]=$companions[$n]}
$lines=[Collections.Generic.List[string]]::new()
$lines.Add('M3 PRE-INSTALL CURRENT M1 RUNTIME BACKUP')
$lines.Add("Game bin: $GameBin")
$lines.Add("Backup: $BackupDir")
$lines.Add("M3 staged version.dll SHA256=$m3 VERIFIED")
foreach($n in $expected.Keys){
 $from=Join-Path $GameBin $n
 $to=Join-Path $BackupDir $n
 [IO.File]::Copy($from,$to,$false)
 Assert-Hash $to $expected[$n]
 Assert-Hash $from $expected[$n]
 $lines.Add("$n bytes=$((Get-Item -LiteralPath $to).Length) SHA256=$($expected[$n]) VERIFIED")
 Write-Host "VERIFIED: $n"
}
Assert-Hash (Join-Path $GameBin 'nwmain.exe') $exe
$lines.Add('RESULT: PASS - five currently installed M1 DLLs copied and independently verified')
$lines.Add('Original pre-M1 backup, installed game, CX source, cx.cfg: NOT MODIFIED')
$lines.Add('NOT TESTED: M3 installation, CX startup, animation smoothness')
$report=[string]::Join([Environment]::NewLine,$lines)+[Environment]::NewLine
$utf8=[Text.UTF8Encoding]::new($false)
[IO.File]::WriteAllText((Join-Path $BackupDir 'BACKUP_MANIFEST.txt'),$report,$utf8)
[IO.File]::WriteAllText($ReportPath,$report,$utf8)
Write-Host $report
Write-Host "REPORT: $ReportPath"
