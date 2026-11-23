# M6: One-step isolated stage and Windows build (no game installation).
# Requires the verified M5 source and build tools.
[CmdletBinding()]
param(
 [string]$M5Base='C:\Projects\NWN_FP_M5_NPC_DIALOG_STAGE',
 [string]$M6='C:\Projects\NWN_FP_M6_WALL_RELEASE_STAGE',
 [string]$Patch='C:\Projects\M6_WallRelease.patch',
 [string]$Report='C:\Projects\M6_StageBuildReport.txt'
)
$ErrorActionPreference='Stop'
$M5Base=[IO.Path]::GetFullPath($M5Base);$M6=[IO.Path]::GetFullPath($M6)
$Patch=[IO.Path]::GetFullPath($Patch);$Report=[IO.Path]::GetFullPath($Report)
function Under([string]$x,[string]$p){
 $prefix=$p.TrimEnd([char[]]@([char]'\',[char]'/'))+[IO.Path]::DirectorySeparatorChar
 return $x.Equals($p,[StringComparison]::OrdinalIgnoreCase) -or
        $x.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)
}
foreach($p in @($M5Base,'C:\Projects\NWN_FP_M4_ACTION_STAGE_R02','C:\Projects\NWN_FP_M3_BAKED_STAGE','C:\Projects\cx','C:\Projects\NWN_FP_M1_J4_STAGE',
 'C:\Projects\NWN_FP_M2_SETTINGS_STAGE','C:\Projects\M1_PreM1_Runtime_Backup',
 'C:\Projects\M3_PreM3_M1_Runtime_Backup',
 'D:\SteamLibrary\steamapps\common\Neverwinter Nights')){
 $p=[IO.Path]::GetFullPath($p)
 if((Under $M6 $p) -or (Under $p $M6)){throw "Protected path overlaps M5: $p"}
 if(Under $Report $p){throw "Report overlaps protected path: $p"}
}
if(Under $Report $M6){throw 'Report cannot be in M6 directory.'}
# A previous attempt may have left an M6 directory or log. Never delete it:
# choose a fresh numbered M6 stage and separate output files automatically.
$baseStage=$M6
$baseReport=$Report
$reportParent=Split-Path -Parent $baseReport
$reportStem=[IO.Path]::GetFileNameWithoutExtension($baseReport)
$reportExt=[IO.Path]::GetExtension($baseReport)
$chosen=$false
for($runNumber=1;$runNumber -le 99;$runNumber++){
 $suffix=if($runNumber -eq 1){''}else{'_R{0:D2}' -f $runNumber}
 $nextStage=$baseStage+$suffix
 $nextReport=Join-Path $reportParent ($reportStem+$suffix+$reportExt)
 $nextManaged=Join-Path $reportParent ('M6_ManagedBuild'+$suffix+'.log')
 $nextNative=Join-Path $reportParent ('M6_NativeBuild'+$suffix+'.log')
 $nextNativeErr=Join-Path $reportParent ('M6_NativeBuild'+$suffix+'.stderr.log')
 if((Test-Path -LiteralPath $nextStage) -or (Test-Path -LiteralPath $nextReport) -or
    (Test-Path -LiteralPath $nextManaged) -or (Test-Path -LiteralPath $nextNative) -or
    (Test-Path -LiteralPath $nextNativeErr)){continue}
 $M6=$nextStage
 $Report=$nextReport
 $managedLog=$nextManaged
 $nativeLog=$nextNative
 $nativeErr=$nextNativeErr
 $chosen=$true
 break
}
if(-not $chosen){throw 'No unused M6 stage/log slot from base through _R99; refusing overwrite.'}
if(-not(Test-Path -LiteralPath $reportParent -PathType Container)){
 throw "M6 report parent does not exist: $reportParent"
}
Write-Host "M6 stage selected: $M6"
Write-Host "M6 report selected: $Report"
if(-not(Test-Path -LiteralPath $Patch -PathType Leaf)){throw "Patch not found: $Patch"}
$baseVersion=Join-Path (Join-Path $M5Base 'cx-windows-x64') 'version.dll'
if(-not(Test-Path -LiteralPath $baseVersion -PathType Leaf) -or
  (Get-FileHash -LiteralPath $baseVersion -Algorithm SHA256).Hash -cne
  '27DFA9EB49DFF45B84D4E19C8FB0A67841514D413619F7F03CDCAF76802D9A3D'){
 throw 'M5 base release does not match the verified M5-rc1 build.'
}
$exclude=@((Join-Path $M5Base 'build'),(Join-Path $M5Base 'cx-windows-x64'),
 (Join-Path $M5Base 'managed\bin'),(Join-Path $M5Base 'managed\obj'))
& robocopy.exe $M5Base $M6 /E /R:0 /W:0 /XD $exclude /XF 'cx-windows-x64.zip' 'build-managed-win.log' | Out-Null
if($LASTEXITCODE -ge 8){throw "Copy failed: $LASTEXITCODE"}
& git.exe -C $M6 apply --check $Patch
if($LASTEXITCODE -ne 0){throw 'M6 patch failed precheck; no build attempted.'}
& git.exe -C $M6 apply $Patch
if($LASTEXITCODE -ne 0){throw 'M6 patch apply failed.'}
$drive=[IO.File]::ReadAllText((Join-Path $M6 'managed\Services\Camera\CameraDriveService.cs'))
$guard=[IO.File]::ReadAllText((Join-Path $M6 'managed\Services\Camera\StepGuardService.cs'))
if(-not $drive.Contains('[m6wall] fallback abort') -or -not $guard.Contains('M6PersistentRefusal')){
 throw 'M6 wall-release markers absent.'
}
$camera=[IO.File]::ReadAllText((Join-Path $M6 'managed\Services\Camera\CameraService.cs'))
$mouse=[IO.File]::ReadAllText((Join-Path $M6 'managed\Services\Camera\MouseLookService.cs'))
if(-not $camera.Contains('internal static bool NpcDialogActive') -or
   -not $camera.Contains('[fpdialog] Driving eye camera held') -or
   -not $mouse.Contains('&& !CameraService.NpcDialogActive')){
 throw 'M6 NPC-dialogue camera/input split markers absent.'
}
Push-Location $M6
try {
 & dotnet.exe build 'managed\cx_managed.csproj' -c Release -r win-x64 -p:PublishAot=false -v:minimal *> $managedLog
 if($LASTEXITCODE -ne 0){throw "M6 managed compile failed. Log: $managedLog"}
 $bash='C:\Program Files\Git\bin\bash.exe'
 if(-not(Test-Path -LiteralPath $bash -PathType Leaf)){throw "Git Bash missing: $bash"}
 $run=Start-Process -FilePath $bash -ArgumentList @('./build-win-native.sh') -WorkingDirectory $M6 -Wait -PassThru -NoNewWindow -RedirectStandardOutput $nativeLog -RedirectStandardError $nativeErr
 if($run.ExitCode -ne 0){throw "M6 NativeAOT failed (exit $($run.ExitCode)). Logs: $nativeLog and $nativeErr"}
} finally { Pop-Location }
$dir=Join-Path $M6 'cx-windows-x64'
$archive=Join-Path $M6 'cx-windows-x64.zip'
if(-not(Test-Path -LiteralPath $archive -PathType Leaf)){throw "Missing M6 ZIP: $archive"}
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip=[IO.Compression.ZipFile]::OpenRead($archive)
try {
 $lines=[Collections.Generic.List[string]]::new()
 $lines.Add('M6 WALL RELEASE STAGE + NATIVE BUILD: PASS')
 $lines.Add("M6 source: $M6")
 $lines.Add("Managed log: $managedLog")
 $lines.Add("Native stdout: $nativeLog")
 $lines.Add("Native stderr: $nativeErr")
 foreach($name in @('version.dll','cx_openal.dll','phonon.dll','shaderc_shared.dll','vma.dll')){
  $path=Join-Path $dir $name
  if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "Missing M6 DLL: $name"}
  $hash=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
  $entry=@($zip.Entries|Where-Object{$_.FullName -ceq $name})
  if($entry.Count -ne 1){throw "Missing or duplicate M6 ZIP DLL: $name"}
  $stream=$entry[0].Open();$sha=[Security.Cryptography.SHA256]::Create()
  try{$packed=[BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-','').ToLowerInvariant()}
  finally{$stream.Dispose();$sha.Dispose()}
  if($hash -cne $packed){throw "M6 folder/ZIP hash mismatch: $name"}
  if($name -eq 'version.dll' -and $hash -ceq '27dfa9eb49dff45b84d4e19c8fb0a67841514d413619f7f03cdcaf76802d9a3d'){
   throw 'M6 version.dll matches the old M5 binary; refusing stale build.'
  }
  $lines.Add("$name SHA256=$hash ZIP=MATCH bytes=$((Get-Item -LiteralPath $path).Length)")
 }
 $lines.Add('Source patch applied and managed/NativeAOT compilation succeeded.')
 $lines.Add('Original CX, game DLLs, cx.cfg and rollback backups: NOT MODIFIED')
 $lines.Add('Actual gameplay: NOT TESTED')
 [IO.File]::WriteAllText($Report,([string]::Join([Environment]::NewLine,$lines)+[Environment]::NewLine),
  [Text.UTF8Encoding]::new($false))
 Write-Host ([string]::Join([Environment]::NewLine,$lines))
 Write-Host "REPORT: $Report"
} finally {$zip.Dispose()}
