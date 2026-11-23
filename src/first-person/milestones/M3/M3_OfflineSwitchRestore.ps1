# M3 offline switch/rollback rehearsal. Only writes into a NEW scratch folder and report.
# Windows PowerShell 5.1; never installs anything in the game.
[CmdletBinding()]
param(
    [string]$ScratchRoot='C:\Projects\M3_OfflineRollbackRehearsal',
    [string]$ReportPath='C:\Projects\M3_OfflineRollbackReport.txt'
)
$ErrorActionPreference='Stop'
$game='D:\SteamLibrary\steamapps\common\Neverwinter Nights\bin\win32'
$m1='C:\Projects\M3_PreM3_M1_Runtime_Backup'
$m3='C:\Projects\NWN_FP_M3_BAKED_STAGE\cx-windows-x64'
$original='C:\Projects\M1_PreM1_Runtime_Backup'
$stage='C:\Projects\NWN_FP_M3_BAKED_STAGE'
$ScratchRoot=[IO.Path]::GetFullPath($ScratchRoot)
$ReportPath=[IO.Path]::GetFullPath($ReportPath)
function Under([string]$child,[string]$parent) {
    $prefix=$parent.TrimEnd([char[]]@([char]'\',[char]'/'))+[IO.Path]::DirectorySeparatorChar
    return $child.Equals($parent,[StringComparison]::OrdinalIgnoreCase) -or
           $child.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)
}
foreach($p in @($game,$m1,$m3,$original,$stage,'C:\Projects\cx',
                'C:\Projects\NWN_FP_M1_J4_STAGE','C:\Projects\NWN_FP_M2_SETTINGS_STAGE')) {
    $p=[IO.Path]::GetFullPath($p)
    if((Under $ScratchRoot $p) -or (Under $p $ScratchRoot)) {
        throw "Scratch path overlaps protected data: $p"
    }
    if(Under $ReportPath $p){throw "Report path overlaps protected data: $p"}
}
if((Under $ReportPath $ScratchRoot) -or (Under $ScratchRoot $ReportPath)) {
    throw 'Scratch and report paths overlap.'
}
if(Test-Path -LiteralPath $ScratchRoot){throw "Refusing existing scratch: $ScratchRoot"}
if(Test-Path -LiteralPath $ReportPath){throw "Refusing existing report: $ReportPath"}
foreach($p in @((Split-Path -Parent $ScratchRoot),(Split-Path -Parent $ReportPath))) {
    if(-not(Test-Path -LiteralPath $p -PathType Container)){throw "Missing output parent: $p"}
}
if(@(Get-Process -Name nwmain -ErrorAction SilentlyContinue).Count -ne 0) {
    throw 'NWN is running; close it before this preflight.'
}
$gameExeHash='3b7cb1252e0edb2ce22d7971f333aade027039ae30a45b4bc64732c3e6bec73a'
$m1Version='a3d65b433191ef652d5d03fc1ae3c6fa407f044c518c47d92111652d0079ac86'
$m3Version='1ec40d2fd60454dc92e8bfd29ca591600fba0db1d3f5e2ccc4232b09868e891d'
$originalVersion='b7d67f9cc95fdda93790f4e231d1f0f0066849c8a0645deef16ec5c0d5d7a3b0'
$companions=[ordered]@{
    'cx_openal.dll'='3963b06e319180700be0bcc0d027336664bb3a4975876b4a5442f10746fab5b4'
    'phonon.dll'='ca3dbc01dbc24492717011e80f6a51404ca143ae344ca660971d2c983f1e058d'
    'shaderc_shared.dll'='8e13592eac48b94755e4aa4c41552b210b41ca906d0bfe35b0a6d47a97d0b7c6'
    'vma.dll'='504da73d9a8bb5acca40d8b563d8898c536329de07a1638f8cd9dbe1126d661e'
}
function Assert-Hash([string]$path,[string]$expected) {
    if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "Missing file: $path"}
    $actual=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if($actual -cne $expected.ToLowerInvariant()) {
        throw "SHA256 mismatch: $path expected=$expected actual=$actual"
    }
}
# Fail closed before creating scratch if installed game, both backups or stage changed.
Assert-Hash (Join-Path $game 'nwmain.exe') $gameExeHash
Assert-Hash (Join-Path $game 'version.dll') $m1Version
Assert-Hash (Join-Path $m1 'version.dll') $m1Version
Assert-Hash (Join-Path $m3 'version.dll') $m3Version
Assert-Hash (Join-Path $original 'version.dll') $originalVersion
Assert-Hash (Join-Path $stage 'managed\Services\Camera\CameraKnobs.cs') '59881B5270A25F62D75EEFEF82DCE186A262B309D02D24A7563CF793D35250DC'
foreach($name in $companions.Keys) {
    foreach($dir in @($game,$m1,$m3,$original)) {
        Assert-Hash (Join-Path $dir $name) $companions[$name]
    }
}
# Offline install M3 using disposable copies of original M1 DLLs, not game DLLs.
[void][IO.Directory]::CreateDirectory($ScratchRoot)
$expected=[ordered]@{'version.dll'=$m1Version}
foreach($name in $companions.Keys){$expected[$name]=$companions[$name]}
foreach($name in $expected.Keys) {
    [IO.File]::Copy((Join-Path $m1 $name),(Join-Path $ScratchRoot $name),$false)
    Assert-Hash (Join-Path $ScratchRoot $name) $expected[$name]
}
$target=Join-Path $ScratchRoot 'version.dll'
$installTemp=Join-Path $ScratchRoot '.install-M3.tmp'
$displacedM1=Join-Path $ScratchRoot '.displaced-M1.named-backup.bak'
[IO.File]::Copy((Join-Path $m3 'version.dll'),$installTemp,$false)
Assert-Hash $installTemp $m3Version
[IO.File]::Replace($installTemp,$target,$displacedM1)
Assert-Hash $target $m3Version
Assert-Hash $displacedM1 $m1Version
# Offline restore the M1 DLL using a NEW, named backup for displaced M3.
$restoreTemp=Join-Path $ScratchRoot '.restore-M1.tmp'
$displacedM3=Join-Path $ScratchRoot '.displaced-M3.named-backup.bak'
[IO.File]::Copy((Join-Path $m1 'version.dll'),$restoreTemp,$false)
Assert-Hash $restoreTemp $m1Version
[IO.File]::Replace($restoreTemp,$target,$displacedM3)
Assert-Hash $target $m1Version
Assert-Hash $displacedM3 $m3Version
foreach($name in $expected.Keys) {Assert-Hash (Join-Path $ScratchRoot $name) $expected[$name]}
# Confirm the real game, M1 rollback and original backup were not altered.
Assert-Hash (Join-Path $game 'nwmain.exe') $gameExeHash
Assert-Hash (Join-Path $game 'version.dll') $m1Version
Assert-Hash (Join-Path $m1 'version.dll') $m1Version
Assert-Hash (Join-Path $original 'version.dll') $originalVersion
foreach($name in $companions.Keys) {
    Assert-Hash (Join-Path $game $name) $companions[$name]
    Assert-Hash (Join-Path $m1 $name) $companions[$name]
    Assert-Hash (Join-Path $original $name) $companions[$name]
}
$report=@(
    'M3 OFFLINE INSTALL + M1 RESTORE REHEARSAL: PASS',
    "Scratch: $ScratchRoot",
    'M1 five-DLL scratch copy: verified',
    "Scratch installation: M1 -> M3 SHA256=$m3Version VERIFIED",
    "Named displaced M1 SHA256=$m1Version VERIFIED",
    "Scratch restoration: M3 -> M1 SHA256=$m1Version VERIFIED",
    "Named displaced M3 SHA256=$m3Version VERIFIED",
    'Four companion DLLs unchanged: VERIFIED',
    'Live game executable and all installed five DLLs: unchanged, VERIFIED',
    'Independent M1 and pre-M1 original rollback backups: unchanged, VERIFIED',
    'Original CX source, M1/M2/M3 stage and cx.cfg: no writes',
    'LIVE installation, CX startup and motion animations: NOT TESTED'
) -join [Environment]::NewLine
[IO.File]::WriteAllText($ReportPath,$report+[Environment]::NewLine,[Text.UTF8Encoding]::new($false))
Write-Host $report
Write-Host "REPORT: $ReportPath"
