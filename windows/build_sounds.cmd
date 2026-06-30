@ECHO OFF
REM Build FreeSWITCH sound MSIs locally for every package, or for the package(s)
REM named as arguments. Adapted from freeswitch w32/Setup/Sounds/build_sounds.cmd:
REM   * msbuild is auto-detected (PATH or vswhere) - no w32\msbuild.cmd needed,
REM   * version data is regenerated from ..\dist.pl when perl is available,
REM   * the wixproj's EnsureSoundFiles target fetches/extracts each payload from
REM     a local dist.pl tarball or the GitHub release - no files.freeswitch.org.
REM
REM Requires: Visual Studio or Build Tools, WiX Toolset v3, curl/tar (Windows 10+).
REM
REM Usage:
REM   build_sounds.cmd                      :: build all packages, all 4 rates
REM   build_sounds.cmd music                :: just music
REM   build_sounds.cmd en-us-callie music   :: a subset
SETLOCAL EnableDelayedExpansion

set "HERE=%~dp0"
set "SOLUTION=%HERE%Setup.Sounds.2017.sln"
set "CODES=%HERE%build\sounds_upgradecode.txt"
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"

REM --- locate msbuild (PATH first, then vswhere so a plain cmd works) ---
set "MSBUILD="
for /f "delims=" %%i in ('where msbuild 2^>NUL') do if not defined MSBUILD set "MSBUILD=%%i"
if not defined MSBUILD if exist "%VSWHERE%" for /f "usebackq delims=" %%i in (`"%VSWHERE%" -latest -prerelease -products * -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do if not defined MSBUILD set "MSBUILD=%%i"
if not defined MSBUILD goto :nomsbuild
echo Using msbuild: "%MSBUILD%"

REM --- refresh version data from dist.pl (optional; needs perl) ---
where perl >NUL 2>&1
if errorlevel 1 goto :noperl
call perl "%HERE%gen-version-files.pl"
if errorlevel 1 goto :genfail
goto :aftergen
:noperl
echo perl not found; using the committed version files.
:aftergen

REM --- choose packages: args, or every package in sounds_upgradecode.txt ---
if not "%~1"=="" goto :args
for /F "usebackq tokens=1 delims= " %%a in ("%CODES%") do call :Build %%a
goto :done
:args
if "%~1"=="" goto :done
call :Build %~1
shift
goto :args

:done
echo.
echo Done. MSIs (if built) are in "%HERE%x64".
goto :end

:nomsbuild
echo ERROR: could not find msbuild. Install Visual Studio or Build Tools.
goto :end
:genfail
echo ERROR: gen-version-files.pl failed.
goto :end

REM --- build one package at all four rates ---
:Build
echo.
echo ============================================================
echo  Building %~1
echo ============================================================
for %%R in (8000 16000 32000 48000) do call :BuildRate %~1 %%R
goto :eof

:BuildRate
echo === %~1 %~2 Hz ===
"%MSBUILD%" "%SOLUTION%" /p:SoundPrimaryName=%~1 /p:SoundQuality=%~2 /p:Configuration=Release /p:Platform=x64 /t:Build /verbosity:normal
goto :eof

:end
ENDLOCAL
