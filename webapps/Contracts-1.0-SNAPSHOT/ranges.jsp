<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ page import="java.io.*" %>
<%@ page import="org.eustrosoft.contractpkg.Controller.RangesController" %>
<html>
<head>

    <%
        String f = request.getParameter("member"); // I think that's bad practice
    %>
    <title><%=f%> ranges</title>
    <link rel="stylesheet" type="text/css" href="css/head.css">
</head>
<body>
<ul>
    <li>
        <a href="members.jsp">
            Назад
        </a>
    </li>
    <li>
        <a href="productstable.jsp?member=<%=f%>&range=<%="0100D"%>">
            <%="0100D"%>
        </a>
    </li>
</ul>
    <!-- I think that's better -->
    <%
        RangesController rController = new RangesController(f);
        String s = rController.getInfo();
    %>
    <%=s%>
</body>
</html>
