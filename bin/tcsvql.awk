#!/usr/bin/awk -f
#
# edit.qr.qxyz.ru
# *.list.csv processing tool
# usage : tcsvql.awk -v QUERY=EXEC:QRQXYZ_MASTER2LIST -v TABOUT=/p/to/list.csv.tab -v CSVOUT=/p/to/list.csv
# Supported queries:
#	EXEC:CAT - (default) read data stream, decode it and encode to output again (works like /bin/cat but with some QC)
#	EXEC:INSERT_FIELD:NF - insert field to position NF
#	EXEC:QRQXYZ_MASTER2QRLIST - convert tcsv data to public qrlist.tcsv with leading QR field keeping PUB only fields
#	EXEC:QRQXYZ_MASTER2LIST2019 - convert tcsv data to legacy public list.csv with leading QR field keeping PUB only fields
#	EXEC:QRQXYZ_QUERY_ROW:QRCODE - find row with given QRCODE and print it as csv row
#	EXEC:QRQXYZ_QUERY_ROW_WIKI:QRCODE - find row with given QRCODE and print it as wiki (.tab file needed)
#
# (с) Alex V Eustrop & EustroSoft.org 2020
#
# This code imported from ConcepTIS
#  ConcepTIS:src/sql/PGSQL/codegen/tools/codegen.awk
#
# where it was licensed as:
# ConcepTIS project
# (c) Alex V Eustrop 2009-2019
#  see LICENSE at the ConcepTIS project's root directory
#
# Relicensed by author (Eustrop 2020-03-31)
# LICENSE: BALES, ISC, MIT, BSD on your choice 
#


BEGIN{
if(QUERY=="") QUERY="EXEC:CAT";
parse_query(QUERY,QUERY_PARTS);
TRUE=1;
FALSE=0;
#print QUERY;
FS="\t";
} #/BEGIN
function parse_query(q,	qp,qp_count)
{
qp_count=split(q,qp,":");
if(q=="EXEC:CAT") return;
if(q=="EXEC:QRQXYZ_MASTER2QRLIST") return;
if(q=="EXEC:QRQXYZ_MASTER2LIST2019") return;
if(qp[1] == "EXEC")
{
 if(qp[2] == "QRQXYZ_QUERY_ROW") { return; }
 if(qp[2] == "QRQXYZ_QUERY_ROW_WIKI") { return; }
}
do_abort("Query:" q " not implemented");
}
END{
if(is_aborted)exit 1;
is_begun=1; # used by do_abort
WDIR="work/"
STD_HEADER_OFFSET=7;
#make_create_table(WDIR "/tables/" SHORT_NAME ".sql");
#make_csv_tab("/dev/stdout");
} #/END
/^#!CSV_DATA/{ # process data rows
 if(QUERY == "EXEC:CAT") {
  make_csv_tab("/dev/stdout");
  print "#!CSV_DATA" 
  process_data_cat();
 }
 else if(QUERY == "EXEC:QRQXYZ_MASTER2QRLIST") {
  make_csv_tab("/dev/stdout", TRUE);
  print "#!CSV_DATA" 
  process_data_pub();
 }
 else if(QUERY == "EXEC:QRQXYZ_MASTER2LIST2019") {
  #make_csv_tab("/dev/stdout", TRUE);
  print "#QR;PRODTYPE;MODEL;SN;prodate;SALEDATE;DEPARTUREDATE;CONTRACTNUM;contractdate;WARRANTYSTART;WARRANTYEND;COMMENT"
  print "#!CSV_DATA" 
  process_data_pub2019();
 }
 else if(QUERY_PARTS[1] == "EXEC") {
  if(QUERY_PARTS[2] == "QRQXYZ_QUERY_ROW"){
   process_data_query_qrrow();
  }
  if(QUERY_PARTS[2] == "QRQXYZ_QUERY_ROW_WIKI"){
   process_data_query_qrrow_wiki();
  }
 }
 next;
}
/^#!CSV_TAB/{next;} # process csv.tab data rows
/^[ \t]*#/{next;} # comments
($1=="NAME"){NAME=$2;CODE=$3;
	n2=split(NAME,tmp_a,".");
	SUBSYS=tmp_a[1];SHORT_NAME=tmp_a[2];
	if(SHORT_NAME==""){SHORT_NAME = NAME; SUBSYS="SAM";}
	next;
	}
($1=="HEADER"){HEADER=$2;
	if(!is_value_in(HEADER,"STD_HEADER","STD_HEANOR","STD_PSPNHEANOR"))
	 do_abort("invalid HEADER: " HEADER);
	next;}
($1=="PARENT"){PARENT=$2;PARENT_CODE=$3;
	n2=split(PARENT,tmp_a,".");
	PARENT_SUBSYS=tmp_a[1];PARENT_SHORT_NAME=tmp_a[2];
	next;}
($1=="CHILD"){
	CHILD_COUNT++; # CHILDREN is to long ;)
	CHILD_NAME[CHILD_COUNT]=$2;
	CHILD_CODE[CHILD_COUNT]=$3;
	n2=split(CHILD_NAME[CHILD_COUNT],tmp_a,".");
	CHILD_SUBSYS[CHILD_COUNT]=tmp_a[1];
	CHILD_SHORT_NAME[CHILD_COUNT]=tmp_a[2];
	if(CHILD_SHORT_NAME[CHILD_COUNT] == ""){
	 CHILD_SUBSYS[CHILD_COUNT] = "TISC";
	 CHILD_SHORT_NAME[CHILD_COUNT]=CHILD_NAME[CHILD_COUNT];
	}
	next;
	}
($1=="PKEY"){do_abort("PKEY token unallowed for object records");}
($1=="OBJECT"){OBJECT_NAME=$2;OBJECT=$3;next;}
($1=="MAXREC"){MAXREC=$2;next;}
($1=="MINREC"){MINREC=$2;next;}
#($1=="QCM"){QCM=$2;if(QCM=="")QCM="QCM_" CODE;next;}
#($1=="FQCM"){FQCM=$2;if(FQCM=="")FQCM="FQCM_" CODE;next;}
($1=="INDEX"){INDEX_COUNT++;INDEX[INDEX_COUNT]=$2;next;}
($1~"[0-9][0-9]"){ # FIELD
	FIELDS_COUNT++;
	f_no[FIELDS_COUNT]=$1;
	f_name[FIELDS_COUNT]=$2;
	f_type[FIELDS_COUNT]=$3;
	f_attrib[FIELDS_COUNT]=$4;
	f_caption[FIELDS_COUNT]=$5;
	f_desc[FIELDS_COUNT]=$6;
	f_NN[FIELDS_COUNT]=1; # NOT NULL by default
	n=split($4,tmp_attrib,",");
	for(i=1;i<=n;i++){
	 n2=split(tmp_attrib[i],tmp_a,"=");
         if(tmp_a[1]=="") continue;
         if(tmp_a[1]=="QR"){f_QR[FIELDS_COUNT]=1; continue;}
         if(tmp_a[1]=="QR_KEY"){ if(QR_KEY == "") { QR_KEY=FIELDS_COUNT; } continue;} # use only first QR_KEY SIC!
         if(is_value_in(tmp_a[1],"DECSEQ","HEXSEQ","REF","OBJ_ID")){continue;} # ignore sequence&reference attr
         if(is_value_in(tmp_a[1],"QR","QR_KEY","QRMONEY","QRMONEYGOT")){continue;} # ignore QR attr
         if(is_value_in(tmp_a[1],"QRPRODMODEL","QRPRODTYPE","QRANGE_WARN")){continue;} # ignore QR attr
         if(is_value_in(tmp_a[1],"SHOW","QR","TEXTAREA")){continue;} # ignore visua attr
         if(is_value_in(tmp_a[1],"HEX","EN")){continue;} # ignore QC attr
         if(tmp_a[1]=="PUB"){f_PUB[FIELDS_COUNT]=1; continue;}
	 if(tmp_a[1]=="NN"){f_NN[FIELDS_COUNT]=1;}
	 else if(tmp_a[1]=="NUL"){f_NN[FIELDS_COUNT]=0;}
	 else if(tmp_a[1]=="SEQID"){do_abort_unallowed_attr(tmp_a[1]);}
	 else if(tmp_a[1]=="ZID"){do_abort_unallowed_attr(tmp_a[1]);}
	 else if(tmp_a[1]=="ZNAME"){f_ZNAME[FIELDS_COUNT]=1;
		if(ZNAME=="")ZNAME=f_name[FIELDS_COUNT];
		else do_abort("only one ZNAME field allowed : " \
			f_name[FIELDS_COUNT] ); }
	 else if(tmp_a[1]=="UNIQ"){f_UNIQ[FIELDS_COUNT]=1;
		f_UNIQ_REALM[FIELDS_COUNT]=tmp_a[2];
		if(f_UNIQ_REALM[FIELDS_COUNT] == "")
		 f_UNIQ_REALM[FIELDS_COUNT] = "DB";
		if(!is_value_in(f_UNIQ_REALM[FIELDS_COUNT],"DB","SCOPE",
		 "OBJECT")) do_abort("invalid realm for UNIQ: " tmp_a[2]);
		if(f_UNIQ_REALM[FIELDS_COUNT] != "OBJECT") has_table_uniq=1;
		}
	 else if(tmp_a[1]=="NOEDIT"){f_NOEDIT[FIELDS_COUNT]=1;
		f_NOEDIT_DEFAULT[FIELDS_COUNT] = tmp_a[2];
		if(tmp_a[2] == "")
		f_NOEDIT_DEFAULT[FIELDS_COUNT] = "null";}
	 else if(tmp_a[1]=="SID"){f_SID[FIELDS_COUNT]=1;
		if(SID_FIELD=="")SID_FIELD=f_name[FIELDS_COUNT];}
	 else if(tmp_a[1]=="SLEVEL"){do_abort_unallowed_attr(tmp_a[1]);}
	 else if(tmp_a[1]=="UID"){f_UID[FIELDS_COUNT]=1;}
	 else if(tmp_a[1]=="GID"){f_GID[FIELDS_COUNT]=1;}
	 else if(tmp_a[1]=="REF"){f_REF[FIELDS_COUNT]=1;
		f_REF_OT[FIELDS_COUNT]=tmp_a[2];
		INDEX_COUNT++;INDEX[INDEX_COUNT]=$2;
		}
	 else if(tmp_a[1]=="DIC"){
	  f_DIC[FIELDS_COUNT]=tmp_a[2];
	  if(f_DIC[FIELDS_COUNT]=="")
	   f_DIC[FIELDS_COUNT]= "" CODE f_no[FIELDS_COUNT];
	 }
	 else{do_warn("Invalid attributes token: " tmp_a[1]);} 
	}
	next;
 } # FIELD
function process_data_cat(status) #CAT
{
 FS=";";
 status=getline;
 while(status)
 {
  #print_qr_row_pub();
  print;
  status=getline;
 }
} #//process_data()
function process_data_pub(status) #PUB
{
 FS=";";
 status=getline;
 while(status)
 {
  print_row_pub();
  #print;
  status=getline;
 }
} #//process_data()
function process_data_query_qrrow(status) #PUB
{
 FS=";";
 status=getline;
 while(status)
 {
  if(QR_KEY != "")
  {
   if("x" $QR_KEY == "x" QUERY_PARTS[3]){
    print_row_pub();
   }
  }
  status=getline;
 }
} #//process_data_query_qrrow()
function process_data_query_qrrow_wiki(status) #PUB
{
 FS=";";
 status=getline;
 while(status)
 {
  if(QR_KEY != "")
  {
   if("x" $QR_KEY == "x" QUERY_PARTS[3]){
    print_row_pub_wiki();
   }
  }
  status=getline;
 }
} #//process_data_query_qrrow_wiki
function process_data_pub2019(status) #PUB2019 list.csv (legacy)
{
 FS=";";
 status=getline;
 while(status)
 {
  print_row_pub2019();
  status=getline;
 }
} #//process_data()
function print_row_pub2019(	i,k,row,pub_f)
{
 OFS=";";
 row="";
 k=1;
 for(i=1;i<=NF;i++)
 {
  if(f_PUB[i]) pub_f[k++]=$i;
 }
 if(QR_KEY != "" && QR_KEY > 0 && QR_KEY <= NF)
 {
  row=strip_qr($QR_KEY) ";";
 }
 else {row="FFF;";}
#  if(f_PUB[12]) row=row $12; row = row ";";
#  if(f_PUB[13]) row=row $13; row = row ";";
#  if(f_PUB[14]) row=row $14; row = row ";";
#  if(f_PUB[15]) row=row $15; row = row ";";
#  if(f_PUB[17]) row=row $17; row = row ";";
#  if(f_PUB[18]) row=row $18; row = row ";";
#  if(f_PUB[7]) row=row $7; row = row ";";
#  if(f_PUB[8]) row=row $8; row = row ";";
#  if(f_PUB[19]) row=row $19; row = row ";";
#  if(f_PUB[20]) row=row $20; row = row ";";
#  if(f_PUB[21]) row=row $21;
  #print strip_qr($QR_KEY),$12,$13,$14,$15,$17,$18,$7,$8,$19,$20,$21;
  print row pub_f[4],pub_f[5],pub_f[6],pub_f[7],pub_f[8],pub_f[9],pub_f[2],pub_f[3],pub_f[10],pub_f[11],pub_f[12];
  #print row;
} #//print_row_pub2019
function print_row_pub(i,row)
{
 row="";
 for(i=1;i<=NF;i++)
 {
  if(f_PUB[i]) if(length(row)==0){row=$i;}else{row=row FS $i; }
 }
 print row;
}#//print_row_pub
function print_row_pub_wiki(i,row)
{
 row="";
 OFS=";"
 for(i=1;i<=NF;i++)
 {
  if(f_PUB[i])
  {
   print ";",f_caption[i],$i;
  }
 }
 #print row;
}#//print_row_pub_wiki
#//{print ;}
//{do_abort("Invalid start token: " $1); }
function do_warn(msg)
{
if(!is_begun)
 print "PARSING WARNING: " msg "\n at line " NR ": >> " $0 " <<" > "/dev/stderr";
else
 print "PROCESSING WARNING: " msg > "/dev/stderr";
}
function do_abort(msg)
{
if(!is_begun)
 print "PARSING ERROR: " msg "\n at line " NR ": >> " $0 " <<" > "/dev/stderr";
else
 print "PROCESSING ERROR: " msg > "/dev/stderr";
is_aborted=1;
exit 1;
}

function strip_qr(qr)
{
 if(length(qr)>3)
 {
 qr=substr(qr,length(qr)-2);
 };
 return(qr);
}

function do_abort_unallowed_attr(attr)
{
do_abort("Unallowed field's attribute: " attr);
}

function is_value_in(value,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10)
{
if(v10 != "") do_abort("too many arguments for is_value_in(). value=" value);
if(value == "") return 0;
if(value == v1) return 1; if(value == v2) return 1; if(value == v3) return 1;
if(value == v4) return 1; if(value == v5) return 1; if(value == v6) return 1;
if(value == v7) return 1; if(value == v8) return 1; if(value == v9) return 1;
return 0;
}

# assistance

function make_qrqxyz_list_csv_tab()
{
}
# create table
function make_csv_tab(f,is_pub,	i,print_field)
{
 if(is_pub == "") is_pub=0;
 #printf("DROP TABLE IF EXISTS %s CASCADE;\n",NAME) >>f;
 printf("#!CSV_TAB\n") >>f;
 printf("#Атрибут\tЗначение\tЗначение2-код\n") >>f;
 printf("NAME\t%s\t%s\n",NAME,CODE) >>f;
 printf("OBJECT\t%s\t%s\n",OBJECT_NAME,OBJECT_CODE) >>f;
 printf("HEADER\t%s\n",HEADER) >>f;
 printf("PARENT\t%s\t%s\n",PARENT,PARENT_CODE) >>f;
 for(i=1;i<=CHILD_COUNT;i++){
  printf("CHILD\t%s\t%s\n",CHILD_NAME[i], CHILD_CODE[i]) >>f;
 }
 printf("#Код\tПоле\tТип\tАтрибуты\tНазвание\tОписание\n") >>f;
 if( HEADER == "STD_PSPNHEANOR"){
  # do nothing
 }
 #else{ do_abort("HEADER=" HEADER " unimplemented (TABLE)"); }
 for(i=1;i<=FIELDS_COUNT;i++)
 {
 print_field = !is_pub;
 if(f_PUB[i]) print_field = 1;
 if(print_field){
  #NUL="NULL"; if(f_NN[i]) NUL="NOT " NUL;
  printf("%s\t%s\t%s\t%s\t%s\t%s\n",f_no[i],f_name[i],f_type[i],f_attrib[i],f_caption[i],f_desc[i]) >>f;
 }
 }
} # /make_create_table(f)
# END OF codegen.awk
