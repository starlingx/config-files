#
# SPDX-License-Identifier: Apache-2.0
#
# Copyright (C) 2019 Intel Corporation
#
# Where dhcp configuration files are stored
%global dhcpconfdir %{_sysconfdir}/dhcp

Summary: dhcp-config
Name: dhcp-config
Version: 1.0
Release: %{tis_patch_ver}%{?_tis_dist}
License: Apache-2.0
Group: base
Packager: StarlingX
URL: unknown
BuildArch: noarch
Source: %name-%version.tar.gz

Requires: dhclient
Summary: package StarlingX configuration files of dhcp to system folder.

%description
package StarlingX configuration files of dhcp to system folder.

%prep
%setup

%build

%install
%{__install} -d %{buildroot}%{dhcpconfdir}
%{__install} -d  0644 %{buildroot}%{_datadir}/starlingx/
%{__install} -p -m 0755 dhclient-enter-hooks %{buildroot}%{dhcpconfdir}/dhclient-enter-hooks
%{__install} -m 0644 dhclient.conf %{buildroot}%{_datadir}/starlingx/stx.dhclient.conf
ln -s  %{dhcpconfdir}/dhclient-enter-hooks  %{buildroot}%{_sysconfdir}/dhclient-enter-hooks

%post
if [ $1 -eq 1 ] ; then
        # Initial installation
        cp -f %{_datadir}/starlingx/stx.dhclient.conf %{dhcpconfdir}/dhclient.conf
        chmod 644 %{dhcpconfdir}/dhclient.conf
fi

%files
%{_datadir}/starlingx/stx.dhclient.conf
%{dhcpconfdir}/dhclient-enter-hooks
%{_sysconfdir}/dhclient-enter-hooks
