#!/bin/sh
#!/usr/local/bin/bash
#                ^^^^ use it for testing for Linux compatibility
#
# edit-qr.qxyz.ru qrdb tree backup subsystem
# 
# (c) Alex V Eustrop & EustroSoft.org 2020
#
# LICENSE: BALES, ISC, MIT, BSD on your choice 
#
# derived from: qrdb_process.sh

QRDB_ROOT=/s/qrdb/
QRDB_PATH=${QRDB_ROOT}/QR.QXYZ.RU/
RSYNC_REMOTE_PATH=durin.qxyz.ru://s/qrdb/
TCSV_TOOLS_BIN=/s/proj/edit.qr.qxyz.ru/bin/
QRDB_TOOLS_BIN=$TCSV_TOOLS_BIN
# tools
CMD_TCSVQL=${TCSV_TOOLS_BIN}/tcsvql.awk
CMD_TCSV_GET_CURRENT=${TCSV_TOOLS_BIN}/tcsv_get_current.awk
CMD_PSPN_CI=${TCSV_TOOLS_BIN}/pspn_ci.sh
AWK=/usr/bin/awk
#
QRDB_PATH_MEMBERS=${QRDB_PATH}/members/
QRDB_PATH_LOG_FILE=${QRDB_PATH}/log/run.log
STDERR=/dev/stderr
STDOUT=/dev/stdout
STDLOG=$STDOUT
#local variables
IS_SOMETHING_CHANGED=none; # SIC! unimpelemented, use it if some files changed rebuilded so rsync remote is needed
# your can redefine any config vars above here:
if [ -r /etc/qrdb.conf ]; then # load global config
	. /etc/qrdb.conf
fi
if [ -r /usr/local/etc/qrdb.conf ]; then # load local config too
	. /usr/local/etc/qrdb.conf
fi
if [ "${HOME}/etc/" != "/etc/" ]; then # load local user's config over all previous
 if [ -r "${HOME}/etc/qrdb.conf" ]; then
  . "${HOME}/etc/qrdb.conf"
 fi
fi

#qrdb.mk
usage()
{
	echo "$QRDB_TOOLS_BIN/qrdb_process.sh " #SIC! imperfect
}
print_qrdb_env()
{
echo QRDB_ROOT=${QRDB_ROOT}	"# /s/qrdb/"
echo QRDB_PATH=${QRDB_PATH}	"# \${QRDB_ROOT}/QR.QXYZ.RU/"
echo RSYNC_REMOTE_PATH=${RSYNC_REMOTE_PATH}	"# durin.qxyz.ru://s/qrdb/"
echo TCSV_TOOLS_BIN=${TCSV_TOOLS_BIN}	"# /s/proj/edit.qr.qxyz.ru/bin/"
echo QRDB_TOOLS_BIN=${QRDB_TOOLS_BIN}	"# \$TCSV_TOOLS_BIN"
echo "# tools"
echo CMD_TCSVQL=${CMD_TCSVQL}	"# ${TCSV_TOOLS_BIN}/tcsvql.awk"
echo CMD_TCSV_GET_CURRENT=${CMD_TCSV_GET_CURRENT}	"# \${TCSV_TOOLS_BIN}/tcsv_get_current.awk"
echo CMD_PSPN_CI=${CMD_PSPN_CI}	"# \${TCSV_TOOLS_BIN}/pspn_ci.sh"
echo AWK=${AWK}	"# /usr/bin/awk"
echo "#"
echo QRDB_PATH_MEMBERS=${QRDB_PATH_MEMBERS}	"# \${QRDB_PATH}/members/"
echo QRDB_PATH_LOG_FILE=${QRDB_PATH_LOG_FILE}	"# \${QRDB_PATH}/log/run.log"
echo STDERR=${STDERR}	"# /dev/stderr"
echo STDOUT=${STDOUT}	"# /dev/stdout"
echo STDLOG=${STDLOG}	"# \$STDOUT"
}
do_log()
{
#echo $* >$STDLOG
}
do_errlog()
{
echo "ERROR: " $* >$STDERR
}
# use: fatal "msg" # to abort processing
fatal()
{
echo "FATAL ERROR: " $* >$STDERR
exit 1
}
check_tools()
{
if [ ! -x $CMD_TCSVQL ]; then
 fatal "$CMD_TCSVQL not exists or not executable, set CMD_TCSVQL"
fi
if [ ! -x $CMD_TCSV_GET_CURRENT ]; then
 fatal "$CMD_TCSV_GET_CURRENT not exists or not executable, set CMD_TCSV_GET_CURRENT"
fi
if [ ! -x $CMD_PSPN_CI ]; then
 fatal "$CMD_PSPN_CI not exists or not executable, set CMD_PSPN_CI"
fi
}
# find all members
rsync_remote4backup()
{
rsync -arlv $QRDB_ROOT/BACKUP $RSYNC_REMOTE_PATH
}
#make_all_pub.sh
BAK_FILENAME=`date "+%Y-%m-%d-%H%M"`.tgz

print_qrdb_env
tar -czf ${QRDB_ROOT}/BACKUP/${BAK_FILENAME} ${QRDB_PATH}
rsync_remote4backup

#rsync_remote

