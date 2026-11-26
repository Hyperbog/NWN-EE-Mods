# Install a published EFP release, not a locally compiled DLL. Windows PowerShell 5.1+.
[CmdletBinding(DefaultParameterSetName='Install')]
param(
 [Parameter(Mandatory=$true,ParameterSetName='Install')]
 [ValidatePattern('^[0-9a-f]{40}$')][string]$SourceCommit,
 [Parameter(ParameterSetName='Install')]
 [ValidatePattern('^M[0-9]+(-[A-Za-z0-9]+)?$')][string]$Version='M7',
 [Parameter(Mandatory=$true,ParameterSetName='Restore')]
 [string]$RestoreBackup
)
$ErrorActionPreference='Stop'
$game='D:\SteamLibrary\steamapps\common\Neverwinter Nights\bin\win32'
$root='C:\Projects\NWN_EFP_Packages'
$exeSha='3b7cb1252e0edb2ce22d7971f333aade027039ae30a45b4bc64732c3e6bec73a'
$names=@('version.dll','cx_openal.dll','phonon.dll','shaderc_shared.dll','vma.dll')
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
AssertHash (Join-Path $game 'nwmain.exe') $exeSha
$before=[ordered]@{}
foreach($name in $names){$before[$name]=Hash (Join-Path $game $name)}
[void][IO.Directory]::CreateDirectory($root)
$work=Join-Path $root ([DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss')+'-'+[Guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($work)
$wanted=[ordered]@{}
if($PSCmdlet.ParameterSetName -eq 'Restore'){
 $from=[IO.Path]::GetFullPath($RestoreBackup)
 $prefix=$root.TrimEnd('\')+'\'
 if(-not $from.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw 'Use the backup directory printed by this installer.'}
 $record=Get-Content -LiteralPath (Join-Path $from 'backup.json') -Raw|ConvertFrom-Json
 if($record.game -ne $game -or $record.exe_sha256 -ne $exeSha){throw 'Backup belongs to a different game installation.'}
 foreach($name in $names){
  $wanted[$name]=[string]$record.before.PSObject.Properties[$name].Value
  $installed=[string]$record.after.PSObject.Properties[$name].Value
  if($before[$name] -cne $wanted[$name] -and $before[$name] -cne $installed){throw "Unexpected current DLL: $name"}
 }
 VerifySet $from $wanted
}else{
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
