Summary: StarlingX Dmesg Configuration File
Name: dmesg-config
Version: 1.0
Release: %{tis_patch_ver}%{?_tis_dist}
License: Apache-2.0
Group: config-files
Packager: StarlingX
URL: unknown

Source0: %{name}-%{version}.tar.gz

BuildArch: noarch

%define debug_package %{nil}

%description
StarlingX dmesg configuration file

%prep
%setup

%install
install -d -m 755 %{buildroot}%{_sysconfdir}/systemd/system/rhel-dmesg.service.d/
install -p -m 644 rhel-dmesg-stx-override.conf %{buildroot}%{_sysconfdir}/systemd/system/rhel-dmesg.service.d/

%files
%defattr(-,root,root)
%license LICENSE
%dir %{_sysconfdir}/systemd/system/rhel-dmesg.service.d
%{_sysconfdir}/systemd/system/rhel-dmesg.service.d/rhel-dmesg-stx-override.conf
