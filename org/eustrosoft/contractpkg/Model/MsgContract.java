/*
* (c) EustroSoft.org 2020
* в этом классе названия полей, в БД и для пользователя, их уровни секретности и пояснения к заполнению
* это необходимо для централизации и нормализации этой информации, ибо она разбросана везде.
* Правильное место этой информации _сейчас_ - был-бы класс Contract, но он ужасен - его не спасти.
* Далее - эта информация должа подгружаться из файла, например того вида что породит main()
*
*/
package org.eustrosoft.contractpkg.Model;

public class MsgContract {

private static String FieldNames[] ={
"ZOID",
"ZVER",
"ZDATE",
"ZUID",
"ZSTA",
"QR",
"CONTRACTNUM",
"contractdate",
"MONEY",
"SUPPLIER",
"CLIENT",
"PRODTYPE",
"MODEL",
"SN",
"prodate",
"shipdate",
"SALEDATE",
"DEPARTUREDATE",
"WARRANTYSTART",
"WARRANTYEND",
"COMMENT"
};
private static String FieldCaptions[] ={
"ZOID",
"ZVER",
"ZDATE",
"ZUID",
"ZSTA",
"QR код",
"№ договора",
"дата договора",
"Деньги по договору",
"Юр-лицо поставщик",
"Юр-лицо клиент",
"Тип продукта",
"Модель продукта",
"SN",
"Дата производства",
"Дата ввоза (ГТД)",
"Дата продажи",
"Дата отправки клиенту",
"Дата начала гарантии",
"Дата окончания гарантии",
"Комментарий (для клиента)"
};
private static String FieldComments[] ={
"ZOID - идентификатор объекта (записи) в файле, записи с одинаковым ZOID - разные версии одной записи",
"ZVER - номер версии записи ",
"ZDATE - дата порождения данной версии",
"ZUID - пользователь, записавший версию",
"ZSTA - статус 'N' - актуальная, 'C' - устаревшая, 'D' - удаленная",
"QR код должен содержать ровно 8 символов, алфавит [0-9,A-F], первые 5 - это диапазон, оставшиеся 3 - номер внутри диапазона в 16-ричном",
"для новых номеров можно использовать последние 4 символа QR-кода. допустимо несколько карточек с одним номером договора",
"дата заключения договора",
"Деньги, причитающиеся поставщику, по договору за это изделие. Если изделий по договору несколько - заполняйте отдельные карточки",
"кто исполнитель по договору, если у нас более одного юр-лица или ИП",
"Юр-лицо клиента, пока только название, но можете добавить ИНН, через запятую, или еще что-то. Последним укажите город. Напр: EustroSoft,...,Москва",
"Тип продукта.",
"Модель продукта",
"Серийный номер изделия. Возможно - серийные номера агрегатов через запятую. Потом разберемся",
"Дата производства изделия",
"Сейчас - номер ГТД. Изначально хотели указывать дату ввоза в Россию, или дату поступления на склад.",
"Дата продажи - видимо дата поступления денег или гарантийного письма об оплате ",
"Дата отправки клиенту/отгрузки со склада. Обычно - это-же дата начала гарантии",
"Дата начала гарантии для конечного пользователя. т.е. при продажи дилером - задается им",
"Дата окончания гарантии. Обычно + 1 год, но нет правил без исключений",
"Этот комментарий виден клиенту! конфиденциальное пишите в поле Деньги"
};

public static final int SLEVEL_DSP = 8;
public static final int SLEVEL_PUB = 10;

private static int FieldSLevel[] ={
SLEVEL_PUB, //"ZOID",
SLEVEL_PUB, //"ZVER",
SLEVEL_PUB, //"ZDATE",
SLEVEL_PUB, //"ZUID",
SLEVEL_PUB, //"ZSTA",
SLEVEL_PUB, //"QR код",
SLEVEL_PUB, //"№ договора",
SLEVEL_PUB, //"дата договора",
SLEVEL_PUB, //"Деньги по договору",
SLEVEL_DSP, //"Юр-лицо поставщик",
SLEVEL_DSP, //"Юр-лицо клиент",
SLEVEL_PUB, //"Тип продукта",
SLEVEL_PUB, //"Модель продукта",
SLEVEL_PUB, //"SN",
SLEVEL_PUB, //"Дата производства",
SLEVEL_DSP, //"Дата ввоза (ГТД)",
SLEVEL_PUB, //"Дата продажи",
SLEVEL_PUB, //"Дата отправки клиенту",
SLEVEL_PUB, //"Дата начала гарантии",
SLEVEL_PUB, //"Дата окончания гарантии",
SLEVEL_PUB //"Комментарий (для клиента)"
};

public static final int FN_ZOID = 0;
public static final int FN_ZVER = 1;
public static final int FN_ZDATE = 2;
public static final int FN_ZUID = 3;
public static final int FN_ZSTA = 4;
public static final int FN_QR = 5;
public static final int FN_CONTRACTNUM = 6;
public static final int FN_contractdate = 7;
public static final int FN_MONEY = 8;
public static final int FN_SUPPLIER = 9;
public static final int FN_CLIENT = 10;
public static final int FN_PRODTYPE = 11;
public static final int FN_MODEL = 12;
public static final int FN_SN = 13;
public static final int FN_prodate = 14;
public static final int FN_shipdate = 15;
public static final int FN_SALEDATE = 16;
public static final int FN_DEPARTUREDATE = 17;
public static final int FN_WARRANTYSTART = 18;
public static final int FN_WARRANTYEND = 19;
public static final int FN_COMMENT = 20;

public static String  getCaption(int fn){return(FieldCaptions[fn]);}
public static String  getComment(int fn){return(FieldComments[fn]);}
public static String  getName(int fn){return(FieldNames[fn]);}
public static int  getSLevel(int fn){return(FieldSLevel[fn]);}
public static String  getSLevelName(int fn){int s=getSLevel(fn);if(s==SLEVEL_DSP)return("DSP");if(s==SLEVEL_PUB)return("PUB");return(""+s);}
public static String getFieldRow(int fn){return( fn + ";" + getName(fn) + ";" + getCaption(fn) + ";" + getSLevelName(fn) + ";" + getComment(fn));}


 public final static String[] CSV_UNSAFE_CHARACTERS = {";","\n","\r"};
 public final static String[] CSV_UNSAFE_CHARACTERS_SUBST = {"\\.,","\\n","\\r"};
 public static String value2csv(String text)
 {
 return(translate_tokens(obj2text(text),CSV_UNSAFE_CHARACTERS,CSV_UNSAFE_CHARACTERS_SUBST));
 } // text2html()
 public static String csv2text(String text)
 {
 if(text==null) text= "";
 return(translate_tokens(text,CSV_UNSAFE_CHARACTERS_SUBST,CSV_UNSAFE_CHARACTERS));
 } // text2html()

// START of WAMessages

private final static String SZ_NULL = "null";

//
// static conversion helpful functions
// obj2text(), obj2html(), obj2value() - useful functions
// translate_tokens() - background work for them
//

 /** convert object to text even if object is null.
 */
 public static String obj2text(Object o)
 {
 if(o == null) return(SZ_NULL); return(csv2text(o.toString()));
 }

 /** convert object to text but preserve null value if so.
 * @see obj2text
 */
 public static String obj2string(Object o)
 {
 if(o == null) return(null); return(obj2text(o));
 }

 /** convert object to html text even if object is null.
 * @see #obj2text
 * @see #text2html
 */
 public static String obj2html(Object o)
 {
  if(o == null) return("<STRIKE><small>null</small></STRIKE>");
  else return(text2html(obj2text(o)));
 }

 /** convert szValue to Long object it's represents or into null value
  * if conversion failed.
 */
 public static Long string2Long(String szValue)
 {
 if(szValue == null) return(null);
 Long v=null; try{v=Long.valueOf(szValue);} catch(NumberFormatException e){}
 return(v);
 }

 //
 public final static String[] HTML_UNSAFE_CHARACTERS = {"<",">","&","\n"};
 public final static String[] HTML_UNSAFE_CHARACTERS_SUBST = {"&lt;","&gt;","&amp;","<br>\n"};
 public final static String[] VALUE_CHARACTERS = { "<",">","&","\"","'" };
 public final static String[] VALUE_CHARACTERS_SUBST = {"&lt;","&gt;","&amp;","&quot;","&#039;"};
 public final static String[] JSON_VALUE_CHARACTERS = { "\n","\r","\"","\\" };
 public final static String[] JSON_VALUE_CHARACTERS_SUBST = {"\\n","\\r","\\","\\\\"};

 /** convert plain textual data into html code with escaping unsafe symbols.
  * @param text - plain text
  * @return html escaped text
  */
 public static String text2html(String text)
 {
 return(translate_tokens(text,HTML_UNSAFE_CHARACTERS,HTML_UNSAFE_CHARACTERS_SUBST));
 } // text2html()

 /** convert plain textual data into html form value suitable for input or textarea fields.
  * @param text - plain text
  * @return escaped text
  */
 public static String text2value(String text)
 {
 return(translate_tokens(text,VALUE_CHARACTERS,VALUE_CHARACTERS_SUBST));
 } // text2value()

 public static String text2json(String text)
 {
 return("\"" + translate_tokens(text,JSON_VALUE_CHARACTERS,JSON_VALUE_CHARACTERS_SUBST) + "\"");
 }

 public static String obj2value(Object o)
 {
 return(text2value(obj2text(o)));
 }


 /** replace all sz's occurrences of 'from[x]' onto 'to[x]' and return the result.
  * Each occurence processed once and result depend on token's order at 'from'. 
  * For instance: translate_tokens("hello",new String[]{"he","hel","hl"}, new String[]{"eh","leh","lh"})
  * give "ehllo", not "lehlo" or "elhlo" (in fact "hel" to "leh" translation never be done).
  * @param sz - string for translation
  * @param from - array of tokens to search
  * @param to - array of tokens to translate to
  * @param len - the number of tokens at "from" to look. use -1 to look for all
  *   actually len = min(len,from.length) if len >=0 and len = from.length otherwise
  *	
  */
 public static String translate_tokens(String sz, String[] from, String[] to, int len)
 {
  if(sz == null) return(sz);
  StringBuffer sb = new StringBuffer(sz.length() + 256);
  int p=0;
  if(len<0) len=from.length;
  //if(len>to.length) len=to.length; // let's
  while(p<sz.length())
  {
  int i=0;
  while(i<len) // search for token
  {
   if(sz.startsWith(from[i],p)) { sb.append(to[i]); p=--p +from[i].length(); break; }
   i++;
  }
  if(i>=len) sb.append(sz.charAt(p)); // not found
  p++;
  }
  return(sb.toString());
 } // translate_tokens

 public static String translate_tokens(String sz, String[] from, String[] to)
 {return(translate_tokens(sz,from,to,-1));}
// END of WAMessages

public static java.math.BigDecimal str2dec(String dec_str)
{
java.math.BigDecimal d = java.math.BigDecimal.ZERO;
if(dec_str==null){dec_str="";}
dec_str=dec_str.replaceAll("[\t ]*","");
dec_str=dec_str.replaceAll(",",".");
dec_str=dec_str.replaceAll("[^0-9eE+-\\.].*$","");
try{
 d=new java.math.BigDecimal(dec_str);
}
catch(Exception ne){ d = java.math.BigDecimal.ZERO; }
return(d);
}//str2dec()

/*
* выводит описание в CSV формате в stdout
*/
public static void main(String[] args)
{
System.out.println("#FN;FNAME;FCAPTION;FSLEVEL;FCOMMENT");
for(int i=0;i<FieldNames.length;i++) {System.out.println(getFieldRow(i));}
java.math.BigDecimal d = str2dec("12 23,4e 3 #234");
System.out.println(d);
} //main()
} //end of class
