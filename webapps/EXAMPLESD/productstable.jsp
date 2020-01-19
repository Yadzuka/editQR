<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.eustrosoft.contractpkg.Model.*" %>
<%@ page import="org.eustrosoft.contractpkg.Controller.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.*" %>
<%!
	//
	public org.eustrosoft.contractpkg.Model.MsgContract msg;
public int str2int(String str){
int i=-1; try{i=Integer.parseInt(str);}catch(java.lang.NumberFormatException nfe){}
return(i);
}
%>
<%
String CGI_NAME = null; try{ CGI_NAME=(String)request.getAttribute("CGI_NAME"); } catch(Exception e){} //it's ok! see before&after
if(CGI_NAME == null) {out.println("<div> no attr_dispatch_canary - exit </div>"); return; }
String range = null; try{ range=(String)request.getParameter("range"); } catch(Exception e){}
String member = null; try{ member=(String)request.getParameter("member"); } catch(Exception e){}
%>
<html>
<head>
    <title>Starting table</title>
    <link rel="stylesheet" type="text/css" href="css/webcss.css"/>
	<link rel="stylesheet" type="text/css" href="css/head.css">
</head>
<body>
	<%
		ControllerContracts contractController = new ControllerContracts(member,range);
		ArrayList<Contract> availableContracts = contractController.getContracts();
		Contract bufferToPrintProperties;
		Contract bufferForComparison;
	%>

	<ul>
		<li><a href="<%= CGI_NAME %>?cmd=rl&member=<%=member%>">Назад</a></li>
		<li><a href="<%= CGI_NAME %>?cmd=ie&member=<%=member%>&range=<%=range%>&action=create">Создать новую запись</a></li>
	</ul>

   		<caption><h3>Таблица проданных товаров, или произведенных изделий, или заключенных договоров. Пока это не очень различимо.</h3></caption>
<p>
По всем изменениям - ведется история, кто, когда и что было раньше. Если что - разберемся и починим все что было поломано.
</p>
	<table class="memberstable" border="2" width="60%">
   	<tr>
   		<td>Функции</td>
<!--
    	<td>QR Image</td>
-->
	<td><%=msg.obj2html(msg.getCaption(msg.FN_QR))%></td>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_CONTRACTNUM))%></td>
	<!-- <td><%=msg.obj2html(msg.getCaption(msg.FN_contractdate))%></td> -->
	<td>Изделие</td>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_SN))%></td>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_CLIENT))%></td>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_SUPPLIER))%></td>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_MONEY))%></td>
   	</tr>
		<%
			int firstCompositor;
			int secondCompositor;
			// Prints only last version of object
if(availableContracts != null) {
//TreeMap years = null;
//TreeMap mounthes = null;
TreeMap products = new TreeMap(); 
TreeMap models = null;
BigDecimal[] counts = null;
BigDecimal all_money = BigDecimal.ZERO;

			for(int i = availableContracts.size()-1; i >= 0; i--){

				bufferToPrintProperties = availableContracts.get(i);
				bufferForComparison = availableContracts.get(i);
				String prodtype = msg.obj2text(bufferToPrintProperties.getPRODTYPE());
				String model = msg.obj2text(bufferToPrintProperties.getMODEL());
				String money = msg.obj2text(bufferToPrintProperties.getMoney());
				models = (TreeMap)products.get(prodtype);
				if(models == null){models = new TreeMap(); products.put(model,models);}
				all_money = all_money.add(msg.str2dec(money));
				

				// Works with all ZOID objects
				for(int j = 0; j < availableContracts.size();j++){
					firstCompositor = str2int(bufferToPrintProperties.getZOID());
					secondCompositor = str2int(availableContracts.get(j).getZOID());

					if(firstCompositor != secondCompositor)
						continue;

					firstCompositor = str2int(bufferToPrintProperties.getZVER());
					secondCompositor = str2int(availableContracts.get(j).getZVER());

					if(firstCompositor < secondCompositor) {
						bufferToPrintProperties = availableContracts.get(j);
					}
				}

				firstCompositor = str2int(bufferForComparison.getZVER());
				secondCompositor = str2int(bufferToPrintProperties.getZVER());
				if(firstCompositor < secondCompositor)
					continue;
		%>
		
   		<tr>
   			<td>
   				<a href="<%= CGI_NAME %>?cmd=iv&member=<%=member%>&range=<%=range%>&zoid=<%=i%>">
   					&lt;карточка&gt&nbsp;
   				</a>
				<!-- <br> Удалить -->
   			</td>
<!--
   			<td>
    			<a href = "engine/qr?codingString=<%=msg.obj2value(bufferToPrintProperties.getQr())%>" >
				<img src="engine/qr?codingString=<%=bufferToPrintProperties.getQr()%>"/>
			</a>
			</td>
-->
    		<td> &nbsp;<a href = "<%="http://qr.qxyz.ru/?q="+msg.obj2value(bufferToPrintProperties.getQr())%>"
			 target="_<%=msg.obj2value(bufferToPrintProperties.getQr())%>"><%=msg.obj2html(bufferToPrintProperties.getQr())%></a>
			</td>
   	 		<td><%=msg.obj2html(bufferToPrintProperties.getContractum())%> от
    		<%=msg.obj2html(bufferToPrintProperties.getContractdate())%></td>
			<td><%=msg.obj2html(msg.obj2text(bufferToPrintProperties.getPRODTYPE()) + msg.obj2text(bufferToPrintProperties.getMODEL()))%></td>
			<td><%=msg.obj2html(bufferToPrintProperties.getSN())%></td>
			<td><%=msg.obj2html(bufferToPrintProperties.getCLIENT())%></td>
    		<td><%=msg.obj2html(bufferToPrintProperties.getSUPPLIER())%></td>
    		<td><%=msg.obj2html(bufferToPrintProperties.getMoney())%></td>
   		</tr>
		<%
			}
		%>
<tr><td colspan="7">Всего:</td>
<td>
<%
out.println(all_money);
} //if
%>
</td></tr>
  	</table>
<%
%>
</body>
</html>
