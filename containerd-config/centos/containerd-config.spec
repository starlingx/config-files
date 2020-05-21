Summary: StarlingX Containerd Configuration File
Name: containerd-config
Version: 1.0
Release: %{tis_patch_ver}%{?_tis_dist}
License: Apache-2.0
Group: config-files
Packager: StarlingX
URL: unknown

Source0: %{name}-%{version}.tar.gz

Requires: containerd

BuildArch: noarch

%define debug_package %{nil}

%description
StarlingX containerd configuration file

%prep
%setup

%install
install -d -m 755 %{buildroot}%{_sysconfdir}/pmon.d/
install -p -m 644 containerd-pmon.conf %{buildroot}%{_sysconfdir}/pmon.d/containerd.conf
install -d -m 755 %{buildroot}%{_sysconfdir}/systemd/system/containerd.service.d/
install -p -m 644 containerd-stx-override.conf %{buildroot}%{_sysconfdir}/systemd/system/containerd.service.d/

%files
%defattr(-,root,root)
%license LICENSE
%dir %{_sysconfdir}/systemd/system/containerd.service.d
%{_sysconfdir}/pmon.d/containerd.conf
%{_sysconfdir}/systemd/system/containerd.service.d/containerd-stx-override.conf
