# M1 source lineage audit, read-only for CX source and Git.
# Compares all 30 original J4 implementation SHA-256 hashes (LF-normalized, no BOM).
# Outputs report OUTSIDE the CX checkout. Requires Windows PowerShell 5.1+ and Git.
[CmdletBinding()]
param(
    [string]$CxRoot = 'C:\Projects\cx',
    [string]$ReportPath
)
$ErrorActionPreference = 'Stop'
$CxRoot = [IO.Path]::GetFullPath($CxRoot)
if (-not (Test-Path -LiteralPath $CxRoot -PathType Container)) {
    throw "Missing CX checkout: $CxRoot"
}
if ([string]::IsNullOrWhiteSpace($ReportPath)) {
    $ReportPath = Join-Path (Split-Path -Parent $CxRoot) 'M1_SourceAudit.txt'
}
$ReportPath = [IO.Path]::GetFullPath($ReportPath)
$inside = $CxRoot.TrimEnd([char]'\', [char]'/') + [IO.Path]::DirectorySeparatorChar
if ($ReportPath.StartsWith($inside, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'The report must be outside the CX checkout.'
}
if (-not (Test-Path -LiteralPath (Split-Path -Parent $ReportPath) -PathType Container)) {
    throw 'Report directory does not exist.'
}

# These hashes are from the original_sha256_lf entries of J4 SOURCE_MANIFEST.json.
$Expected = @{
    'managed/Alloy/AlloyRenderer.Batches.cs' = '5ce74f63e15df014b6d4643532b71c3ffd46d3ec3ed8d2b578b43e4c03f41244'
    'managed/Alloy/Db/DbKeyhole.cs' = 'dd76a33b6458153dd3dd288e482c4c0c05467243c5377c088a22a08f77bc4326'
    'managed/Alloy/Scene/AlloyRenderer.DbPass.cs' = '494d05139541b48d8a0e56ada7b1fbaf097be7a1e1d648c7082268277f6757cd'
    'managed/Alloy/Scene/AlloyRenderer.DbStage.cs' = 'b6849338393f6b278b9cda333678e3b7d2560ac3dd05b04f583a9b79599b1d6a'
    'managed/Framework/ClientApi.cs' = '2894fb6c018e7c635dab8a08bbf23e8b0d6f6c5833f5312d3705d19db4fb16b2'
    'managed/Services/Anim/PoseService.cs' = '8eb5526a4c0c40aa3f7e830303a15a1c312f6b56da27cff6f180d0f7e2d0922c'
    'managed/Services/Camera/ActionFeedback.cs' = '497bea017915970ad4aca73ab38c05152121cc6c891ab15d2e586ff5f705d569'
    'managed/Services/Camera/AnimationCameraMotion.cs' = '1dbdaccffae9942a0b84d344b9a2c76c07fb8be6bfa84751a7d8c7cf3a9d6d1f'
    'managed/Services/Camera/AnimationCameraSettings.cs' = '792bb5c7409cdc94819384054b3cd4914f558a0206c6d82c1209481e80003cbf'
    'managed/Services/Camera/AttackCameraFollow.cs' = 'f8ff34f21b0708ecfc4c9cabda90291ddedb78cdd6b01e20d88c6765906c92ea'
    'managed/Services/Camera/CameraDriveService.cs' = '56c083389bc94cf878e301cc52174dbd0fad1d2daeea3547b43a57664fe563f7'
    'managed/Services/Camera/CameraKnobs.cs' = '3895b9e6cd0497237bc82acb35ae2c20e5139c40d42a9c25e3f6f18980998fb3'
    'managed/Services/Camera/CameraService.cs' = '3c29018f1bccbd34a1f17d855f449b3c5b1d14b362f9c188026591090bc21dc3'
    'managed/Services/Camera/FirstPersonHeadFilter.cs' = 'c92818f6762651ebe713dddb18063c56cff658a700b5b39bba751cf419eedbd1'
    'managed/Services/Camera/FirstPersonModelProbe.cs' = 'edc5e5a2c136dc84184c56c18f9ef4a8e902c2be006c3bd6ac60c80cb34ccf71'
    'managed/Services/Camera/FirstPersonVisibility.cs' = '2a48ec8f1c77116274c89f4ff8fc2d99760941feeb51fc9b7a14110ed6ed9911'
    'managed/Services/Camera/FirstPersonWorldGuard.cs' = 'f82b2f20b1e9f58a5c1014c082f115387a63197f1d11d05ef521009284b89d6c'
    'managed/Services/Camera/Fix14CProbe.cs' = '8ee95b5eb5e68945c1308954f96ee14001f2731fd33900ed6e0c517afa0ac9ed'
    'managed/Services/Camera/HeadBoneCamera.cs' = '1071b53d07e0f4985482954a00d4406b038e5c96c4486c150926217bf2b9a9be'
    'managed/Services/Camera/HeadTrackService.cs' = '30aa5561747a783e0fb51e9e81ba09d764f9bad8b8cd4650f94926d3a80b5811'
    'managed/Services/Camera/JumpPhysics/AirMomentumMotor.cs' = '688b095c802663a14464b46251a12ae2909ccbeae0f2e488d6bde03f44237692'
    'managed/Services/Camera/JumpPhysics/JumpMotor.cs' = '198a10c03e8e9d56b86ed171ff6c76c167f0cf69f83fad08086da26666767b2e'
    'managed/Services/Camera/JumpPhysics/JumpPositionService.cs' = '37f106f64a42e5aebdac6879800cdd139aae0e774722195b4b9faa35064d7de3'
    'managed/Services/Camera/JumpPhysics/JumpPreview.cs' = 'a6d6cc6ada4e654b2374cc65fe8073f3f3477408d0b4104f8da4228766454b49'
    'managed/Services/Camera/JumpPhysics/JumpWalkBridgeService.cs' = '593955ded18cc8c12b4851d50f9c5e00d39085dedb50b9ae5f38c67df9110b36'
    'managed/Services/Camera/JumpPhysics/RayCollisionWorld.cs' = '6c1a4a1c1ae241d71fb8bda1581e57fc822171e13e05de010069ae3bc4ef703e'
    'managed/Services/Camera/MouseLookService.cs' = '656cf769c51aacd37fbf0a4b1a88eeff8e0f8966dc98d096e02ef5e69f23e1fe'
    'managed/Services/Camera/StepGuardService.cs' = '4c0c2158048c260048a1a7ccd30ef3af44d0734b80fc2c0a74fbf65e671cf66a'
    'managed/Services/Camera/UniversalEyeClearance.cs' = 'd7a7b3159d344f8b79a2f1510d75deb5e175b2009c816bcc2f702254c75d63c4'
    'managed/Services/Hotkeys/HotkeyServerLinkService.cs' = 'c7d157484697e71841b8f42230368324c8cf7964b51f06adb03c05f7598db82c'
}
$CameraUpstreamSha256 = 'ef6c5794fcbcd2a2e7b6710b6f552149b72dd455dfc0e825edbdede55a65665e'
$CameraJ4Path = 'managed/Services/Camera/CameraKnobs.cs'

function Get-SourceHash([string]$fullPath) {
    $bytes = [IO.File]::ReadAllBytes($fullPath)
    $utf8 = [Text.UTF8Encoding]::new($false, $true)
    $source = $utf8.GetString($bytes)
    if ($source.Length -gt 0 -and $source[0] -eq [char]0xFEFF) {
        $source = $source.Substring(1)
    }
    $crlf = [string]([char]13) + [string]([char]10)
    $lf = [string]([char]10)
    $norm = $source.Replace($crlf, $lf)
    $hash = [Security.Cryptography.SHA256]::Create()
    try {
        return [BitConverter]::ToString($hash.ComputeHash($utf8.GetBytes($norm))).Replace('-', '').ToLowerInvariant()
    } finally {
        $hash.Dispose()
    }
}

$env:GIT_OPTIONAL_LOCKS = '0'
try {
    $head = (& git -C $CxRoot rev-parse --verify HEAD 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Git HEAD unavailable: $head" }
    $branch = (& git -C $CxRoot branch --show-current 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Git branch unavailable: $branch" }
    $status = @(& git -C $CxRoot status --porcelain=v1 --untracked-files=no -- managed 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "Git status unavailable: $status" }
} finally {
    Remove-Item Env:\GIT_OPTIONAL_LOCKS -ErrorAction SilentlyContinue
}
$changed = @($status | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) }).Count

$lines = New-Object 'System.Collections.Generic.List[string]'
$lines.Add('M1 SOURCE LINEAGE AUDIT (source and Git read-only)')
$lines.Add('Reference: Hyperbog/NWN-EE-Mods src/first-person/SOURCE_MANIFEST.json')
$lines.Add('J4 base: b4b43a54ed68aa1072ce1715c0479b2fb127b5ef')
$lines.Add('Upstream camera reference: nwncxee/cx main @ 66fcc820ef746fdf155b81309f63e7da52d5c865')
$lines.Add("Checkout HEAD: $head")
$lines.Add("Checkout branch: $branch")
$lines.Add("Tracked modified entries under managed/: $changed")
$lines.Add('Comparison: normalized LF/UTF-8, one optional BOM stripped; no source writes.')
$lines.Add('')
$matched = 0
$differ = 0
$missing = 0
foreach ($relative in @($Expected.Keys | Sort-Object)) {
    $target = Join-Path $CxRoot ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
    if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
        $lines.Add("MISSING   $relative")
        $missing++
        continue
    }
    $actual = Get-SourceHash $target
    if ($actual -ceq $Expected[$relative]) {
        $lines.Add("J4-EXACT  $relative  $actual")
        $matched++
    } else {
        $lines.Add("DIFFERENT $relative  $actual")
        $differ++
    }
    if ($relative -eq $CameraJ4Path) {
        if ($actual -ceq $CameraUpstreamSha256) {
            $lines.Add('  CAMERA: exact upstream CX snapshot; J4 settings declarations absent.')
        } elseif ($actual -ceq $Expected[$relative]) {
            $lines.Add('  CAMERA: exact published J4 implementation.')
        } else {
            $lines.Add('  CAMERA: neither published J4 nor known upstream snapshot.')
        }
    }
}
$lines.Add('')
$lines.Add("TOTAL: J4-exact=$matched different=$differ missing=$missing / 30")
$lines.Add('Decision: do not apply M1 settings patch or reconciler before source-lineage review.')
$report = [string]::Join([Environment]::NewLine, $lines)
[IO.File]::WriteAllText($ReportPath, $report + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))
Write-Host $report
Write-Host ''
Write-Host "REPORT: $ReportPath"
