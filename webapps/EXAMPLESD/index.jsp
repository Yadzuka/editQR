<%@ page import="org.eustrosoft.contractpkg.Model.Members" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.OutputStream" %>
<%@ page import="java.io.InputStream" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@
  page import="java.util.*"
  import="java.io.*"
%>
<%--
 QR.QXYZ.RU Project
 (c) Alex V Eustrop & EustroSoft.org 2019
 LICENSE: BALES, MIT, ISC
 Partally based o psql.jsp from ConcepTIS project
 (c) Alex V Eustrop 2009
 see LICENSE at the ConcepTIS project's root directory
 (ConcepTIS LICENSE is compatible with any of BALES, MIT, ISC)

--%>
<%!
//
// Global parameters
//
private final static String CGI_NAME = "index.jsp";
private final static String CGI_TITLE = "EDIT-QR.qxyz.ru - средство редактирования БД диапазонов QR-кодов для проданных изделий";
//private final static String DBSERVER_URL = "jdbc:postgresql:tisexmpldb?user=tisuser1&password=";
private final static String DBSERVER_URL = "jdbc:postgresql:conceptisdb";
private final static String JSP_VERSION = "$Id$";

private final static String SZ_EMPTY = "";
private final static String SZ_NULL = "<<NULL>>";
private final static String SZ_UNKNOWN = "<<UNKNOWN>>";

private final static String CMD_MEMBER_LIST = "ml";
private final static String CMD_RANGE_LIST = "rl";
//private final static String CMD_RANGE_VIEW = "rv";
private final static String CMD_ITEM_LIST = "il";
private final static String CMD_ITEM_VIEW = "iv";
private final static String CMD_ITEM_EDIT = "ie";
private final static String CMD_TEST = "test";
private final static String CMD_DEFAULT = CMD_MEMBER_LIST;

private JspWriter out;

private String QRDB_PATH=null;
  public void read_parameters_from_web_xml()
  {
      QRDB_PATH = getServletContext().getInitParameter("QRDB_PATH");
  }

//
// static conversion helpful functions
// obj2text(), obj2html(), obj2value() - useful functions
// translate_tokens() - background work for them
//

 /** convert object to text even if object is null.
 */
 public static String obj2text(Object o)
 {
 if(o == null) return(SZ_NULL); return(o.toString());
 }

 /** convert object to html text even if object is null.
 * @see #obj2text
 * @see #text2html
 */
 public static String obj2html(Object o)
 {
 return(text2html(obj2text(o)));
 }

 //
 public static String[] HTML_UNSAFE_CHARACTERS = {"<",">","&","\n"};
 public static String[] HTML_UNSAFE_CHARACTERS_SUBST = {"&lt;","&gt;","&amp;","<br>\n"};
 public final static String[] VALUE_CHARACTERS = { "<",">","&","\"","'" };
 public final static String[] VALUE_CHARACTERS_SUBST = {"&lt;","&gt;","&amp;","&quot;","&#039;"};

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
 } // text2html()

 /** replace all sz's occurrences of 'from[x]' onto 'to[x]' and return the result.
  * Each occurence processed once and result depend on token's order at 'from'. 
  * For instance: translate_tokens("hello",new String[]{"he","hel","hl"}, new String[]{"eh","leh","lh"})
  * give "ehllo", not "lehlo" or "elhlo" (in fact "hel" to "leh" translation never be done).
  */
 public static String translate_tokens(String sz, String[] from, String[] to)
 {
  if(sz == null) return(sz);
  StringBuffer sb = new StringBuffer(sz.length() + 256);
  int p=0;
  while(p<sz.length())
  {
  int i=0;
  while(i<from.length) // search for token
  {
   if(sz.startsWith(from[i],p)) { sb.append(to[i]); p=--p +from[i].length(); break; }
   i++;
  }
  if(i>=from.length) sb.append(sz.charAt(p)); // not found
  p++;
  }
  return(sb.toString());
 } // translate_tokens


   /** print message to stdout. TISExmlDB.java legacy where have been wrapper to System.out.print */
   public  void printmsg(String msg) throws java.io.IOException {out.print(msg);}
   public  void printmsgln(String msg) throws java.io.IOException {out.println(msg);}
   public  void printmsgln() throws java.io.IOException {out.println();}

   /** print message to stderror. TISExmlDB.java legacy where have been just a wrapper to System.err.print */
   public  void printerr(String msg) throws java.io.IOException {out.print("<b>" + obj2html(msg) + "</b>");}
   public  void printerrln(String msg) throws java.io.IOException {printerr(msg);out.print("<br>");}
   public  void printerrln() throws java.io.IOException {out.println();}
 //
 // some hints for old and buggy browsers like NN4.x
 //
  public void set_request_hints(HttpServletRequest request, HttpServletResponse response)
   throws java.io.IOException
  {
   long enter_time = System.currentTimeMillis();
   long expire_time = enter_time + 24*60*60*1000;
   response.setHeader("Cache-Control","No-cache");
   response.setHeader("Pragma","no-cache");
   response.setDateHeader("Expires",expire_time);
   try{
   request.setCharacterEncoding("UTF-8");
   }
   catch (UnsupportedEncodingException e){printerr(e.toString());}
  }

%>
<html>
 <head>
  <title><%= CGI_TITLE %></title>
 </head>
<body>
  <h2><%= CGI_TITLE %></h2>
 <hr>
<div>
<a href='<%= CGI_NAME %>'>Начало</a>&nbsp;
<a href='<%= CGI_NAME %>?cmd=test'>Тест</a>&nbsp;
<a href='test.jsp'>test.jsp</a>&nbsp;
<!--
-->

</div>
<%
  set_request_hints(request,response);
  this.out = out;
  long enter_time = System.currentTimeMillis();
  read_parameters_from_web_xml();
  if(QRDB_PATH == null) {printerr("QRDB_PATH параметр не задан! отредактируйте WEB-INF/web.xml"); }
  Members.setWayToDB(QRDB_PATH);
  String cmd=request.getParameter("cmd");
  if(SZ_EMPTY.equals(cmd) || cmd == null){ cmd=CMD_DEFAULT; }
  try{
      //out.println("<div><a href='./'>Начало</a></div>");
      out.flush();
      request.setAttribute("attr_dispatch_canary","Hello! i'am attribute attr_dispatch_canary for test.jsp!");
      request.setAttribute("CGI_NAME",CGI_NAME);
      switch(cmd){
        case CMD_MEMBER_LIST :
           request.getRequestDispatcher("members.jsp").include(request, response);
           break;
        case CMD_RANGE_LIST :
           request.getRequestDispatcher("ranges.jsp").include(request, response);
           break;
        //case CMD_RANGE_VIEW :
        case CMD_ITEM_LIST :
          request.getRequestDispatcher("productstable.jsp").include(request, response);
           break;
        case CMD_ITEM_VIEW :
           request.getRequestDispatcher("productview.jsp").include(request, response);
           break;
        case CMD_ITEM_EDIT :
           request.getRequestDispatcher("update.jsp").include(request, response);
          break;
        case CMD_TEST :
           request.getRequestDispatcher("test.jsp").include(request, response);
           break;
        default:
          printerr("Неправильный запрос cmd=" + cmd);
          break;
        }
      out.println("<div>after</div>");
    }
    catch(Exception e){printerrln(e.toString());}
%>
<hr>
  <i>timing : <%= ((System.currentTimeMillis() - enter_time) + " ms") %></i>
 <br>
  Hello! your web-server is <%= application.getServerInfo() %><br>
  <i><%= JSP_VERSION %></i>
  <!-- Привет this is just for UTF-8 testing (must be russian word "Privet") -->
</body>
</html>
