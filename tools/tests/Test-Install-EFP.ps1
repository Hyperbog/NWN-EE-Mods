# Disposable fixture test. Never use an actual game installation or network download.
$ErrorActionPreference='Stop'
$installer=Join-Path $PSScriptRoot '..\Install-EFP.ps1'
$tokens=$null; $errors=$null
[void][System.Management.Automation.Language.Parser]::ParseFile($installer,[ref]$tokens,[ref]$errors)
if($errors.Count){throw ($errors|Out-String)}
$root=Join-Path $env:TEMP ('efp-test-'+[Guid]::NewGuid().ToString('N'))
$gameRoot=Join-Path $root 'game'
$game=Join-Path $gameRoot 'bin\win32'
$work=Join-Path $root 'work'
$payload=Join-Path $root 'payload'
$names=@('version.dll','cx_openal.dll','phonon.dll','shaderc_shared.dll','vma.dll')
function Put($path,$value){[IO.File]::WriteAllText($path,$value)}
function Sha($path){(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()}
function Assert($ok,$message){if(-not $ok){throw $message}}
function Refuse([scriptblock]$action,[string]$reason){
 try{& $action}catch{if($_.Exception.Message -notlike "*$reason*"){throw};return}
 throw "Expected refusal: $reason"
}
# A called script has its own script scope. Use a unique fixture state in this CI process.
if(Get-Variable -Name EfpInstallerFixtureState -Scope Global -ErrorAction SilentlyContinue){throw 'Fixture state already exists'}
$global:EfpInstallerFixtureState=@{downloads=@{};running=$false;processChecks=0;downloadCalls=0}
function Invoke-WebRequest {
 param([switch]$UseBasicParsing,[string]$Uri,[string]$OutFile)
 $global:EfpInstallerFixtureState.downloadCalls++
 if(-not $global:EfpInstallerFixtureState.downloads.ContainsKey($Uri)){throw "Unexpected network request: $Uri"}
 [IO.File]::Copy($global:EfpInstallerFixtureState.downloads[$Uri],$OutFile,$false)
}
function Get-Process {
 param([string]$Name,[string]$ErrorAction)
 $global:EfpInstallerFixtureState.processChecks++
 if($global:EfpInstallerFixtureState.running){[pscustomobject]@{Name='nwmain'}}
}
try{
 foreach($dir in @($game,$payload)){[void][IO.Directory]::CreateDirectory($dir)}
 Put (Join-Path $game 'nwmain.exe') 'synthetic executable'
 Put (Join-Path $game 'cx.cfg') 'keep configuration'
 Put (Join-Path $game 'test.sav') 'keep save'
 $exe=Sha (Join-Path $game 'nwmain.exe')
 $old=[ordered]@{}; $dlls=[ordered]@{}
 foreach($name in $names){
  Put (Join-Path $game $name) "old $name"
  Put (Join-Path $payload $name) "new $name"
  $old[$name]=Sha (Join-Path $game $name)
  $dlls[$name]=@{sha256=(Sha (Join-Path $payload $name));size_bytes=(Get-Item (Join-Path $payload $name)).Length}
 }
 Add-Type -AssemblyName System.IO.Compression.FileSystem
 $package='NWN-EFP-M11-win-x64.zip'
 $zip=Join-Path $root $package
 [IO.Compression.ZipFile]::CreateFromDirectory($payload,$zip)
 $commit='a'*40
 $manifest=@{version='M11';mod_source_commit=$commit;cx_checkpoint='2470f0d27be0a29c152456aa60222f1f4fc25c34';package=$package;package_sha256=(Sha $zip);dlls=$dlls}
 $manifestPath=Join-Path $root 'release-manifest.json'
 $planPath=Join-Path $root 'BUILD_PLAN.json'
 Put $planPath '{"version":"M11"}'
 Put $manifestPath ($manifest|ConvertTo-Json -Depth 8)
 $base="https://github.com/Hyperbog/NWN-EE-Mods/releases/download/efp-M11-$commit"
 $global:EfpInstallerFixtureState.downloads=@{}
 $global:EfpInstallerFixtureState.downloads["https://raw.githubusercontent.com/Hyperbog/NWN-EE-Mods/$commit/src/first-person/BUILD_PLAN.json"]=$planPath
 $global:EfpInstallerFixtureState.downloads["$base/release-manifest.json"]=$manifestPath
 $global:EfpInstallerFixtureState.downloads["$base/$package"]=$zip
 $common=@{SourceCommit=$commit;GamePath=$gameRoot;WorkDir=$work;ExpectedExeSha256=@($exe)}
 $global:EfpInstallerFixtureState.running=$true
 Refuse {& $installer @common} 'Close NWN'
 Assert ($global:EfpInstallerFixtureState.processChecks -gt 0) 'Process mock not invoked'
 Assert ($global:EfpInstallerFixtureState.downloadCalls -eq 0) 'Running-process refusal attempted a download'
 $global:EfpInstallerFixtureState.running=$false
 Refuse {& $installer -SourceCommit $commit -GamePath $gameRoot -WorkDir $work} 'Unsupported nwmain.exe'
 $correct=$manifest.package_sha256
 $manifest.package_sha256='0'*64
 Put $manifestPath ($manifest|ConvertTo-Json -Depth 8)
 Refuse {& $installer @common} 'SHA256 mismatch'
 $manifest.package_sha256=$correct
 Put $manifestPath ($manifest|ConvertTo-Json -Depth 8)
 foreach($name in $names){Assert ((Sha (Join-Path $game $name)) -eq $old[$name]) "Refusal changed $name"}
 & $installer @common
 $results=@(Get-ChildItem -LiteralPath $work -Recurse -Filter install-result.json)
 Assert ($results.Count -eq 1) 'Expected one successful transaction'
 $result=Get-Content -LiteralPath $results[0].FullName -Raw|ConvertFrom-Json
 Assert ($result.version -eq 'M11') 'Version must resolve from manifest'
 foreach($name in $names){
  Assert ((Sha (Join-Path $game $name)) -eq $dlls[$name].sha256) "Install mismatch $name"
  Assert ((Sha (Join-Path $result.backup $name)) -eq $old[$name]) "Backup mismatch $name"
 }
 & $installer -RestoreBackup $result.backup -WorkDir $work -ExpectedExeSha256 $exe
 foreach($name in $names){Assert ((Sha (Join-Path $game $name)) -eq $old[$name]) "Restore mismatch $name"}
 Assert ((Get-Content (Join-Path $game 'cx.cfg') -Raw) -eq 'keep configuration') 'Configuration changed'
 Assert ((Get-Content (Join-Path $game 'test.sav') -Raw) -eq 'keep save') 'Save changed'
 Write-Host 'PASS: portable installer fixture, pinned version, process/hash refusal, backup and rollback.'
}finally{
 Remove-Variable -Name EfpInstallerFixtureState -Scope Global -ErrorAction SilentlyContinue
 Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue
}
