<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ page import="java.io.*" %>
<%@ page import="org.eustrosoft.contractpkg.Controller.RangesController" %>
<%!

private String[] NAILED_RANGE_DESC= {
   "01000", "(Пример) - по каждому объекту (QR-коду) ведется отдельная страница",
   "0100A", "(Пример) здесь будет пример информации защищенной паролем",
   "0100F", "(Пример) здесь будет пример перенаправления на другие сайты",
   "0100D", "(Пример) Примеры на основе первых проданных двигателей TDME",
   "0100E", "(Пример) Отладочный пример, на основе данных Доминатор 01012 - реальные продажи TDME 2010-2017",
"01011",":+:2019-11-18:DOMINATOR:list:Данные о продажах от начала работы до конца 2011 г",
"01012", "Доминатор - реальные продажи TDME 2010-2017 (Money_2)",
"01017", "DOMINATOR:list:Данные о продажах в 2017 г. (предложение к использованию)",
"01018", "DOMINATOR:list:Данные о продажах в 2018 г. (предложение к использованию)",
"01019",":+:2019-11-24:DOMINATOR:list:Данные о продажах в 2019 г.",
"0101A",":+:2019-11-24:DOMINATOR:list:Данные о продажах в 2020 г.",
"0101E",":+:2019-11-27:DOMINATOR::Diesel Engines models",
"01020",":+:2019-11-21:EUSTROSOFT::Various EustroSoft QR-info pages",
"01021",":+:2019-12-22:EUSTROSOFT::EustroSoft's inventory-list",
"01030",":-:2019-12-17:NS-RESERVED",
"01031",":-:2019-12-17:MH-RESERVED",
"01032",":-:2019-12-17:GL-RESERVED",
"01033",":-:2019-12-17:MA-RESERVED",
"01034",":-:2019-12-17:SN-RESERVED",
"01035",":-:2019-12-22:LYRA-SNT",
"01036","выделен 2019-12-22 для rubmaster.ru",
"01037","выделен 2019-12-22 для boatswain.org",

   "FFFF", ""
};

public String getNailedRangDesc(String r, String desc){
int i=0;
String new_desc=desc;
if(new_desc==null) new_desc="";
for(i=0; i< (NAILED_RANGE_DESC.length/2); i++)
{
if(NAILED_RANGE_DESC[i*2].equals(r)){new_desc=new_desc+" "+NAILED_RANGE_DESC[i*2+1]; break; }
}
return(new_desc);
}
%>
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
 String item_desc = getNailedRangDesc(item,"Диапазон " + item);
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
