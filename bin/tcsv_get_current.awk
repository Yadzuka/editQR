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
# extrct only latest actual versions of rows from TIS-CSV format
#
# usage: cat your_data.csv | ./get_tcsv_current
# where your_data.csv is somthing like:
#  #ZRID;ZVER;ZDATE;ZUID;field1;field2;field3;field4;field5
#  149;1;date;user;N;0000FF6B;row: 65387 ver=1;0,927585;0,276377
#  147;1;date;user;N;0000FF6D;row: 65389 ver=1;0,915482;0,381637
#  146;1;date;user;N;0000FF6E;row: 65390 ver=1;0,677313;0,0318512
#  142;1;date;user;N;0000FF72;row: 65394 ver=1;0,384728;0,394329
#  140;1;date;user;N;0000FF74;row: 65396 ver=1;0,442688;0,463768
#  148;2;date;user;N;0000FF6C;row: 65388 ver=2;0,229739;0,170296
#  147;2;date;user;N;0000FF6D;row: 65389 ver=2;0,373959;0,00492086
#  144;2;date;user;N;0000FF70;row: 65392 ver=2;0,263643;0,296
#  143;2;date;user;N;0000FF71;row: 65393 ver=2;0,17734;0,49112
#  147;3;date;user;N;0000FF6D;row: 65389 ver=3;0,182588;0,461233
#  146;3;date;user;N;0000FF6E;row: 65390 ver=3;0,721734;0,296664
#  144;3;date;user;N;0000FF70;row: 65392 ver=3;0,435756;0,310288
#  143;3;date;user;N;0000FF71;row: 65393 ver=3;0,302065;0,000860193
#  141;3;date;user;D;0000FF73;row: 65395 ver=3;0,0722343;0,488052
#  140;3;date;user;D;0000FF74;row: 65396 ver=3;0,092708;0,494391
#  148;4;date;user;D;0000FF6C;row: 65388 ver=4;0,0544952;0,48486
#  144;4;date;user;N;0000FF70;row: 65392 ver=4;0,933549;0,40759
#  143;4;date;user;N;0000FF71;row: 65393 ver=4;0,558266;0,297562
#  142;4;date;user;N;0000FF72;row: 65394 ver=4;0,363897;0,252736
#  141;4;date;user;N;0000FF73;row: 65395 ver=4;0,884118;0,31312
#  145;5;date;user;N;0000FF6F;row: 65391 ver=5;0,690852;0,179569
#  143;5;date;user;D;0000FF71;row: 65393 ver=5;0,706354;0,137302
#  

BEGIN{
 FS=";";
 maxZRID=0;
 ZRID=0; # current ZRID
 uniq_ZRID_count=0;
 #ZRID_idx
}
/^#/{next}
{
 ZRID=$1+0;
 ZSTA=$5;
 if(ZRID==0)next;
 #print ZRID;
 if(lines[ZRID]==""){ZRID_idx[++uniq_ZRID_count]=ZRID;}
 lines[ZRID]=$0;
 if(ZSTA=="D") lines[ZRID]="#";
 if(ZRID>maxZRID){maxZRID=ZRID;}
}
function print_lines_idx(lines,idx, i, count)
{
 count=uniq_ZRID_count;
 #for(ZRID in lines) {idx[count++]=ZRID;}
 #for(ZRID in idx) {count++;}
 #sort_idx(idx,count);
 #print "count:" count;
 for(i=0;i<=count;i++)
 {
  if(lines[idx[i]] != "" && lines[idx[i]] != "#")
  {
   print lines[idx[i]];
  }
 }
}
function print_lines_in(lines)
{
 for(ZRID in lines)
 {
  if(lines[ZRID] != "" && lines[ZRID] != "#")
  {
   print lines[ZRID];
  }
 }
}

# bubble sort (do not use it! too slow for large set)
#
function sort_idx(idx, size,	i,a,b,r, swap_count)
{
 r=0;
 #print "size:" size;
 swap_count=1;
 while(swap_count>0)
 {
 swap_count=0;
 for(i=0;i<size;i++)
 {
  if(i>0){
  #print "i:" i " " idx[i] " " idx[i-1];
   if(idx[i]<idx[i-1])
   {
    r=idx[i];idx[i]=idx[i-1];idx[i-1]=r; #swap
    #print "swap:" i;
    swap_count++;
   }
  }
 }
 } #//while(swap_count)
}
END{
#print_lines_in(lines); # can be used if you don't want to keep rows order
print_lines_idx(lines, ZRID_idx); # this version keeps order of rows
}
