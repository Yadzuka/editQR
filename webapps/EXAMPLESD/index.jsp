<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.util.*"
%>
<%!
    private final static String CGI_TITLE = "EDIT-QR.qxyz.ru - средство редактирования БД диапазонов QR-кодов для проданных изделий"; // Upper page info
    private final static String CGI_NAME = "editqrpage.jsp"; // Page domain name
%>
<%
response.sendRedirect(CGI_NAME);

%>
<html>
<head>
<title>
<%= CGI_TITLE %>
</title>
<head>
<body>
<a href="<%=CGI_NAME%>"><%=CGI_NAME%></a>
</body>
</html>
