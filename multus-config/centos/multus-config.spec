#
# SPDX-License-Identifier: Apache-2.0
#
# Copyright (C) 2020 Wind River Systems, Inc.
#
Summary: multus-config
Name: multus-config
Version: 1.0
Release: %{tis_patch_ver}%{?_tis_dist}
License: Apache-2.0
Group: base
Packager: StarlingX
URL: unknown
BuildArch: noarch
Source: %name-%version.tar.gz

Summary: package StarlingX configuration files of multus to system folder.

%description
package StarlingX configuration files of multus to system folder.

%prep
%setup

%install
%{__install} -d %{buildroot}%{_sysconfdir}/logrotate.d
%{__install} -m 0644 multus.logrotate        %{buildroot}%{_sysconfdir}/logrotate.d/multus.logrotate


%files
%{_sysconfdir}/logrotate.d/multus.logrotate
