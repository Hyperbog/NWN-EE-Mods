# M5 guarded runtime switch: verified M4 to M5, with exact M4 rollback.
# Status is read-only for the game. Named backups preserve displaced DLLs.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Status','InstallM5','RestoreM4')]
    [string]$Action,
    [string]$ReportPath=''
)
$ErrorActionPreference='Stop'
$game='D:\SteamLibrary\steamapps\common\Neverwinter Nights\bin\win32'
$stage='C:\Projects\NWN_FP_M5_NPC_DIALOG_STAGE\cx-windows-x64'
$stageRoot='C:\Projects\NWN_FP_M5_NPC_DIALOG_STAGE'
$m4Stage='C:\Projects\NWN_FP_M4_ACTION_STAGE_R02\cx-windows-x64'
$m4StageRoot='C:\Projects\NWN_FP_M4_ACTION_STAGE_R02'
$m1Backup='C:\Projects\M3_PreM3_M1_Runtime_Backup'
$originalBackup='C:\Projects\M1_PreM1_Runtime_Backup'
$offlineScratch='C:\Projects\M3_OfflineRollbackRehearsal'
$exeSha='3b7cb1252e0edb2ce22d7971f333aade027039ae30a45b4bc64732c3e6bec73a'
$originalSha='b7d67f9cc95fdda93790f4e231d1f0f0066849c8a0645deef16ec5c0d5d7a3b0'
$m1Sha='a3d65b433191ef652d5d03fc1ae3c6fa407f044c518c47d92111652d0079ac86'

$m4Sha='29a719191b9f781a6c37193ffc7c6b8d23ed236c38f8857dd499145edefc70e2'
$m5Sha='27dfa9eb49dff45b84d4e19c8fb0a67841514d413619f7f03cdcaf76802d9a3d'
$sourceCameraMarker='internal static bool NpcDialogActive'
$sourceMouseMarker='&& !CameraService.NpcDialogActive'
$companions=[ordered]@{
    'cx_openal.dll'='3963b06e319180700be0bcc0d027336664bb3a4975876b4a5442f10746fab5b4'
    'phonon.dll'='ca3dbc01dbc24492717011e80f6a51404ca143ae344ca660971d2c983f1e058d'
    'shaderc_shared.dll'='8e13592eac48b94755e4aa4c41552b210b41ca906d0bfe35b0a6d47a97d0b7c6'
    'vma.dll'='504da73d9a8bb5acca40d8b563d8898c536329de07a1638f8cd9dbe1126d661e'
}
if(-not $ReportPath){$ReportPath="C:\Projects\M5_RuntimeSwitch_$Action.txt"}
$ReportPath=[IO.Path]::GetFullPath($ReportPath)
function IsUnder([string]$child,[string]$parent){
    $parent=[IO.Path]::GetFullPath($parent)
    $child=[IO.Path]::GetFullPath($child)
    $prefix=$parent.TrimEnd([char[]]@([char]'\',[char]'/'))+[IO.Path]::DirectorySeparatorChar
    return $child.Equals($parent,[StringComparison]::OrdinalIgnoreCase) -or
           $child.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)
}
foreach($protected in @($game,$stageRoot,$m4StageRoot,$m1Backup,$originalBackup,$offlineScratch,
                         'C:\Projects\cx','C:\Projects\NWN_FP_M1_J4_STAGE',
                         'C:\Projects\NWN_FP_M2_SETTINGS_STAGE')){
    if(IsUnder $ReportPath $protected){throw "Report destination overlaps protected data: $protected"}
}
if(Test-Path -LiteralPath $ReportPath){throw "Existing report: $ReportPath; refusing overwrite"}
if(-not(Test-Path -LiteralPath (Split-Path -Parent $ReportPath) -PathType Container)){
    throw 'Report parent directory missing.'
}
function Assert-Hash([string]$path,[string]$expected){
    if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "File missing: $path"}
    $actual=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if($actual -cne $expected.ToLowerInvariant()){
        throw "SHA256 mismatch: $path expected=$expected actual=$actual"
    }
}
# Preflight all known runtime generations, sources and companion DLLs before any change.
Assert-Hash (Join-Path $game 'nwmain.exe') $exeSha
Assert-Hash (Join-Path $originalBackup 'version.dll') $originalSha
Assert-Hash (Join-Path $m1Backup 'version.dll') $m1Sha
Assert-Hash (Join-Path $m4Stage 'version.dll') $m4Sha
Assert-Hash (Join-Path $stage 'version.dll') $m5Sha
$cameraSource=Join-Path $stageRoot 'managed\Services\Camera\CameraService.cs'
$mouseSource=Join-Path $stageRoot 'managed\Services\Camera\MouseLookService.cs'
if(-not(Test-Path -LiteralPath $cameraSource -PathType Leaf) -or
   -not(Test-Path -LiteralPath $mouseSource -PathType Leaf) -or
   -not([IO.File]::ReadAllText($cameraSource).Contains($sourceCameraMarker)) -or
   -not([IO.File]::ReadAllText($mouseSource).Contains($sourceMouseMarker))){
    throw 'M5 staged dialogue camera and input source markers missing.'
}
foreach($name in $companions.Keys){
    Assert-Hash (Join-Path $game $name) $companions[$name]
    Assert-Hash (Join-Path $stage $name) $companions[$name]
    Assert-Hash (Join-Path $m4Stage $name) $companions[$name]
    Assert-Hash (Join-Path $m1Backup $name) $companions[$name]
    Assert-Hash (Join-Path $originalBackup $name) $companions[$name]
}
# The staged release ZIP must still contain exactly the bytes that were verified by build.
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive=Join-Path $stageRoot 'cx-windows-x64.zip'
if(-not(Test-Path -LiteralPath $archive -PathType Leaf)){throw 'M5 release ZIP missing.'}
$zip=[IO.Compression.ZipFile]::OpenRead($archive)
try{
    $expected=[ordered]@{'version.dll'=$m5Sha}
    foreach($name in $companions.Keys){$expected[$name]=$companions[$name]}
    foreach($name in $expected.Keys){
        $entry=@($zip.Entries | Where-Object {$_.FullName -ceq $name})
        if($entry.Count -ne 1){throw "Missing or duplicate M5 ZIP entry: $name"}
        $stream=$entry[0].Open()
        $sha=[Security.Cryptography.SHA256]::Create()
        try {$actual=[BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-','').ToLowerInvariant()}
        finally {$stream.Dispose();$sha.Dispose()}
        if($actual -cne $expected[$name]){throw "Staged M5 ZIP checksum mismatch: $name"}
    }
} finally {$zip.Dispose()}
$target=Join-Path $game 'version.dll'
if(-not(Test-Path -LiteralPath $target -PathType Leaf)){throw 'Installed version.dll is missing.'}
$before=(Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant()
if($before -cne $m4Sha -and $before -cne $m5Sha){
    throw "Installed version.dll is neither the verified M4 nor M5 release. SHA256=$before; refusing switch."
}
$result='READ_ONLY'
$displaced=''
if($Action -ne 'Status'){
    if(@(Get-Process -Name nwmain -ErrorAction SilentlyContinue).Count -ne 0){
        throw 'NWN is running; close it before changing version.dll.'
    }
    $want=if($Action -eq 'InstallM5'){$m5Sha}else{$m4Sha}
    $from=if($Action -eq 'InstallM5'){
        Join-Path $stage 'version.dll'
    }else{
        Join-Path $m4Stage 'version.dll'
    }
    Assert-Hash $from $want
    if($before -ceq $want){
        $result='ALREADY_DESIRED_VERSION'
    }else{
        $id=[Guid]::NewGuid().ToString('N')
        $temp=Join-Path $game ('.m5switch-'+$id+'.tmp')
        $displaced=Join-Path $game ('.m5switch-'+$id+'.previous-version.dll.bak')
        if((Test-Path -LiteralPath $temp) -or (Test-Path -LiteralPath $displaced)){
            throw 'Randomized temporary or displaced-backup path already exists; refusing.'
        }
        try{
            [IO.File]::Copy($from,$temp,$false)
            Assert-Hash $temp $want
            # File.Replace requires a named backup on the tested Windows configuration.
            [IO.File]::Replace($temp,$target,$displaced)
            Assert-Hash $target $want
            Assert-Hash $displaced $before
            $result='SWITCHED_AND_VERIFIED'
        }finally{
            if(Test-Path -LiteralPath $temp -PathType Leaf){
                Remove-Item -LiteralPath $temp -Force
            }
            # The displaced DLL backup is intentionally NEVER deleted.
        }
    }
}
$after=(Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant()
if($Action -eq 'Status'){
    if($after -cne $before){throw 'version.dll changed during read-only Status; inspect before proceeding.'}
}else{
    if($after -cne $want){throw "Post-switch version.dll hash unexpected: $after"}
}
Assert-Hash (Join-Path $game 'nwmain.exe') $exeSha
Assert-Hash (Join-Path $originalBackup 'version.dll') $originalSha
Assert-Hash (Join-Path $m1Backup 'version.dll') $m1Sha
Assert-Hash (Join-Path $stage 'version.dll') $m5Sha
Assert-Hash (Join-Path $m4Stage 'version.dll') $m4Sha
foreach($name in $companions.Keys){
    Assert-Hash (Join-Path $game $name) $companions[$name]
    Assert-Hash (Join-Path $stage $name) $companions[$name]
    Assert-Hash (Join-Path $m4Stage $name) $companions[$name]
    Assert-Hash (Join-Path $m1Backup $name) $companions[$name]
    Assert-Hash (Join-Path $originalBackup $name) $companions[$name]
}
$lines=@(
    'M5 GUARDED RUNTIME SWITCH',
    "Action: $Action",
    "Result: $result",
    "Game bin: $game",
    "Original pre-M1 backup: $originalBackup",
    "Pre-M3 M1 backup: $m1Backup",
    "M4 baseline, M5 staged markers, and five M5 release ZIP entries: verified",
    "version.dll before SHA256=$before",
    "version.dll after SHA256=$after",
    "Named displaced DLL backup: $displaced",
    'Four unchanged companions, M4 rollback and both older rollback generations: verified',
    'Source checkout and cx.cfg: NOT MODIFIED',
    'M5 runtime startup, CX self-checks and gameplay: NOT TESTED'
)
$report=[string]::Join([Environment]::NewLine,$lines)+[Environment]::NewLine
[IO.File]::WriteAllText($ReportPath,$report,[Text.UTF8Encoding]::new($false))
Write-Host $report
Write-Host "REPORT: $ReportPath"
