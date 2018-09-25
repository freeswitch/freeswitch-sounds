%define ARCHIVE_SOURCE_FOLDER freeswitch-sounds
%define SOUNDS_PATH /usr/share/freeswitch/sounds
%define SOUNDS_SUFF en/US/allison
%define SOUNDS_SUFF_LC en/us/allison
%define SOUND_CATEGORIES alt ascii base256 conference currency digits directory ivr misc time voicemail zrtp

Name:		freeswitch-sounds-en-us-allison
Version:	20180515
Release:	1%{?dist}
Summary:	FreeSWITCH Sounds en-US Allison
Group:		Productivity/Telephony/Servers
License:	MPL
Packager:	FreeSWITCH Solutions <packages@freeswitch.com>
URL:		http://www.freeswitch.org
Source0:	freeswitch-sounds_20180515.orig.tar.xz
BuildArch:	noarch
BuildRequires:	bash, sox, flac
Requires:	freeswitch

%description
This package contains en-US Allison sounds for FreeSWITCH.

%prep
%setup -c -n %{ARCHIVE_SOURCE_FOLDER}

%install
for d in %{SOUND_CATEGORIES}; do
  install --directory $RPM_BUILD_ROOT/%{SOUNDS_PATH}/%{SOUNDS_SUFF_LC}/${d}/flac
  install -m644 $RPM_BUILD_DIR/%{ARCHIVE_SOURCE_FOLDER}/%{SOUNDS_SUFF}/${d}/flac/*.flac $RPM_BUILD_ROOT/%{SOUNDS_PATH}/%{SOUNDS_SUFF_LC}/${d}/flac/
done

%clean
rm -rf $RPM_BUILD_ROOT $RPM_BUILD_DIR/%{ARCHIVE_SOURCE_FOLDER}

%post
for r in 8000 16000 32000 48000; do
  echo "Generating sounds at ${r} Hz..." >&2
  for d in %{SOUNDS_PATH}/%{SOUNDS_SUFF_LC}/*; do
    [ -d ${d} ] || continue
    mkdir -p ${d}/${r}
    for f in ${d}/flac/*.flac; do
      [ -f ${f} ] || continue
      w=${f%.flac}.wav
      flac -s -d -c ${f} | sox -v 0.95 -t wav - -c1 -r${r} -b16 -e signed-integer ${d}/${r}/${w##*/}
    done
  done
done

%preun
for r in 8000 16000 32000 48000; do
  for d in %{SOUND_CATEGORIES}; do
    rm -rf %{SOUNDS_PATH}/%{SOUNDS_SUFF_LC}/${d}/${r}
  done
done

%postun
find %{SOUNDS_PATH}/%{SOUNDS_SUFF_LC}/ -type d -empty -delete

%files
%{SOUNDS_PATH}/%{SOUNDS_SUFF_LC}/*/flac/*.flac

%changelog
* Fri May 25 2018 FreeSWITCH Solutions <packages@freeswitch.com> 20180515-1
- Initial release
