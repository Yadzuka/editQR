<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<div>
Hello!
<%
out.println("<pre>");
out.println(request.getRemoteUser());
out.println(request.getRemoteAddr());
out.println(new SimpleDateFormat("y-MM-dd HH:mm:ss Z").format(new Date()));
out.println("</pre>");
if( request.getAttribute("attr_dispatch_canary") == null) {out.println("<div> no attr_dispatch_canary - exit </div>"); return; }
// { throw(new Exception("Атрибут attr_dispatch_canary не передан, значит меня вызвали напрямую, Я для этого не предназначено!")); }
out.println((String)request.getAttribute("attr_dispatch_canary"));
//if(true) throw(new Exception("Пример исключения в JSP для .include"));
%>
</div>
