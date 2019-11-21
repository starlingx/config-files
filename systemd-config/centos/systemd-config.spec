#
# SPDX-License-Identifier: Apache-2.0
#
# Copyright (C) 2019 Intel Corporation
#
Summary: StarlingX systemd Configuration File
Name: systemd-config
Version: 1.0
Release: %{tis_patch_ver}%{?_tis_dist}
License: Apache-2.0
Group: config-files
Packager: StarlingX
URL: unknown
Source: %name-%version.tar.gz

BuildArch: noarch
BuildRequires: systemd = 219-67.el7
Requires: systemd

%define debug_package %{nil}
%define local_udev_rules_d %{_sysconfdir}/udev/rules.d
%define local_tmpfiles_d %{_sysconfdir}/tmpfiles.d
%define local_systemd_system %{_sysconfdir}/systemd/system

%description
StarlingX systemd configuration file

%prep

%setup

%build

%install
install -d %{buildroot}%{_datadir}/starlingx
install -d %{buildroot}%{local_udev_rules_d}
install -d %{buildroot}%{local_tmpfiles_d}
install -d %{buildroot}%{local_systemd_system}

install -m644 60-persistent-storage.rules %{buildroot}%{local_udev_rules_d}/60-persistent-storage.rules
install -m644 journald.conf %{buildroot}%{_datadir}/starlingx/journald.conf
install -m644 systemd.conf.tmpfiles.d %{buildroot}%{local_tmpfiles_d}/systemd.conf
install -m644 tmp.conf.tmpfiles.d %{buildroot}%{local_tmpfiles_d}/tmp.conf
install -m644 tmp.mount %{buildroot}%{local_systemd_system}/tmp.mount

%post
if [ $1 -eq 1 ] ; then
    cp -f %{_datadir}/starlingx/journald.conf %{_sysconfdir}/systemd
    chmod 644 %{_sysconfdir}/systemd/journald.conf
fi

%files
%defattr(-,root,root)
%license LICENSE
%{local_udev_rules_d}/60-persistent-storage.rules
%{_datadir}/starlingx/journald.conf
%{local_tmpfiles_d}/systemd.conf
%{local_tmpfiles_d}/tmp.conf
%{local_systemd_system}/tmp.mount
