# Install an exact published EFP release. Windows PowerShell 5.1+.
[CmdletBinding(DefaultParameterSetName='Install')]
param(
 [Parameter(Mandatory=$true,ParameterSetName='Install')]
 [ValidatePattern('^[0-9a-f]{40}$')][string]$SourceCommit,
 [Parameter(ParameterSetName='Install')]
 [ValidatePattern('^M[0-9]+(-[A-Za-z0-9]+)?$')][string]$Version,
 [Parameter(Mandatory=$true,ParameterSetName='Restore')][string]$RestoreBackup,
 [string]$GamePath,
 [string]$WorkDir=(Join-Path $env:LOCALAPPDATA 'NWN_EFP_Packages'),
 [ValidateNotNullOrEmpty()][ValidatePattern('^[0-9a-fA-F]{64}$')]
 [string[]]$ExpectedExeSha256=@('3b7cb1252e0edb2ce22d7971f333aade027039ae30a45b4bc64732c3e6bec73a')
)
$ErrorActionPreference='Stop'
$names=@('version.dll','cx_openal.dll','phonon.dll','shaderc_shared.dll','vma.dll')
function FullPath([string]$path){
 if($path -notmatch '^[A-Za-z]:[\\/]'){throw 'Use an absolute local Windows drive path.'}
 $full=[IO.Path]::GetFullPath($path).TrimEnd('\')
 if($full -match '^[A-Za-z]:$'){throw 'Choose a directory rather than an entire drive.'}
 return $full
}
function SafeFolder([string]$path){
 $dir=[IO.DirectoryInfo]::new($path)
 while($null -ne $dir){
  if($dir.Exists -and ($dir.Attributes -band [IO.FileAttributes]::ReparsePoint)){throw "Refusing reparse directory: $($dir.FullName)"}
  $dir=$dir.Parent
 }
}
function FindGame([string]$override){
 $candidates=@()
 if($override){$candidates+=FullPath $override}
 else{
  $steam=@()
  foreach($key in @('HKCU:\Software\Valve\Steam','HKLM:\SOFTWARE\Valve\Steam','HKLM:\SOFTWARE\WOW6432Node\Valve\Steam')){
   $reg=Get-ItemProperty -LiteralPath $key -ErrorAction SilentlyContinue
   if($reg.SteamPath){$steam+=$reg.SteamPath}
   if($reg.InstallPath){$steam+=$reg.InstallPath}
  }
  if($env:ProgramFiles){$steam+=Join-Path $env:ProgramFiles 'Steam'}
  if([Environment]::GetEnvironmentVariable('ProgramFiles(x86)')){$steam+=Join-Path ([Environment]::GetEnvironmentVariable('ProgramFiles(x86)')) 'Steam'}
  foreach($s in ($steam|Select-Object -Unique)){
   $libs=@($s)
   $vdf=Join-Path $s 'steamapps\libraryfolders.vdf'
   if(Test-Path -LiteralPath $vdf -PathType Leaf){
    foreach($m in [regex]::Matches((Get-Content -LiteralPath $vdf -Raw),'(?im)^\s*"(?:path|\d+)"\s*"([^"\r\n]+)"')){
     $lib=$m.Groups[1].Value.Replace('\\','\')
     if($lib -match '^[A-Za-z]:[\\/]'){$libs+=$lib}
    }
   }
   foreach($lib in $libs){$candidates+=Join-Path $lib 'steamapps\common\Neverwinter Nights'}
  }
  foreach($key in @('HKLM:\SOFTWARE\GOG.com\Games','HKLM:\SOFTWARE\WOW6432Node\GOG.com\Games','HKCU:\SOFTWARE\GOG.com\Games','HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall','HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall')){
   foreach($sub in (Get-ChildItem -LiteralPath $key -ErrorAction SilentlyContinue)){
    $reg=Get-ItemProperty -LiteralPath $sub.PSPath -ErrorAction SilentlyContinue
    if(($reg.gameName -match 'Neverwinter Nights.*Enhanced' -or $reg.DisplayName -match 'Neverwinter Nights.*Enhanced')){
     if($reg.path){$candidates+=$reg.path}
     if($reg.InstallLocation){$candidates+=$reg.InstallLocation}
    }
   }
  }
  if($env:SystemDrive){$candidates+=Join-Path ($env:SystemDrive+'\') 'GOG Games\Neverwinter Nights Enhanced Edition'}
 }
 $found=@()
 foreach($candidate in $candidates){
  if($candidate -notmatch '^[A-Za-z]:[\\/]'){continue}
  foreach($folder in @($candidate,(Join-Path $candidate 'bin\win32'))){
   if(Test-Path -LiteralPath (Join-Path $folder 'nwmain.exe') -PathType Leaf){$found+=FullPath $folder}
  }
 }
 $found=@($found|Select-Object -Unique)
 if($found.Count -ne 1){throw "Found $($found.Count) NWN installations. Specify -GamePath with the game root or bin\win32 directory."}
 SafeFolder $found[0]
 return $found[0]
}
function Hash([string]$path){
 if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "Missing file: $path"}
 if((Get-Item -LiteralPath $path -Force).Attributes -band [IO.FileAttributes]::ReparsePoint){throw "Refusing reparse point: $path"}
 return (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
}
function AssertHash([string]$path,[string]$expected){
 if($expected -notmatch '^[0-9a-fA-F]{64}$' -or (Hash $path) -cne $expected.ToLowerInvariant()){throw "SHA256 mismatch: $path"}
}
function Closed {
 if(Get-Process -Name nwmain -ErrorAction SilentlyContinue){throw 'Close NWN:EE completely before installing or restoring.'}
}
function VerifySet([string]$folder,$hashes){
 foreach($name in $names){AssertHash (Join-Path $folder $name) ([string]$hashes[$name])}
}
function WriteJson([string]$path,$value){
 [IO.File]::WriteAllText($path,($value|ConvertTo-Json -Depth 8),[Text.UTF8Encoding]::new($false))
}
function ReplaceSet([string]$from,$wanted,$before,[string]$snapshot){
 VerifySet $from $wanted
 VerifySet $game $before
 Closed
 AssertHash (Join-Path $game 'nwmain.exe') $exeSha
 $changed=[Collections.Generic.List[string]]::new()
 try {
  foreach($name in $names){
   if($before[$name] -ceq $wanted[$name]){continue}
   Closed
   $dest=Join-Path $game $name
   AssertHash $dest $before[$name]
   $id=[Guid]::NewGuid().ToString('N')
   $tmp=Join-Path $game ('.efp-'+$id+'.tmp')
   $displaced=Join-Path $game ('.efp-'+$id+'.'+$name+'.bak')
   [IO.File]::Copy((Join-Path $from $name),$tmp,$false)
   AssertHash $tmp $wanted[$name]
   $changed.Add($name)
   [IO.File]::Replace($tmp,$dest,$displaced)
   AssertHash $dest $wanted[$name]
   AssertHash $displaced $before[$name]
  }
  VerifySet $game $wanted
 }catch{
  $failure=$_.Exception.Message
  Write-Warning "Switch failed: $failure. Attempting restoration from $snapshot"
  try {
   Closed
   foreach($name in $changed){
    $dest=Join-Path $game $name
    if((Hash $dest) -ceq $before[$name]){continue}
    $id=[Guid]::NewGuid().ToString('N')
    $tmp=Join-Path $game ('.efp-recover-'+$id+'.tmp')
    $bak=Join-Path $game ('.efp-recover-'+$id+'.bak')
    [IO.File]::Copy((Join-Path $snapshot $name),$tmp,$false)
    AssertHash $tmp $before[$name]
    [IO.File]::Replace($tmp,$dest,$bak)
   }
   VerifySet $game $before
  }catch{throw "Switch failed and automatic restoration did not complete. Keep backup $snapshot. Error: $_"}
  throw "Switch failed; previous DLLs restored and verified. Error: $failure"
 }
}
Closed
$root=FullPath $WorkDir
SafeFolder $root
if($PSCmdlet.ParameterSetName -eq 'Restore'){
 $from=FullPath $RestoreBackup
 $prefix=$root+'\'
 if(-not $from.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw 'Use the printed backup directory and its original -WorkDir.'}
 SafeFolder $from
 $recordPath=Join-Path $from 'backup.json'
 [void](Hash $recordPath)
 $record=Get-Content -LiteralPath $recordPath -Raw|ConvertFrom-Json
 if(-not $GamePath){$GamePath=[string]$record.game}
 if(-not $GamePath){throw 'Backup has no game directory.'}
}
$game=FindGame $GamePath
if($root -eq $game -or $root.StartsWith($game+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Work directory must not be inside the game executable directory.'}
$exeSha=Hash (Join-Path $game 'nwmain.exe')
if($ExpectedExeSha256 -notcontains $exeSha){throw "Unsupported nwmain.exe SHA256: $exeSha. No game files changed."}
if($PSCmdlet.ParameterSetName -eq 'Restore' -and ($record.game -ne $game -or $record.exe_sha256 -ne $exeSha)){throw 'Backup belongs to a different game installation.'}
$before=[ordered]@{}
foreach($name in $names){$before[$name]=Hash (Join-Path $game $name)}
[void][IO.Directory]::CreateDirectory($root)
$work=Join-Path $root ([DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss')+'-'+[Guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($work)
$wanted=[ordered]@{}
if($PSCmdlet.ParameterSetName -eq 'Restore'){
 foreach($name in $names){
  $wanted[$name]=[string]$record.before.PSObject.Properties[$name].Value
  $installed=[string]$record.after.PSObject.Properties[$name].Value
  if($before[$name] -cne $wanted[$name] -and $before[$name] -cne $installed){throw "Unexpected current DLL: $name"}
 }
 VerifySet $from $wanted
}else{
 # The immutable source plan locates the release; the release manifest supplies the version.
 if(-not $Version){
  $planFile=Join-Path $work 'BUILD_PLAN.json'
  Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/$SourceCommit/src/first-person/BUILD_PLAN.json" -OutFile $planFile
  $plan=Get-Content -LiteralPath $planFile -Raw|ConvertFrom-Json
  $Version=[string]$plan.version
  if($Version -cnotmatch '^M[0-9]+(-[A-Za-z0-9]+)?$'){throw 'Invalid version in pinned build plan.'}
 }
 $tag="efp-$Version-$SourceCommit"
 $base="https://github.com/Hyperbog/NWN-EE-Mods/releases/download/$tag"
 $package="NWN-EFP-$Version-win-x64.zip"
 $manifestFile=Join-Path $work 'release-manifest.json'
 $zipFile=Join-Path $work $package
 try{Invoke-WebRequest -UseBasicParsing -Uri "$base/release-manifest.json" -OutFile $manifestFile}
 catch{throw "Release $tag is not accessible. Check GitHub Actions/Releases. No game files changed. $_"}
 $manifest=Get-Content -LiteralPath $manifestFile -Raw|ConvertFrom-Json
 if($manifest.version -cne $Version -or $manifest.mod_source_commit -cne $SourceCommit -or
    $manifest.cx_checkpoint -cne '2470f0d27be0a29c152456aa60222f1f4fc25c34' -or $manifest.package -cne $package){
  throw 'Release manifest does not identify the requested source commit and package.'
 }
 $Version=[string]$manifest.version
 Invoke-WebRequest -UseBasicParsing -Uri "$base/$package" -OutFile $zipFile
 AssertHash $zipFile ([string]$manifest.package_sha256)
 $from=Join-Path $work 'package'
 [void][IO.Directory]::CreateDirectory($from)
 Add-Type -AssemblyName System.IO.Compression
 Add-Type -AssemblyName System.IO.Compression.FileSystem
 $zip=[IO.Compression.ZipFile]::OpenRead($zipFile)
 try{
  foreach($name in $names){
   $item=$manifest.dlls.PSObject.Properties[$name].Value
   $wanted[$name]=[string]$item.sha256
   $entry=@($zip.Entries|Where-Object{$_.FullName -ceq $name})
   if($entry.Count -ne 1 -or $entry[0].Length -ne $item.size_bytes){throw "Invalid ZIP member: $name"}
   [IO.Compression.ZipFileExtensions]::ExtractToFile($entry[0],(Join-Path $from $name),$false)
  }
 }finally{$zip.Dispose()}
 VerifySet $from $wanted
}
Closed
VerifySet $game $before
$backup=Join-Path $work 'previous-runtime'
[void][IO.Directory]::CreateDirectory($backup)
foreach($name in $names){[IO.File]::Copy((Join-Path $game $name),(Join-Path $backup $name),$false)}
VerifySet $backup $before
WriteJson (Join-Path $backup 'backup.json') ([ordered]@{game=$game;exe_sha256=$exeSha;before=$before;after=$wanted})
Write-Host "ROLLBACK BACKUP: $backup"
ReplaceSet $from $wanted $before $backup
WriteJson (Join-Path $work 'install-result.json') ([ordered]@{result='SWITCHED_AND_VERIFIED';source_commit=$SourceCommit;version=$Version;before=$before;after=$wanted;backup=$backup})
Write-Host "SWITCHED_AND_VERIFIED; version.dll SHA256=$($wanted['version.dll'])"
Write-Host "Game configuration unchanged. Start NWN:EE for gameplay testing."
