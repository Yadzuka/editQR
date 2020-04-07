#!/bin/sh
#
# edit-qr.qxyz.ru qrdb tree publishing subsystem
# pspn_ci is wrapper on RCS (rcs&ci) tools
# use it for preserving file content before overwriting
#
# Usage:
#       pspn_ci.sh filename
# Bugs: only one filename possible, no custom options supported
# 
# (c) Alex V Eustrop & EustroSoft.org 2020
#
# LICENSE: BALES, ISC, MIT, BSD on your choice 
#

FILE=$1
STDERR=/dev/stderr
RCS_STORE=RCS
CMD_RCS=rcs
CMD_CI=ci

# use: fatal "msg" # to abort processing
fatal()
{
echo "FATAL ERROR: " $* >$STDERR
exit 1
}

# 1. check if no passed file
if [ "${FILE}x" = "x" ]; then
 fatal "no filename passed"
fi
# 2. if file not exists or not readable
if [ ! -r "${FILE}" ]; then
 fatal "file not readable : $FILE"
fi
# 3. prepare names for next stage
BASENAME=`basename "$FILE"`
BASEDIR=`dirname "$FILE"`
RCSDIR="$BASEDIR/$RCS_STORE"
RCSFILE="$RCSDIR/$BASENAME,v"
# 4. create RCS direcory on no one
if [ ! -d "${RCSDIR}" ]; then
 mkdir -p $RCSDIR
 if [ ! -d "${RCSDIR}" ]; then
  fatal "no RCS/ directory : $RCSDIR"
 fi
fi
# 5. init RCS store for file & SET IT STORE MODE TO "BINARY" !!!
if [ ! -r "${RCSFILE}" ]; then
 $CMD_RCS -kb -t-pspn_ci_init -i -q $FILE
 if [ ! -r "${RCSFILE}" ]; then
  fatal " RCS file not readable : $RCSFILE"
 fi
fi
# 6. store file version
$CMD_CI -mpspn_ci -q -l $FILE
# 7. report about success
echo ok $RCSFILE
#HAPPY KONEC!
