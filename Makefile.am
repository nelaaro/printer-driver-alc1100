##  Makefile.am -- an automake template for a Makefile.in file
##  Copyright (C) SEIKO EPSON CORPORATION 2003-2006.
##
##  This file is part of the "ESC/PageS-Filter" program.
##
##  The "ESC/PageS-Filter" program is free software.
##  You can redistribute it and/or modify it under the terms of the EPSON
##  AVASYS Public License (versions dated 2005-04-01 or later) as published
##  by EPSON AVASYS Corporation.
##
##  This program is distributed in the hope that it will be useful, but
##  WITHOUT ANY WARRANTY;  without even the implied warranty of FITNESS
##  FOR A PARTICULAR PURPOSE or MERCHANTABILITY.
##  See the EPSON AVASYS Public License for more details.
##
##  You should have received a verbatim copy of the EPSON AVASYS Public
##  License along with this program; if not, write to:
##
##      EPSON AVASYS Corporation.
##      1077-5, Otsu, Shimonogo, Ueda-shi,
##      Nagano-ken 386-1214 JAPAN
##

bin_SCRIPTS = \
	pstoalc1100.sh \
	alc1100_lprwrapper.sh

EXTRA_DIST = \
	alc1100 \
	pstoalc1100.sh \
	alc1100_lprwrapper.sh \
	option.conf \
	ppd/Epson-AL-C1100-fm3.ppd\
	EAPL.en.txt \
	EAPL.ja.txt \
	README-alc1100 \
	README-alc1100-CUPS \
	Epson-ALC1100-filter.spec


redhat9: dist
	cp $(distdir).tar.gz $(rpmdir)/SOURCES
	$(RPMBUILD) --clean --rmsource -ba Epson-ALC1100-filter.spec

install-exec-hook:
	$(mkinstalldirs) $(DESTDIR)$(bindir)
	$(INSTALL_PROGRAM) $(srcdir)/alc1100 $(DESTDIR)$(bindir)
	$(mkinstalldirs) $(DESTDIR)$(sysconfdir)/epkowa/alc1100
	$(INSTALL_DATA) $(srcdir)/option.conf $(DESTDIR)$(sysconfdir)/epkowa/alc1100
	$(mkinstalldirs) $(DESTDIR)$(CUPS_DATA_DIR)/model
	$(INSTALL_DATA) $(srcdir)/ppd/Epson-AL-C1100-fm3.ppd $(DESTDIR)$(CUPS_DATA_DIR)/model

uninstall-hook:
	rm -f $(DESTDIR)$(CUPS_DATA_DIR)/model/Epson-AL-C1100-fm3.ppd
	cp -p $(DESTDIR)$(sysconfdir)/epkowa/alc1100/option.conf \
	      $(DESTDIR)$(sysconfdir)/epkowa/alc1100/option.conf.bak
	rm -f $(DESTDIR)$(sysconfdir)/epkowa/alc1100/option.conf
	rm -f $(DESTDIR)$(bindir)/alc1100

# end of Makefile.am
