#
# SPDX-License-Identifier: Apache-2.0
#
# Copyright (C) 2022  Wind River Systems, Inc.
#
Summary: python-siteconfig
Name: python-siteconfig
Version: 1.0
Release: %{tis_patch_ver}%{?_tis_dist}
License: Apache-2.0
Group: base
Packager: StarlingX
URL: unknown
BuildArch: noarch
Source: %name-%version.tar.gz

%define pythonroot           /usr/lib64/python2.7/site-packages
%define stx_app_plugind      /var/stx_app/plugins

Summary: package StarlingX configuration files for additional site-package.

%description
package StarlingX configuration files for additional site-package.

%prep
%setup

%build

%install
mkdir -p %{pythonroot}
%{__install} -p -D -m 0755 sitecustomize.py %{buildroot}%{pythonroot}/sitecustomize.py

%post

%files
%defattr(-,root,root,-)
%{pythonroot}/sitecustomize.py
%{pythonroot}/sitecustomize.pyc
%{pythonroot}/sitecustomize.pyo
