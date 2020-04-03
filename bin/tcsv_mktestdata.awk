#!/usr/bin/awk -f
# For testing with different awk implementations use please:
#!/usr/local/bin/gawk -f
#!/usr/local/bin/mawk -f
#!/usr/local/bin/nawk -f
#
# edit-qr.qxyz.ru project part
#
# (c) 2020 Alex V Eustrop & EustroSoft.org
# LICENCE: BALES,ISC,BSD,MIT on your choice
#
# prepare random or stable test data set in TIS-CSV format
#
# usage: ./make_test_csv.awk | more
# 

BEGIN{
 OFS=";";
 i=0; 
 k=65536; # num of uniq ZRID
 v=0; # inital version is v++
 MAX_v=5; # number of versions for each row
 DEL_v=3; # this version will be "deletion"
 ver_prob=1; # probability to version be produced
 #ver_prob=0.5; # probability to version be produced
 ver_del_prob=0; # probability to version will be "deletion"
 #ver_del_prob=0.1; # probability to version will be "deletion"
 srand();
 #srand(2020); #fixed seed, comment it to more random test-sets
 while(v++<MAX_v)
 {
  ZSTA_VER="N";
  if(v==DEL_v) ZSTA="D";
  for(i=0;i<k;i++)
  {
   ZSTA=ZSTA_VER;
   RAND_DEL=rand();
   RAND_PRINT=rand();
   QRCODE=sprintf("%08X",i);
   if(RAND_DEL<=ver_del_prob){ ZSTA="D"; }
   if(RAND_PRINT<=ver_prob)
    print (k-i),v,"date","user",ZSTA,QRCODE,"row: " i " ver=" v,RAND_DEL,RAND_PRINT;
  }#//for(i)
 }#//while(v)
}#//BEGIN
