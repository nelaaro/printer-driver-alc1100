#!/bin/bash
#  alc1100_lprwrapper.sh -- LPR(ng) wrapper filter for ALC1100-ESC/PageS-filter
#  Copyright (C) SEIKO EPSON CORPORATION 2003-2006.
#
#  This file is part of the Epson-ALC1100-filter.
#
#  The Epson-ALC1100-filter is free software.
#  You can redistribute it and/or modify it under the terms of the EPSON
#  AVASYS Public License (versions dated 2005-04-01 or later) as published
#  by EPSON AVASYS Corporation.
#
#  This program is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY;  without even the implied warranty of FITNESS
#  FOR A PARTICULAR PURPOSE or MERCHANTABILITY.
#  See the EPSON AVASYS Public License for more details.
#
#  You should have received a verbatim copy of the EPSON AVASYS Public
#  License along with this program; if not, write to:
#
#      EPSON AVASYS Corporation
#      1077-5 Ostu Shimonogo
#      Ueda Nagano 386-1214  JAPAN
#
# !Caution: This script work on "bash" only.
declare -a PaperList[0]
declare -a PaperIndex[0]
declare -a SizeList[0]

DEBUG="off"
#DEBUG="on"
#THROUGH="on"
DATADIR=/etc/epkowa/alc1100
TOP=/tmp
#TOP=${TMPDIR:=/tmp}

ARGS="$@"

OPTKEY=" \
    PageSize\
    InputSlot\
    Resolution\
    Duplex\
    Color\
    TonerSave\
    MediaType\
    Copies\
"

# Paper size parameters for EPSON AL-C1100
PaperList=(\
"PageSize=a4     XY600=4960x7016" \
"PageSize=b5     XY600=4300x6072" \
"PageSize=a5     XY600=3496x4960" \
"PageSize=lt     XY600=5100x6600" \
"PageSize=hlt    XY600=3300x5100" \
"PageSize=exe    XY600=4350x6300" \
"PageSize=glt    XY600=4800x6300" \
"PageSize=mon    XY600=2324x4500 Rotate=90" \
"PageSize=ib5    XY600=4156x5905" \
"PageSize=env10  XY600=2474x5700" \
"PageSize=envdl  XY600=2598x5196 Rotate=90" \
"PageSize=envc5  XY600=3826x5408" \
"PageSize=envc6  XY600=2692x3826 Rotate=90" \
)

SizeList=(\
"-w595.2 -h841.92 -W595.2 -H841.92" \
"-w516 -h728.64 -W516 -H728.64" \
"-w419.52 -h595.2 -W419.52 -H595.2" \
"-w612 -h792 -W612 -H792" \
"-w396 -h612 -W396 -H612" \
"-w522 -h756 -W522 -H756" \
"-w576 -h756 -W576 -H756" \
"-w278.88 -h540 -W278.88 -H540" \
"-w498.72 -h708.6 -W498.72 -H708.6" \
"-w296.88 -h684 -W296.88 -H684" \
"-w311.76 -h623.52 -W311.76 -H623.52" \
"-w459.12 -h648.96 -W459.12 -H648.96" \
"-w323.04 -h459.12 -W323.04 -H459.12" \
)

PaperIndex=( ${PaperList[*]/ */} )


default_opt=""
test -f $DATADIR/option.conf && default_opt="$(cat $DATADIR/option.conf | sed '/^#/d')"

# DEBUG message out
LOG=$TOP/alc1100_lprwrapper.log

test "$DEBUG" = "on" && echo $0 $ARGS > $LOG

# log message out
msglog()
{
    test "$DEBUG" = "on" && echo "$@" >> $LOG
    return 0
}

# get option value
optvalue()
{
    test -z "$1" && return 1
    KEY="$1"
    test -z "$(echo $ARGS | grep $KEY= )" && return 1
    VALUE=$(echo $ARGS | sed -e "s,^.*${KEY}=\\([^ ,\$]*\\).*,\\1,")
#    msglog "optval: $KEY=$VALUE"
    return 0
}

# get option value
default_value()
{
    test -z "$1" && return 1
    KEY="$1"
    test -z "$(echo $default_opt | grep $KEY= )" && return 1
    VALUE=$(echo $default_opt | sed -e "s,^.*${KEY}=\\([^ \$]*\\).*,\\1,")
    msglog "default: $KEY=$VALUE"
    return 0
}

#
# get paper size strings
# ex) get_paper_size "PageSize=a4"
#     return: A4 paper size setting parameter strings.
#
get_paper_size()
{
    test -z "$1" && return 1
    n=0
    while test -n "${PaperIndex[$((n))]}" \
	-a "${PaperIndex[$n]}" != "$1"
      do n=$((n +1))
    done
    paper_size="${PaperList[$n]}"
    adjust_args="${SizeList[$n]}"
    msglog "paper_size=$paper_size"
    return 0
}


# ----------------------------------------
#
# MAIN START
#

filter_args=""

for key in $OPTKEY; do
    v="" && optvalue $key && v=$VALUE && msglog "$key=$v"
    if test "$key" = "PageSize";then
	VALUE="$v" && test -z "$v" && default_value $key
	paper_size="" && adjust_args="" && get_paper_size "$key=$VALUE"
	filter_args="$filter_args $paper_size"
    else
	if test -z "$v"; then
	    default_value $key && filter_args="$filter_args $key=$VALUE"
	else
	    filter_args="$filter_args $key=$v"
	fi
    fi
done


tee0="" && test "$DEBUG" = "on" && tee0="tee $TOP/alc1100_lprwrapper.ps | "
sizeadjust="psresize -q $adjust_args | " && test x"$THROUGH" = x"on" && sizeadjust=""
filtercmd="pstoalc1100.sh $filter_args"
cmd="$tee0 $sizeadjust $filtercmd"

sh -c "$cmd"

msglog "$cmd"

#end of file
