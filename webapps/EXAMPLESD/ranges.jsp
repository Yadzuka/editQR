<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ page import="java.io.*" %>
<%@ page import="org.eustrosoft.contractpkg.Controller.RangesController" %>
<%
String CGI_NAME = null; try{ CGI_NAME=(String)request.getAttribute("CGI_NAME"); } catch(Exception e){} //it's ok! see before&after
if(CGI_NAME == null) {out.println("<div> no attr_dispatch_canary - exit </div>"); return; }
String range = null; try{ range=(String)request.getAttribute("range"); } catch(Exception e){}
%>
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
        <a href="./">
            Назад
        </a>
    </li>
</ul>
    <!-- I think that's better -->
    <%
        RangesController rController = new RangesController(f);
        String s = rController.getInfo();
    %>
    <%=s%>
<table>
 <tbody>
  <tr>
   <th>Диапазон</th>
   <th>Описание</th>
  </tr>
<!--
  <tr>
   <td><a href="<%= CGI_NAME %>?cmd=il&member=<%=f%>&range=<%="0100D"%>">0100D</a></td>
   <td>Примеры на основе первых проданных двигателей TDME</td>
  </tr>
  <tr>
   <td><a href="<%= CGI_NAME %>?cmd=il&member=<%=f%>&range=<%="0100E"%>">0100E</a></td>
   <td>(для отладки) несуществующий диапазон</td>
  </tr>
-->
<%
// Set global parameters
String [] allItems = rController.getRanges();
// Cycle for each member ( directory ) in the main (members) path
for(int i =0; i <  allItems.length; i++) {
 String item = allItems[i];
 String item_desc = "Диапазон " + item;
%>
  <tr>
   <td><a href="<%= CGI_NAME %>?cmd=il&member=<%=f%>&range=<%=item%>"><%=item%></a></td>
   <td><%=item_desc%></td>
  </tr>
<%
}
%>
  <tr>
   <td><a href="<%= CGI_NAME %>?cmd=il&member=<%=f%>&range=<%="FFFFF"%>">FFFFF</a></td>
   <td>(для отладки) это несуществующий диапазон!</td>
  </tr>
 </tbody>
</table>

</body>
</html>
