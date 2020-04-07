#!/usr/bin/awk -f
#
# edit.qr.qxyz.ru
# *.list.csv processing tool
# usage : tcsvql.awk -v QUERY=EXEC:QRQXYZ_MASTER2LIST -v TABOUT=/p/to/list.csv.tab -v CSVOUT=/p/to/list.csv
# Supported queries:
#	EXEC:QRQXYZ_MASTER2LIST - convert tcsv data to public list with leading QR field keeping PUB only fields
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
if(QUERY=="") QUERY="EXEC:QRQXYZ_MASTER2LIST";
#print QUERY;
FS="\t";
} #/BEGIN
END{
if(is_aborted)exit 1;
is_begun=1; # used by do_abort
WDIR="work/"
STD_HEADER_OFFSET=7;
#make_create_table(WDIR "/tables/" SHORT_NAME ".sql");
make_csv_tab("/dev/stdout");
} #/END
/^#!CSV_DATA/{process_data(); next;} # process data rows
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
function process_data(status)
{
 FS=";";
 status=getline;
 while(status)
 {
  print_qr_row_pub();
  print;
  status=getline;
 }
} #//process_data()
function print_qr_row_pub(i,row)
{
 row="";
 for(i=1;i<=NF;i++)
 {
  if(f_PUB[i]) row=row FS $i;
 }
 print row;
}#//process_data()
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
function make_csv_tab(f,	i)
{
 #printf("DROP TABLE IF EXISTS %s CASCADE;\n",NAME) >>f;
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
  NUL="NULL"; if(f_NN[i]) NUL="NOT " NUL;
  printf("%s\t%s\t%s\t%s\t%s\t%s\n",f_no[i],f_name[i],f_type[i],f_attrib[i],f_caption[i],f_desc[i]) >>f;
 }
} # /make_create_table(f)
# END OF codegen.awk

