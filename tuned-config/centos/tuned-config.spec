Summary: StarlingX Tuned Configuration File
Name: tuned-config
Version: 1.0
Release: %{tis_patch_ver}%{?_tis_dist}
License: Apache-2.0
Group: config-files
Packager: StarlingX
URL: unknown

Source0: %{name}-%{version}.tar.gz

Requires: tuned
BuildArch: noarch

%define debug_package %{nil}

%description
StarlingX tuned configuration file

%prep
%setup

%install
install -d -m 755 %{buildroot}%{_sysconfdir}/systemd/system/tuned.service.d/
install -p -m 644 tuned-stx-override.conf %{buildroot}%{_sysconfdir}/systemd/system/tuned.service.d/
install -d -m 755 %{buildroot}%{_sysconfdir}/tuned/starlingx/
install -d -m 755 %{buildroot}%{_sysconfdir}/tuned/starlingx-realtime/
install -p -m 644 tuned.conf %{buildroot}%{_sysconfdir}/tuned/starlingx/
install -p -m 644 tuned-realtime.conf %{buildroot}%{_sysconfdir}/tuned/starlingx-realtime/tuned.conf
install -p -m 644 recommend.conf %{buildroot}%{_sysconfdir}/tuned/

%files
%defattr(-,root,root)
%license LICENSE
%dir %{_sysconfdir}/systemd/system/tuned.service.d
%{_sysconfdir}/systemd/system/tuned.service.d/tuned-stx-override.conf
%dir %{_sysconfdir}/tuned/starlingx
%config %{_sysconfdir}/tuned/starlingx/tuned.conf
%dir %{_sysconfdir}/tuned/starlingx-realtime
%config %{_sysconfdir}/tuned/starlingx-realtime/tuned.conf
%config(noreplace) %{_sysconfdir}/tuned/recommend.conf
