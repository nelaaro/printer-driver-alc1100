# rpm.spec -- `rpm' based packaging support
# Copyright (C) SEIKO EPSON CORPORATION 2003-2006.
#
# This file is part of the "ESC/PageS-Filter" program.
#
# The "ESC/PageS-Filter" program is free software.
# You can redistribute it and/or modify it under the terms of the EPSON
# AVASYS Public License (versions dated 2005-04-01 or later) as published
# by EPSON AVASYS Corporation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY;  without even the implied warranty of FITNESS
# FOR A PARTICULAR PURPOSE or MERCHANTABILITY.
# See the EPSON AVASYS Public License for more details.
#
# You should have received a verbatim copy of the EPSON AVASYS Public
# License along with this program; if not, write to:
#
#      EPSON AVASYS Corporation.
#      1077-5, Otsu, Shimonogo, Ueda-shi,
#      Nagano-ken 386-1214 JAPAN
#

Summary: Linux Print Filter for the EPSON AL-C1100
Name: Epson-ALC1100-filter
Version: 1.2
Release: 0

License: EPSON AVASYS Public License
URL: http://www.avasys.jp/english/linux_e/.
Group: Applications/Publishing
Source: %{name}-%{version}.tar.gz
Packager: EPSON AVASYS LX Team <pipsplus-bugs@avasys.jp>
Vendor: EPSON AVASYS Corporation <http://www.avasys.jp/english/linux_e/.>
BuildRoot: /tmp/rpm/pane04/%{name}-%{version}
Requires: ghostscript
Requires: psutils
Requires: glibc
Requires: sed
Requires: grep
Requires: gawk
Requires: bc
%description
EPSON AL-C1100 filter for LPR(ng) and CUPS.
This is a printer driver package for EPSON AL-C1100.



%package cups
License: MIT License
Summary: Linux Print Filter for the EPSON AL-C1100 for CUPS
Requires: %{name} = %{version}
Requires: cups >= 1.1.17
Requires: foomatic >= 3.0
Group: Applications/Publishing

%description cups
This package provides Linux Print Filter for the EPSON AL-C1100.
Include PPD file for CUPS and Foomatic Ver.3 for EPSON AL-C1100.

%prep

%setup
    ./configure --prefix=/usr		\
	--mandir=\${prefix}/share/man	\
	--infodir=\${prefix}/share/info	\
	--sysconfdir=/etc \
	--sharedstatedir=/var

%build
#    make CFLAGS="-g -O2" CXXFLAGS="-g -O2"

%clean
    make distclean || true
    rm -rf ${RPM_BUILD_ROOT}

%install
    make install DESTDIR=${RPM_BUILD_ROOT}

%post

%preun

%postun
rmdir %{_sysconfdir}/epkowa/alc1100 2> /dev/null || true
rmdir %{_sysconfdir}/epkowa 2> /dev/null || true

%files
%defattr(-,root,root)
%doc	EAPL.en.txt
%doc	EAPL.ja.txt
%doc	README-alc1100
#%doc	INSTALL
#%doc	NEWS
#%doc	ChangeLog
#%doc	AUTHORS
%{_bindir}/alc1100
%{_bindir}/pstoalc1100.sh
%{_bindir}/alc1100_lprwrapper.sh
%{_sysconfdir}/epkowa/alc1100/option.conf

%files cups
%defattr(-,root,root)
%doc	README-alc1100-CUPS
#%doc	INSTALL
#%doc	NEWS
#%doc	ChangeLog
#%doc	AUTHORS
/usr/share/cups/model/Epson-AL-C1100-fm3.ppd

%changelog
* Thu Nov 16 2006 Avasys <pipsplus-bugs@avasys.jp> 1.2-0
  - fixed "Image Optimum" warning printer panel display.

* Tue Oct 17 2006 Avasys <pipsplus-bugs@avasys.jp> 1.1-0
  - fixed 5mm shift to lower right corner
  - fixed several typos in the PPD file

* Wed Oct 27 2004 epkowa <pipsplus-bugs@epkowa.co.jp> 1.0
  - Initial build
