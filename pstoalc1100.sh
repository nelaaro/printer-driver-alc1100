#!/bin/bash
#  pstoalc1100.sh -- PostScript to ALC1100-ESC/PageS-filter
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
DEBUG="off"
PSOUT="off"
WORKF="off"
TOP=/tmp
#TOP=${TMPDIR:=/tmp}
TMPFILE="$TOP/pstoalc1100"

ARGS="$@"

# for debug
#DEBUG="on"
#PSOUT="on"
#WORKF="on"

WORKFLAG="${TMPFILE}_at_work_now"
clear_work_flag=""
if test "$WORKF" = "on" ; then
    clear_work_flag=" ; test -f $WORKFLAG && rm -f $WORKFLAG"
    while test -f $WORKFLAG ; do sleep 2 ; done
    sleep 2 && touch $WORKFLAG
fi

LOG=${TMPFILE}.log
test "$DEBUG" = "on" && echo $0 $ARGS > $LOG

tee0="" && test "$DEBUG" = "on" && tee0="| tee ${TMPFILE}In.ps"
tee1="" && test "$DEBUG" = "on" && tee1="| tee ${TMPFILE}1.ps"
tee2="" && test "$DEBUG" = "on" && tee2="| tee ${TMPFILE}2.ps"
tee3="" && test "$DEBUG" = "on" && tee3="| tee ${TMPFILE}3.ps"
tee8="" && test "$DEBUG" = "on" && tee8="| tee ${TMPFILE}Out.ps"
tee9="" && test "$DEBUG" = "on" && tee9="| tee ${TMPFILE}.ras"

# get option value
optvalue()
{
    test -z "$1" && return 1
    KEY="$1"
    test -z "$(echo $ARGS | grep $KEY= )" && return 1
    VALUE=$(echo $ARGS | sed -e "s,^.*${KEY}=\\([^ ,\$]*\\).*,\\1,")
    return 0
}

# error message out
msgerr()
{
    cont=0 && test x"$1" = x"-n" && cont=1 && shift
    a="$@"
    test 0 -ne $# && echo -n "$@" >&2
    test 0 -eq $cont && echo "" >&2
    return 0
}

# log message out
msglog()
{
    test "$DEBUG" = "on" && echo "$@" >> $LOG
    return 0
}

#
# START MAIN
#

# Paper size in 600dpi
XY600="" && optvalue XY600 && XY600=$VALUE && msglog "XY600=$XY600"
test -z "$XY600" && msgerr "ERROR: $0: Un-known paper size" && exit 1

# Output resolution.
Resolution="" && optvalue Resolution && Resolution=$VALUE && msglog "Resolution=$Resolution"
test -z "$Resolution" && msgerr "ERROR: $0: Un-known output resolution" && exit 1
Resolution=$(echo $Resolution | sed -e 's,^*[^[:digit:]],,;s,[^[:digit:]]*$,,')

# other options
PageSize=""  && optvalue PageSize  && PageSize=$VALUE  && msglog "PageSize=$PageSize"
Rotate=""    && optvalue Rotate    && Rotate=$VALUE    && msglog "Rotate=$Rotate"
Duplex=""    && optvalue Duplex    && Duplex=$VALUE    && msglog "Duplex=$Duplex"
Color=""     && optvalue Color     && Color=$VALUE     && msglog "Color=$Color"
MediaType="" && optvalue MediaType && MediaType=$VALUE && msglog "MediaType=$MediaType"
TonerSave="" && optvalue TonerSave && TonerSave=$VALUE && msglog "TonerSave=$TonerSave"
InputSlot="" && optvalue InputSlot && InputSlot=$VALUE && msglog "InputSlot=$InputSlot"
Copies=""    && optvalue Copies    && Copies=$VALUE    && msglog "Copies=$Copies"
Collate=""   && optvalue Collate   && Collate=$VALUE   && msglog "Collate=$Collate"
collatefile="-"
numcopies=1

# Output Printable area width/height in 600dpi.
LogX600="$(echo $XY600 | sed 's,x.*$,,')"
LogY600="$(echo $XY600 | sed 's,^.*x,,')"
msglog "LogX600=$LogX600" "LogY600=$LogY600"

# Logical Printable area width/height in PS unit (1/72 inch).
LogX72=$(echo "scale=6; a=$LogX600*72/600; scale=0; b=a/1; scale=6; c=a-b; if(c>0.444444) b+1 else b" | bc)
LogY72=$(echo "scale=6; a=$LogY600*72/600; scale=0; b=a/1; scale=6; c=a-b; if(c>0.444444) b+1 else b" | bc)
msglog "LogX72=$LogX72" "LogY72=$LogY72"

# if hardware rotate paper then swap X and Y.
if test x"$Rotate" = x"90";then
    X600=$LogY600
    Y600=$LogX600
    X72=$LogY72
    Y72=$LogX72
else
    X600=$LogX600
    Y600=$LogY600
    X72=$LogX72
    Y72=$LogY72
fi
msglog "X600=$X600" "Y600=$Y600"
msglog "X72=$X72" "Y72=$Y72"

# output printable area in output resolution unit(dot)
Xdot=$(echo "a=$X600*$Resolution/600; scale=0; b=a/1; scale=4; c=a-b; if(c>0.4444) b+1 else b" | bc)
Ydot=$(echo "a=$Y600*$Resolution/600; scale=0; b=a/1; scale=4; c=a-b; if(c>0.4444) b+1 else b" | bc)
msglog "Xdot=$Xdot" "Ydot=$Ydot"

# Duplex and rotation
useRotator="on"
if test x"$Rotate" = x"90";then
    # default duplex = long edge
    pstops1="-w$LogY72 -h$LogY72"
    if test x"$Duplex" = x"DuplexNoTumble"; then
	pstops2="2:R1\(0,$Y72\),R0\(0,$Y72\)"
    else
	if test x"$Duplex" = x"DuplexTumble"; then
	    pstops2="2:L1\($X72,0\),R0\(0,$Y72\)"
	else
	    pstops2="1:R0\(0,$Y72\)"
	fi
    fi
else
    # default duplex = short edge
    pstops1="-w$X72 -h$Y72"
    if test x"$Duplex" = x"DuplexNoTumble"; then
	pstops2="2:1U\($X72,$Y72\),0"
    else
	if test x"$Duplex" = x"DuplexTumble"; then
	    pstops2="2:1,0"
	else
	    pstops2="1:0"
	    useRotator="off"
	fi
    fi
fi

# color/grayscale out control.
if test x"$Color" = x"black"; then
    gs1="-sDEVICE=bit -dGrayValues=256"
else
    gs1="-sDEVICE=bitrgb -dRedValues=256"
fi

gs2="-r$Resolution -g${Xdot}x${Ydot}"


# create ESC/PageS filter option argument.
opt="-o Width:${Xdot} -o Height:${Ydot}"
if test x"$Resolution" = x"300"; then
    opt="$opt -o QualityAuto:fast"
else
    opt="$opt -o QualityAuto:fine"
fi
if test x"$Duplex" = x"DuplexTumble"; then
    opt="$opt -o Duplex:top"
else
    if test x"$Duplex" = x"DuplexNoTumble"; then
    opt="$opt -o Duplex:left"
    fi
fi
test -n "$Color" && opt="$opt -o Color:$Color"
test -n "$PageSize" && opt="$opt -o PaperSize:$PageSize"
test -n "$MediaType" && opt="$opt -o PaperType:$MediaType"
test -n "$InputSlot" && opt="$opt -o PaperSource:$InputSlot"
test -n "$TonerSave" && opt="$opt -o TonerSave:$TonerSave"
if test 1 -ge $((Copies)); then
    Copies="0"
else
    if test "$Collate" = "on"; then
	collatefile="$( mktemp $TOP/alc1100.XXXXXX )"
	cat > $collatefile
	numcopies=$((Copies))
    else
	test -n "$Copies" && opt="$opt -o Copies:$Copies"
    fi
fi

msglog "collatefile=$collatefile"
msglog "numcopies=$numcopies"

rotator="" && test "$useRotator" = "on" && rotator="| pstops -q $pstops1 $pstops2"
rasterizer="| gs -q -dBATCH -dPARANOIDSAFER -dNOPAUSE $gs1 $gs2 -sOutputFile=- -"
escpagesfilter="| alc1100 $opt" && test "$PSOUT" = "on" && escpagesfilter=""

cmd="\
cat $collatefile \
$tee0 $rotator \
$tee8 $rasterizer \
$tee9 $escpagesfilter \
$clear_work_flag"


# execute transration.
page=1
while test 0 -ne $((numcopies));do
    msglog "page=$page numcopies=$numcopies"
    sh -c "$cmd"
    numcopies=$((numcopies -1))
    page=$((page +1))
done

test $collatefile != "-" && rm -f $collatefile

# for debug
msglog "[ Command ]"
msglog "$cmd"
msglog "[ Emulation ]"
msglog "cat ${TMPFILE}In.ps $rotator > d1.ps"
msglog "cat d1.ps $rasterizer > d2.ras"
msglog "cat d2.ras $escpagesfilter > d3.prn"
msglog "[ View ]"
msglog "gs -q -r72 -g${LogX72}x${LogY72} -dBATCH -sDEVICE=x11 ${TMPFILE}In.ps"
msglog "gs -q -r72 -g${X72}x${Y72} -dBATCH -sDEVICE=x11 ${TMPFILE}Out.ps"
if test x"$Color" = x"black"; then
    TYPE="Gray"
else
    TYPE="RGB"
fi
msglog "convert -depth 8 -size ${Xdot}x${Ydot} $TYPE:${TMPFILE}.ras pstoalc1100.png"
msglog "done"

exit 0
# end of script
