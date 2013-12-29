dnl  configure.ac -- an autoconf template for the ./configure script
dnl  Copyright (C) SEIKO EPSON CORPORATION 2003-2006.
dnl
dnl  This file is part of the "ESC/PageS-Filter" program.
dnl
dnl  The "ESC/PageS-Filter" program is free software.
dnl  You can redistribute it and/or modify it under the terms of the EPSON
dnl  AVASYS Public License (versions dated 2005-04-01 or later) as published
dnl  by EPSON AVASYS Corporation.
dnl
dnl  This program is distributed in the hope that it will be useful, but
dnl  WITHOUT ANY WARRANTY;  without even the implied warranty of FITNESS
dnl  FOR A PARTICULAR PURPOSE or MERCHANTABILITY.
dnl  See the EPSON AVASYS Public License for more details.
dnl
dnl  You should have received a verbatim copy of the EPSON AVASYS Public
dnl  License along with this program; if not, write to:
dnl
dnl      EPSON AVASYS Corporation.
dnl      1077-5, Otsu, Shimonogo, Ueda-shi,
dnl      Nagano-ken 386-1214 JAPAN
dnl

dnl  preamble

AC_PREREQ(2.53)
AC_INIT(Epson-ALC1100-filter, 1.2, pipsplus-bugs@avasys.jp)
        dnl  sets the shell variables PACKAGE_NAME and PACKAGE_VERSION
        dnl  so use these below whenever needed

AM_INIT_AUTOMAKE($PACKAGE_NAME,$PACKAGE_VERSION)

AM_CONFIG_HEADER(config.h)
AC_CONFIG_SRCDIR(alc1100)

dnl  checks for programs

AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_AWK

AC_CHECK_PROG(RPMBUILD, rpmbuild, rpmbuild)
rpmdir=`rpm --eval %_topdir`
AC_SUBST(rpmdir)

AC_CHECK_PROG(have_cups_config, cups-config, yes)
if test $have_cups_config = yes; then
   CUPS_CFLAGS=`cups-config --cflags`
   CUPS_LDFLAGS=`cups-config --ldflags`
   CUPS_LIBS=`cups-config --libs`
   CUPS_IMAGE_LIBS=`cups-config --image --libs`
   CUPS_SERVER_DIR=`cups-config --serverbin`
   CUPS_DATA_DIR=`cups-config --datadir`
else
   AC_MSG_ERROR([*** 'cups-config' missing, please install CUPS or fix your \$PATH ***])
fi
AC_SUBST(CUPS_CFLAGS)
AC_SUBST(CUPS_LDFLAGS)
AC_SUBST(CUPS_LIBS)
AC_SUBST(CUPS_IMAGE_LIBS)
AC_SUBST(CUPS_SERVER_DIR)
AC_SUBST(CUPS_DATA_DIR)

dnl  appendix

AC_CONFIG_FILES( Makefile )
AC_OUTPUT
