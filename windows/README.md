# Windows MSI packaging

Builds Windows installers (`.msi`) for the FreeSWITCH sound packages. Ported
from `freeswitch` `w32/Setup/Sounds` so this repository can produce its own
Windows artifacts without cloning freeswitch and without `files.freeswitch.org`.

## Contents

| File | Purpose |
|------|---------|
| `Setup.Sounds.2017.sln` / `.wixproj` | WiX v3 project that produces one MSI per package+rate |
| `Product.wxs` | WiX product definition (installs into `Program Files\FreeSWITCH\sounds`) |
| `basedir.props` | Sets `BaseDir` to this `windows/` folder |
| `build/sounds_upgradecode.txt` | **Stable** per-package upgrade-code GUIDs (copied verbatim from freeswitch — do not regenerate, or upgrades break) |
| `gen-version-files.pl` | Generates `build/sounds_version.txt` + `build/moh_version.txt` from `../dist.pl` |
| `docs/COPYING.rtf` | EULA shown by the installer |
| `build-msi.ps1` | Builds a single MSI from a `dist.pl` tarball; used locally and by CI |
| `build_sounds.cmd` | Builds all (or named) packages × 4 rates locally (ported from freeswitch) |

`dist.pl` is the single source of truth for versions; the `*_version.txt` files
are generated from it and are git-ignored.

## How it differs from the freeswitch original

The freeswitch project downloaded the sound tarball **and** `7za` from
`files.freeswitch.org` during the MSI build. Here the `EnsureSoundFiles` target
in the wixproj sources the tarball from (in order) an explicit
`/p:SoundTarball=`, `dist.pl`'s local output, or the **GitHub release**, and
extracts it with built-in `tar`. So `msbuild` still works out of the box, with
no `files.freeswitch.org` and no `7za` dependency.

## Building locally

Requires Visual Studio (msbuild), [WiX Toolset v3](https://wixtoolset.org/), and
`curl`/`tar` (built into Windows 10+). `perl` only if you need to regenerate the
version files after editing `dist.pl`.

```powershell
# Convenience wrapper (regenerates version files, builds one MSI from a tarball):
./build-msi.ps1 -Tarball ..\freeswitch-sounds-en-us-callie-48000-1.0.53.tar.gz
```

Or build whole packages at all four rates (`msbuild` is auto-detected via
`vswhere`, so a plain Command Prompt works). The project fetches each payload
itself:

```bat
build_sounds.cmd                    :: every package, all rates
build_sounds.cmd music              :: just music
build_sounds.cmd en-us-callie music :: a subset
```

Or drive `msbuild` directly — the project fetches/extracts the payload itself:

```powershell
# Uses a local tarball if present (dist.pl output in the repo root or .\dist\),
# otherwise downloads it from the GitHub release:
msbuild Setup.Sounds.2017.sln /p:SoundPrimaryName=en-us-callie /p:SoundQuality=8000 /p:Configuration=Release /p:Platform=x64

# Or point it at a specific tarball:
msbuild Setup.Sounds.2017.sln /p:SoundPrimaryName=en-us-callie /p:SoundQuality=8000 /p:SoundTarball=E:\path\freeswitch-sounds-en-us-callie-8000-1.0.53.tar.gz /p:Configuration=Release /p:Platform=x64

# Override the release host (e.g. a fork) with /p:SoundReleaseBaseUrl=...
```

The resulting `FreeSWITCH-Sounds-<voice>-<version>-<rate>Hz.msi` is written to
`windows/x64/`.

## CI

`.github/workflows/build-sounds.yml` builds the tarballs on Linux, then a
Windows job runs `build-msi.ps1` for each tarball and attaches the MSIs to the
same per-package-version GitHub Release as the tarballs.
