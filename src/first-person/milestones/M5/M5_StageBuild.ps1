# M5: One-step isolated stage and Windows build (no game installation).
# Requires the already validated M4 source and build tools.
[CmdletBinding()]
param(
 [string]$M4Base='C:\Projects\NWN_FP_M4_ACTION_STAGE_R02',
 [string]$M5='C:\Projects\NWN_FP_M5_NPC_DIALOG_STAGE',
 [string]$Patch='C:\Projects\M5_NpcDialogueCamera.patch',
 [string]$Report='C:\Projects\M5_StageBuildReport.txt'
)
$ErrorActionPreference='Stop'
$M4Base=[IO.Path]::GetFullPath($M4Base);$M5=[IO.Path]::GetFullPath($M5)
$Patch=[IO.Path]::GetFullPath($Patch);$Report=[IO.Path]::GetFullPath($Report)
function Under([string]$x,[string]$p){
 $prefix=$p.TrimEnd([char[]]@([char]'\',[char]'/'))+[IO.Path]::DirectorySeparatorChar
 return $x.Equals($p,[StringComparison]::OrdinalIgnoreCase) -or
        $x.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)
}
foreach($p in @($M4Base,'C:\Projects\cx','C:\Projects\NWN_FP_M1_J4_STAGE',
 'C:\Projects\NWN_FP_M2_SETTINGS_STAGE','C:\Projects\M1_PreM1_Runtime_Backup',
 'C:\Projects\M3_PreM3_M1_Runtime_Backup',
 'D:\SteamLibrary\steamapps\common\Neverwinter Nights')){
 $p=[IO.Path]::GetFullPath($p)
 if((Under $M5 $p) -or (Under $p $M5)){throw "Protected path overlaps M4: $p"}
 if(Under $Report $p){throw "Report overlaps protected path: $p"}
}
if(Under $Report $M5){throw 'Report cannot be in M5 directory.'}
# A previous attempt may have left an M5 directory or log. Never delete it:
# choose a fresh numbered M5 stage and separate output files automatically.
$baseStage=$M5
$baseReport=$Report
$reportParent=Split-Path -Parent $baseReport
$reportStem=[IO.Path]::GetFileNameWithoutExtension($baseReport)
$reportExt=[IO.Path]::GetExtension($baseReport)
$chosen=$false
for($runNumber=1;$runNumber -le 99;$runNumber++){
 $suffix=if($runNumber -eq 1){''}else{'_R{0:D2}' -f $runNumber}
 $nextStage=$baseStage+$suffix
 $nextReport=Join-Path $reportParent ($reportStem+$suffix+$reportExt)
 $nextManaged=Join-Path $reportParent ('M5_ManagedBuild'+$suffix+'.log')
 $nextNative=Join-Path $reportParent ('M5_NativeBuild'+$suffix+'.log')
 $nextNativeErr=Join-Path $reportParent ('M5_NativeBuild'+$suffix+'.stderr.log')
 if((Test-Path -LiteralPath $nextStage) -or (Test-Path -LiteralPath $nextReport) -or
    (Test-Path -LiteralPath $nextManaged) -or (Test-Path -LiteralPath $nextNative) -or
    (Test-Path -LiteralPath $nextNativeErr)){continue}
 $M5=$nextStage
 $Report=$nextReport
 $managedLog=$nextManaged
 $nativeLog=$nextNative
 $nativeErr=$nextNativeErr
 $chosen=$true
 break
}
if(-not $chosen){throw 'No unused M5 stage/log slot from base through _R99; refusing overwrite.'}
if(-not(Test-Path -LiteralPath $reportParent -PathType Container)){
 throw "M5 report parent does not exist: $reportParent"
}
Write-Host "M5 stage selected: $M5"
Write-Host "M5 report selected: $Report"
if(-not(Test-Path -LiteralPath $Patch -PathType Leaf)){throw "Patch not found: $Patch"}
$baseVersion=Join-Path (Join-Path $M4Base 'cx-windows-x64') 'version.dll'
if(-not(Test-Path -LiteralPath $baseVersion -PathType Leaf) -or
  (Get-FileHash -LiteralPath $baseVersion -Algorithm SHA256).Hash -cne
  '29A719191B9F781A6C37193FFC7C6B8D23ED236C38F8857DD499145EDEFC70E2'){
 throw 'M4 base release does not match the verified M4-rc1 build.'
}
$exclude=@((Join-Path $M4Base 'build'),(Join-Path $M4Base 'cx-windows-x64'),
 (Join-Path $M4Base 'managed\bin'),(Join-Path $M4Base 'managed\obj'))
& robocopy.exe $M4Base $M5 /E /R:0 /W:0 /XD $exclude /XF 'cx-windows-x64.zip' 'build-managed-win.log' | Out-Null
if($LASTEXITCODE -ge 8){throw "Copy failed: $LASTEXITCODE"}
& git.exe -C $M5 apply --check $Patch
if($LASTEXITCODE -ne 0){throw 'M5 patch failed precheck; no build attempted.'}
& git.exe -C $M5 apply $Patch
if($LASTEXITCODE -ne 0){throw 'M5 patch apply failed.'}
$camera=[IO.File]::ReadAllText((Join-Path $M5 'managed\Services\Camera\CameraService.cs'))
$mouse=[IO.File]::ReadAllText((Join-Path $M5 'managed\Services\Camera\MouseLookService.cs'))
if(-not $camera.Contains('internal static bool NpcDialogActive') -or
   -not $camera.Contains('[fpdialog] Driving eye camera held') -or
   -not $mouse.Contains('&& !CameraService.NpcDialogActive')){
 throw 'M5 NPC-dialogue camera/input split markers absent.'
}
Push-Location $M5
try {
 & dotnet.exe build 'managed\cx_managed.csproj' -c Release -r win-x64 -p:PublishAot=false -v:minimal *> $managedLog
 if($LASTEXITCODE -ne 0){throw "M5 managed compile failed. Log: $managedLog"}
 $bash='C:\Program Files\Git\bin\bash.exe'
 if(-not(Test-Path -LiteralPath $bash -PathType Leaf)){throw "Git Bash missing: $bash"}
 $run=Start-Process -FilePath $bash -ArgumentList @('./build-win-native.sh') -WorkingDirectory $M5 -Wait -PassThru -NoNewWindow -RedirectStandardOutput $nativeLog -RedirectStandardError $nativeErr
 if($run.ExitCode -ne 0){throw "M5 NativeAOT failed (exit $($run.ExitCode)). Logs: $nativeLog and $nativeErr"}
} finally { Pop-Location }
$dir=Join-Path $M5 'cx-windows-x64'
$archive=Join-Path $M5 'cx-windows-x64.zip'
if(-not(Test-Path -LiteralPath $archive -PathType Leaf)){throw "Missing M5 ZIP: $archive"}
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip=[IO.Compression.ZipFile]::OpenRead($archive)
try {
 $lines=[Collections.Generic.List[string]]::new()
 $lines.Add('M5 NPC DIALOGUE CAMERA STAGE + NATIVE BUILD: PASS')
 $lines.Add("M5 source: $M5")
 $lines.Add("Managed log: $managedLog")
 $lines.Add("Native stdout: $nativeLog")
 $lines.Add("Native stderr: $nativeErr")
 foreach($name in @('version.dll','cx_openal.dll','phonon.dll','shaderc_shared.dll','vma.dll')){
  $path=Join-Path $dir $name
  if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "Missing M5 DLL: $name"}
  $hash=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
  $entry=@($zip.Entries|Where-Object{$_.FullName -ceq $name})
  if($entry.Count -ne 1){throw "Missing or duplicate M5 ZIP DLL: $name"}
  $stream=$entry[0].Open();$sha=[Security.Cryptography.SHA256]::Create()
  try{$packed=[BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-','').ToLowerInvariant()}
  finally{$stream.Dispose();$sha.Dispose()}
  if($hash -cne $packed){throw "M5 folder/ZIP hash mismatch: $name"}
  if($name -eq 'version.dll' -and $hash -ceq '29a719191b9f781a6c37193ffc7c6b8d23ed236c38f8857dd499145edefc70e2'){
   throw 'M5 version.dll matches the old M4 binary; refusing stale build.'
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
