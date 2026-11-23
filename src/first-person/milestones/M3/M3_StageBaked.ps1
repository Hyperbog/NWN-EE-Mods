# Build separate M3 source stage from verified M2 without touching installed DLLs.
[CmdletBinding()]
param(
 [string]$M2Root='C:\Projects\NWN_FP_M2_SETTINGS_STAGE',
 [string]$M3Root='C:\Projects\NWN_FP_M3_BAKED_STAGE',
 [string]$PatchPath='C:\Projects\M3_BakedControlsAndTurn.patch',
 [string]$ReportPath='C:\Projects\M3_BakedStageReport.txt'
)
$ErrorActionPreference='Stop'
$M2Root=[IO.Path]::GetFullPath($M2Root)
$M3Root=[IO.Path]::GetFullPath($M3Root)
$PatchPath=[IO.Path]::GetFullPath($PatchPath)
$ReportPath=[IO.Path]::GetFullPath($ReportPath)
function Under([string]$child,[string]$parent){
 $prefix=$parent.TrimEnd([char[]]@([char]'\',[char]'/'))+[IO.Path]::DirectorySeparatorChar
 return $child.Equals($parent,[StringComparison]::OrdinalIgnoreCase) -or
        $child.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)
}
foreach($p in @($M2Root,'C:\Projects\NWN_FP_M1_J4_STAGE','C:\Projects\cx',
 'C:\Projects\M1_PreM1_Runtime_Backup','D:\SteamLibrary\steamapps\common\Neverwinter Nights')){
 $p=[IO.Path]::GetFullPath($p)
 if((Under $M3Root $p) -or (Under $p $M3Root)){throw "Protected path overlap: $p"}
 if(Under $ReportPath $p){throw "Report path overlaps protected source: $p"}
}
if(Under $ReportPath $M3Root){throw 'Report path inside M3 stage.'}
if(Test-Path -LiteralPath $M3Root){throw 'Refusing existing M3 destination.'}
if(Test-Path -LiteralPath $ReportPath){throw 'Refusing existing report.'}
if(-not(Test-Path -LiteralPath $PatchPath -PathType Leaf)){throw 'M3 patch missing.'}
if(-not(Test-Path -LiteralPath $M2Root -PathType Container)){throw 'M2 source missing.'}
foreach($p in @((Split-Path -Parent $M3Root),(Split-Path -Parent $ReportPath))){
 if(-not(Test-Path -LiteralPath $p -PathType Container)){throw "Missing parent: $p"}
}
$source=Join-Path $M2Root 'managed\Services\Camera\CameraKnobs.cs'
if((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -cne 'ECC44A0FC95C7B0D1A2EFC4B19F31A59D81FCB136B538FC8B708131805FBD9D1'){
 throw 'M2 CameraKnobs hash mismatch. No patch was applied.'
}
$exclude=@((Join-Path $M2Root 'build'),(Join-Path $M2Root 'cx-windows-x64'),
 (Join-Path $M2Root 'managed\bin'),(Join-Path $M2Root 'managed\obj'))
& robocopy.exe $M2Root $M3Root /E /R:0 /W:0 /XD $exclude /XF 'cx-windows-x64.zip' 'build-managed-win.log' | Out-Null
if($LASTEXITCODE -ge 8){throw "Copy failed: $LASTEXITCODE"}
& git.exe -C $M3Root apply --check $PatchPath
if($LASTEXITCODE -ne 0){throw 'Patch check failed. M3 stage retained for inspection.'}
& git.exe -C $M3Root apply $PatchPath
if($LASTEXITCODE -ne 0){throw 'Patch application failed. M3 stage retained for inspection.'}
$knobs=[IO.File]::ReadAllText((Join-Path $M3Root 'managed\Services\Camera\CameraKnobs.cs'))
$drive=[IO.File]::ReadAllText((Join-Path $M3Root 'managed\Services\Camera\CameraDriveService.cs'))
if(-not $knobs.Contains('internal bool FirstPersonActive => _mode == 2 || FirstPerson.V;') -or
 -not $knobs.Contains('internal float ZoomLag => _mode == 2 ? 0f : LagZoom.V;') -or
 -not $drive.Contains('FirstPersonHeading(_heading, want, mk.Turn.V, dt)')){
 throw 'Post-application M3 source check failed; do not build.'
}
$report=@('M3 SOURCE STAGE: PASS',"M2: $M2Root","M3: $M3Root",
 "M3 CameraKnobs SHA256: $((Get-FileHash -LiteralPath (Join-Path $M3Root 'managed\Services\Camera\CameraKnobs.cs') -Algorithm SHA256).Hash)",
 'M1 game DLL, cx.cfg, backup, CX original, M1 and M2 source: UNCHANGED',
 'Windows managed build, NativeAOT and animation runtime: NOT TESTED') -join [Environment]::NewLine
[IO.File]::WriteAllText($ReportPath,$report+[Environment]::NewLine,[Text.UTF8Encoding]::new($false))
Write-Host $report
Write-Host "REPORT: $ReportPath"
