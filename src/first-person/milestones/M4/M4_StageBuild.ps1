# M4: One-step isolated stage and Windows build (no game installation).
# Requires the already validated M3 source and build tools.
[CmdletBinding()]
param(
 [string]$M3='C:\Projects\NWN_FP_M3_BAKED_STAGE',
 [string]$M4='C:\Projects\NWN_FP_M4_ACTION_STAGE',
 [string]$Patch='C:\Projects\M4_MandatoryActionCamera.patch',
 [string]$Report='C:\Projects\M4_StageBuildReport.txt'
)
$ErrorActionPreference='Stop'
$M3=[IO.Path]::GetFullPath($M3);$M4=[IO.Path]::GetFullPath($M4)
$Patch=[IO.Path]::GetFullPath($Patch);$Report=[IO.Path]::GetFullPath($Report)
function Under([string]$x,[string]$p){
 $prefix=$p.TrimEnd([char[]]@([char]'\',[char]'/'))+[IO.Path]::DirectorySeparatorChar
 return $x.Equals($p,[StringComparison]::OrdinalIgnoreCase) -or
        $x.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)
}
foreach($p in @($M3,'C:\Projects\cx','C:\Projects\NWN_FP_M1_J4_STAGE',
 'C:\Projects\NWN_FP_M2_SETTINGS_STAGE','C:\Projects\M1_PreM1_Runtime_Backup',
 'C:\Projects\M3_PreM3_M1_Runtime_Backup',
 'D:\SteamLibrary\steamapps\common\Neverwinter Nights')){
 $p=[IO.Path]::GetFullPath($p)
 if((Under $M4 $p) -or (Under $p $M4)){throw "Protected path overlaps M4: $p"}
 if(Under $Report $p){throw "Report overlaps protected path: $p"}
}
if(Under $Report $M4){throw 'Report cannot be in M4 directory.'}
if(Test-Path -LiteralPath $M4){throw "Refusing existing M4 directory: $M4"}
if(Test-Path -LiteralPath $Report){throw "Refusing existing M4 report: $Report"}
if(-not(Test-Path -LiteralPath $Patch -PathType Leaf)){throw "Patch not found: $Patch"}
$M3Knobs=Join-Path $M3 'managed\Services\Camera\CameraKnobs.cs'
if((Get-FileHash -LiteralPath $M3Knobs -Algorithm SHA256).Hash -cne
 '59881B5270A25F62D75EEFEF82DCE186A262B309D02D24A7563CF793D35250DC'){
 throw 'M3 source hash mismatch; refusing to stage M4.'
}
$exclude=@((Join-Path $M3 'build'),(Join-Path $M3 'cx-windows-x64'),
 (Join-Path $M3 'managed\bin'),(Join-Path $M3 'managed\obj'))
& robocopy.exe $M3 $M4 /E /R:0 /W:0 /XD $exclude /XF 'cx-windows-x64.zip' 'build-managed-win.log' | Out-Null
if($LASTEXITCODE -ge 8){throw "Copy failed: $LASTEXITCODE"}
& git.exe -C $M4 apply --check $Patch
if($LASTEXITCODE -ne 0){throw 'M4 patch failed precheck; no build attempted.'}
& git.exe -C $M4 apply $Patch
if($LASTEXITCODE -ne 0){throw 'M4 patch apply failed.'}
$knobs=[IO.File]::ReadAllText((Join-Path $M4 'managed\Services\Camera\CameraKnobs.cs'))
if(-not $knobs.Contains('internal static bool ActionEnabled => CameraService.Mode == 2 || M.Action.V;') -or
 -not $knobs.Contains('internal static bool LookEnabled => CameraService.Mode == 2 || M.Look.V;')){
 throw 'M4 mandatory Action Camera source markers absent.'
}
$managedLog='C:\Projects\M4_ManagedBuild.log'
$nativeLog='C:\Projects\M4_NativeBuild.log'
if((Test-Path -LiteralPath $managedLog) -or (Test-Path -LiteralPath $nativeLog)){
 throw 'Refusing to overwrite earlier M4 build logs.'
}
Push-Location $M4
try {
 & dotnet.exe build 'managed\cx_managed.csproj' -c Release -r win-x64 -p:PublishAot=false -v:minimal *> $managedLog
 if($LASTEXITCODE -ne 0){throw "M4 managed compile failed. Log: $managedLog"}
 $bash='C:\Program Files\Git\bin\bash.exe'
 if(-not(Test-Path -LiteralPath $bash -PathType Leaf)){throw "Git Bash missing: $bash"}
 $nativeErr='C:\Projects\M4_NativeBuild.stderr.log'
 if(Test-Path -LiteralPath $nativeErr){throw "Refusing to overwrite: $nativeErr"}
 $run=Start-Process -FilePath $bash -ArgumentList @('./build-win-native.sh') -WorkingDirectory $M4 -Wait -PassThru -NoNewWindow -RedirectStandardOutput $nativeLog -RedirectStandardError $nativeErr
 if($run.ExitCode -ne 0){throw "M4 NativeAOT failed (exit $($run.ExitCode)). Logs: $nativeLog and $nativeErr"}
} finally { Pop-Location }
$dir=Join-Path $M4 'cx-windows-x64'
$archive=Join-Path $M4 'cx-windows-x64.zip'
if(-not(Test-Path -LiteralPath $archive -PathType Leaf)){throw "Missing M4 ZIP: $archive"}
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip=[IO.Compression.ZipFile]::OpenRead($archive)
try {
 $lines=[Collections.Generic.List[string]]::new()
 $lines.Add('M4 ACTION CAMERA STAGE + NATIVE BUILD: PASS')
 $lines.Add("M4 source: $M4")
 foreach($name in @('version.dll','cx_openal.dll','phonon.dll','shaderc_shared.dll','vma.dll')){
  $path=Join-Path $dir $name
  if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "Missing M4 DLL: $name"}
  $hash=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
  $entry=@($zip.Entries|Where-Object{$_.FullName -ceq $name})
  if($entry.Count -ne 1){throw "Missing or duplicate M4 ZIP DLL: $name"}
  $stream=$entry[0].Open();$sha=[Security.Cryptography.SHA256]::Create()
  try{$packed=[BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-','').ToLowerInvariant()}
  finally{$stream.Dispose();$sha.Dispose()}
  if($hash -cne $packed){throw "M4 folder/ZIP hash mismatch: $name"}
  if($name -eq 'version.dll' -and $hash -ceq '1ec40d2fd60454dc92e8bfd29ca591600fba0db1d3f5e2ccc4232b09868e891d'){
   throw 'M4 version.dll matches old M3 binary; refusing stale build.'
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
