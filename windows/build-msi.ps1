<#
.SYNOPSIS
  Build a single FreeSWITCH sound MSI from a built sound tarball.

.DESCRIPTION
  Given a freeswitch-sounds-<voice>-<rate>-<version>.tar.gz produced by dist.pl,
  this:
    1. regenerates the WiX version files from ../dist.pl (single source of truth),
    2. extracts the tarball into libs/sounds/<suffix>/,
    3. runs msbuild on Setup.Sounds.2017.sln to produce the MSI.

  The same script is used locally and by CI (.github/workflows/build-sounds.yml).

  Requires: msbuild on PATH (Visual Studio / setup-msbuild), WiX Toolset v3
  (heat/candle/light), perl, and tar (built into Windows 10+/Server 2019+).

.PARAMETER Tarball
  Path to the freeswitch-sounds-*.tar.gz to package.

.PARAMETER WixTargetsPath
  Optional explicit path to WiX v3 Wix.targets. Defaults to $env:WIX\Wix.targets
  when the WIX environment variable is set (it is after a WiX install).

.OUTPUTS
  The full path of the produced .msi (also written to the pipeline).
#>
param(
  [Parameter(Mandatory = $true)][string]$Tarball,
  [string]$WixTargetsPath = $env:WixTargetsPath,
  [string]$Configuration = "Release",
  [string]$Platform = "x64"
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$fname = Split-Path -Leaf $Tarball
if ($fname -notmatch '^freeswitch-sounds-(.+)-(8000|16000|32000|48000)-([0-9][0-9.]*)\.tar\.gz$') {
  throw "Unexpected tarball name (expected freeswitch-sounds-<voice>-<rate>-<version>.tar.gz): $fname"
}
$voice   = $Matches[1]
$rate    = $Matches[2]
$version = $Matches[3]
$suffix  = ($voice -replace '-', '_') + $rate

Write-Host "Packaging $voice @ ${rate}Hz (version $version), suffix '$suffix'"

# 1. Version files from dist.pl
& perl (Join-Path $here "gen-version-files.pl")
if ($LASTEXITCODE -ne 0) { throw "gen-version-files.pl failed" }

# 2. Clear any stale extraction so the project re-extracts this exact tarball.
$dest = Join-Path $here "libs/sounds/$suffix"
if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }

# 3. Build the MSI. The project's EnsureSoundFiles target extracts $SoundTarball
#    (built-in tar) into libs/sounds/<suffix> before heat runs.
# Only override WixTargetsPath with a file that actually exists; otherwise leave
# it empty so the wixproj's own fallback ($(MSBuildExtensionsPath32)\Microsoft\
# WiX\v3.x\Wix.targets) resolves the standard install location.
if (-not $WixTargetsPath -and $env:WIX -and (Test-Path (Join-Path $env:WIX "Wix.targets"))) {
  $WixTargetsPath = Join-Path $env:WIX "Wix.targets"
}
if ($WixTargetsPath -and -not (Test-Path $WixTargetsPath)) {
  Write-Host "WixTargetsPath '$WixTargetsPath' not found; deferring to the project's default."
  $WixTargetsPath = ""
}

$sln = Join-Path $here "Setup.Sounds.2017.sln"
$msbuildArgs = @(
  $sln,
  "/p:SoundPrimaryName=$voice",
  "/p:SoundQuality=$rate",
  "/p:SoundTarball=$Tarball",
  "/p:Configuration=$Configuration",
  "/p:Platform=$Platform",
  "/t:Build",
  "/verbosity:normal"
)
if ($WixTargetsPath) { $msbuildArgs += "/p:WixTargetsPath=$WixTargetsPath" }

& msbuild @msbuildArgs
if ($LASTEXITCODE -ne 0) { throw "msbuild failed for $voice ${rate}Hz" }

$msi = Join-Path $here "$Platform/FreeSWITCH-Sounds-$voice-$version-${rate}Hz.msi"
if (-not (Test-Path $msi)) { throw "Expected MSI not found: $msi" }
Write-Host "Built $msi"
$msi
