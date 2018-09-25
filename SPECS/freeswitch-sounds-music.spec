%define ARCHIVE_SOURCE_FOLDER freeswitch-sounds
%define SOUNDS_PATH /usr/share/freeswitch/sounds
%define SOUNDS_SUFF music

Name:		freeswitch-sounds-music
Version:	20180515
Release:	1%{?dist}
Summary:	FreeSWITCH Music
Group:		Productivity/Telephony/Servers
License:	MPL
Packager:	FreeSWITCH Solutions <packages@freeswitch.com>
URL:		http://www.freeswitch.org
Source0:	freeswitch-sounds_20180515.orig.tar.xz
BuildArch:	noarch
BuildRequires:	bash, sox, flac
Requires:	freeswitch

%description
This package contains default music for FreeSWITCH.

%prep
%setup -c -n %{ARCHIVE_SOURCE_FOLDER}

%install
install --directory $RPM_BUILD_ROOT/%{SOUNDS_PATH}/%{SOUNDS_SUFF}/flac
install -m644 $RPM_BUILD_DIR/%{ARCHIVE_SOURCE_FOLDER}/%{SOUNDS_SUFF}/flac/*.flac $RPM_BUILD_ROOT/%{SOUNDS_PATH}/%{SOUNDS_SUFF}/flac

%clean
rm -rf $RPM_BUILD_ROOT $RPM_BUILD_DIR/%{ARCHIVE_SOURCE_FOLDER}

%post
for r in 8000 16000 32000 48000; do
  echo "Generating sounds at $r Hz..." >&2
  mkdir -p %{SOUNDS_PATH}/%{SOUNDS_SUFF}/$r
  for f in %{SOUNDS_PATH}/%{SOUNDS_SUFF}/flac/*.flac; do
    [ -f $f ] || continue
    w=${f%.flac}.wav
    flac -s -d -c ${f} | sox -v 0.98 -t wav - -c1 -r${r} -b16 -e signed-integer %{SOUNDS_PATH}/%{SOUNDS_SUFF}/${r}/${w##*/}
  done
done

%preun
for r in 8000 16000 32000 48000; do
  rm -rf %{SOUNDS_PATH}/%{SOUNDS_SUFF}/${r}
done

%files
%{SOUNDS_PATH}/%{SOUNDS_SUFF}/flac/*.flac

%changelog
* Fri May 25 2018 FreeSWITCH Solutions <packages@freeswitch.com> 20180515-1
- Initial release
