#!/bin/sh
#!/usr/local/bin/bash
#                ^^^^ use it for testing for Linux compatibility
#
# edit-qr.qxyz.ru qrdb tree publishing subsystem
# 
# (c) Alex V Eustrop & EustroSoft.org 2020
#
# LICENSE: BALES, ISC, MIT, BSD on your choice 
#
# derived from: qrdb.mk make_all_pub.sh dominator0101A.mk master2list master.list.csv.tab d.sh

QRDB_ROOT=/s/qrdb/
QRDB_PATH=${QRDB_ROOT}/QR.QXYZ.RU/
RSYNC_REMOTE_PATH=durin.qxyz.ru://s/qrdb/
TCSV_TOOLS_BIN=/s/proj/yadzuka/edit.qr.qxyz.ru/bin/
# tools
CMD_TCSVQL=${TCSV_TOOLS_BIN}/tcsvql.awk
CMD_TCSV_GET_CURRENT=${TCSV_TOOLS_BIN}/tcsv_get_current.awk
CMD_PSPN_CI=${TCSV_TOOLS_BIN}/pspn_ci.sh
AWK=/usr/bin/awk
#
QRDB_PATH_MEMBERS=${QRDB_PATH}/members/
QRDB_PATH_LOG_FILE=${QRDB_PATH}/log/run.log
STDERR=/dev/stderr
# your can redefine any config vars here:
#. /etc/qrdb.conf
#. /usr/local/etc/qrdb.conf

#qrdb.mk
usage()
{
	echo "use: make all|pub" #SIC! wrong
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
get_list_of_members()
{
QRDB_PATH_MEMBERS=$1
ls -F $QRDB_PATH_MEMBERS | $AWK '/\/$/{print}'
}
get_list_of_ranges()
{
MEMBER_PATH=$1
ls -F $MEMBER_PATH | $AWK '(($1~/([0-9ABCDEF])+\//)){print}' # SIC! not-fully-correct
}
get_list_of_master_files()
{
#echo master.list.csv
ls -F $1/ | $AWK '/^master..*csv$/{print}'
}
get_name_of_csv_tab_file()
{
echo master.list.csv.tab
}
get_result_file4master()
{
echo qrlist.tcsv
}
get_result_file4master_compat2019()
{
if [ "${1}x" != "x" ]; then
 MASTER_BASE_NAME=`basename $1`
fi
if [ "${MASTER_BASE_NAME}x" = "master.list.csvx" ]; then
echo list.csv
fi
}
rsync_remote()
{
rsync -arlv $QRDB_PATH $RSYNC_REMOTE_PATH
}
make_master_file()
{
 MASTER_FILE=$1
 MASTER_FILE_DIR=`dirname $1`
 MASTER_FILE_TAB=$MASTER_FILE_DIR/`get_name_of_csv_tab_file $MASTER_FILE`
 RESULT_FILE="$MASTER_FILE_DIR/"`get_result_file4master $MASTER_FILE`
 RESULT_FILE_COMPAT2019=`get_result_file4master_compat2019 $MASTER_FILE`
 RESULT_FILE_COMPAT2019_FULL="$MASTER_FILE_DIR/${RESULT_FILE_COMPAT2019}"
 echo "    master_file: " $MASTER_FILE "tab_file:" $MASTER_FILE_TAB "result_file:" $RESULT_FILE
 if [ ! -r $RESULT_FILE ]; then
  touch $RESULT_FILE
 fi
 $CMD_PSPN_CI $RESULT_FILE
 #cat $MASTER_FILE_TAB $MASTER_FILE | $CMD_TCSV_GET_CURRENT | $CMD_TCSVQL # SIC! do NOT ENABLE
 #print_master_file_bundle $MASTER_FILE_TAB $MASTER_FILE | $CMD_TCSVQL
 if [ "${RESULT_FILE_COMPAT2019}x" != "x" ]; then
  if [ ! -r $RESULT_FILE_COMPAT2019_FULL ]; then
   touch $RESULT_FILE_COMPAT2019_FULL
  fi
  $CMD_PSPN_CI $RESULT_FILE_COMPAT2019_FULL
 fi
}
make_all_range_master_files()
{
D=${1}
echo $DIR
FILE_LIST=`get_list_of_master_files $D`
for F in $FILE_LIST; do
 echo "  file : " $F
 make_master_file $D$F
done 
}
make_all_member_ranges()
{
DIR=$1
RANGES_LIST=`get_list_of_ranges $DIR `
echo "ranges: " $RANGES_LIST
for R in $RANGES_LIST; do
 echo " range : " $R
 make_all_range_master_files ${DIR}${R}
done 
}
make_all_members()
{
check_tools
MEMBERS_LIST=`get_list_of_members $QRDB_PATH_MEMBERS`
echo "members: " $MEMBERS_LIST
for M in $MEMBERS_LIST; do
 echo "member : " $M
 make_all_member_ranges $QRDB_PATH_MEMBERS$M
done 
}

print_master_file_bundle()
{
FILE_CSV_TAB=$1
FILE_CSV=$2
#echo $FILE_CSV_TAB $FILE_CSV

echo "#!CSV_TAB"
if [ -r $FILE_CSV_TAB ]; then
 cat $FILE_CSV_TAB
else
 print_default_master_tab
fi
#echo DATA
echo "#!CSV_DATA"
cat $FILE_CSV | $CMD_TCSV_GET_CURRENT
#	cat master.list.csv | ../bin/get_tcsv_current | ../bin/master2list >list.csv
}


print_default_master_tab()
{
cat <<EOF
# Default master.list.csv.tab for edit.qr.qxyz.ru
#Атрибут	Значение	Значение2/код
NAME	QR_QXYZ.Item	QI
OBJECT	None	Q
HEADER	STD_PSPNHEANOR
PARENT	none	NN
CHILD	none	NN
#Код	Поле	Тип	Атрибуты	Название	Описание
01	ZRID	text	NN,	ZRID	ZRID - идентификатор объекта (записи) в файле, записи с одинаковым ZRID - разные версии одной записи
02	ZVER	text	NUL,	ZVER	ZVER - номер версии записи 
03	ZDATE	text	NUL,	ZDATE	ZDATE - дата порождения данной версии
04	ZUID	text	NUL,	ZUID	ZUID - пользователь, записавший версию
05	ZSTA	text	NUL,	ZSTA	ZSTA - статус 'N' - актуальная, 'C' - устаревшая, 'D' - удаленная
06	QR	text	PUB,NUL,SHOW,HEX,QR,QR_KEY,QRANGE_WARN,	QR код	QR код должен содержать ровно 8 символов, алфавит [0-9,A-F], первые 5 - это диапазон, оставшиеся 3 - номер внутри диапазона в 16-ричном
07	cnum	text	PUB,NUL,SHOW,	№ договора	для новых номеров можно использовать последние 4 символа QR-кода. допустимо несколько карточек с одним номером договора
08	cdate	text	PUB,NUL,	дата договора	дата заключения договора
09	cmoney	text	NUL,SHOW,QRMONEY,	Деньги по договору	Деньги, причитающиеся поставщику, по договору за это изделие. Если изделий по договору несколько - заполняйте отдельные карточки
10	supplier	text	NUL,DIC,	Юр-лицо поставщик	кто исполнитель по договору, если у нас более одного юр-лица или ИП
11	client	text	NUL,SHOW,	Юр-лицо клиент	Юр-лицо клиента, пока только название, но можете добавить ИНН, через запятую, или еще что-то. Последним укажите город. Напр: EustroSoft,...,Москва
12	prodtype	text	PUB,NUL,DIC,SHOW,QRPRODTYPE,	Тип продукта	Тип продукта.
13	prodmodel	text	PUB,NUL,DIC,SHOW,QRPRODMODEL,	Модель продукта	Модель продукта
14	sn	text	PUB,NUL,SHOW,EN,	SN	Серийный номер изделия. Возможно - серийные номера агрегатов через запятую. Потом разберемся
15	prodate	text	PUB,NUL,	Дата производства	Дата производства изделия
16	GTD	text	NUL,	Дата ввоза (ГТД)	Сейчас - номер ГТД. Изначально хотели указывать дату ввоза в Россию, или дату поступления на склад.
17	saledate	text	PUB,NUL,	Дата продажи	Дата продажи - видимо дата поступления денег или гарантийного письма об оплате 
18	sendate	text	PUB,NUL,QRMONEYGOT,	Дата отправки клиенту	Дата отправки клиенту/отгрузки со склада. Обычно - это-же дата начала гарантии
19	wstart	text	PUB,NUL,	Дата начала гарантии	Дата начала гарантии для конечного пользователя. т.е. при продажи дилером - задается им
20	wend	text	PUB,NUL,	Дата окончания гарантии	Дата окончания гарантии. Обычно + 1 год, но нет правил без исключений
21	comment	text	PUB,NUL,TEXTAREA,	Комментарий (для клиента)	Этот комментарий виден клиенту! конфиденциальное пишите в поле Деньги
EOF
}
hello()
{
echo hello
}
#make_all_pub.sh
#!/bin/sh

#date >>  /s/qrdb/log/make_all_pub.log
#cd /s/qrdb &&  make all pub >> /s/qrdb/log/make_all_pub.log

make_all_members
#print_default_master_tab

