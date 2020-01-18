<%@ page contentType="text/html;charset=UTF-8" language="java"  %>
<%@ page import="org.eustrosoft.contractpkg.Controller.ControllerContracts" %>
<%@ page import="org.eustrosoft.contractpkg.Model.Contract" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.ParseException" %>
<%!
	//
	public org.eustrosoft.contractpkg.Model.MsgContract msg;
%>
<%
String CGI_NAME = null; try{ CGI_NAME=(String)request.getAttribute("CGI_NAME"); } catch(Exception e){} //it's ok! see before&after
if(CGI_NAME == null) {out.println("<div> no attr_dispatch_canary - exit </div>"); return; }
String range = null; try{ range=(String)request.getParameter("range"); } catch(Exception e){}
String member = null; try{ member=(String)request.getParameter("member"); } catch(Exception e){}
%>
<html>
<head>
    <title>Product viewing</title>
	<link rel="stylesheet" type="text/css" href="css/head.css">
</head>
<body>

<%
	String memberParam = request.getParameter("member");
	String rangeParam = request.getParameter("range");
	String contractParam = request.getParameter("zoid");
	int parsedContractParam = 0;
	try {
		 parsedContractParam = Integer.parseInt(contractParam);
	}catch(Exception ex){

	}
	ControllerContracts contractController = new ControllerContracts(member,range);
	Contract bufferToShowModel = contractController.getContract(parsedContractParam);
%>
<ul>
	<li><a href="<%= CGI_NAME %>?cmd=il&member=<%=memberParam%>&range=<%=rangeParam%>">
		Назад</a></li>&nbsp;
	<li><a href="<%= CGI_NAME %>?cmd=ie&member=<%=memberParam%>&range=<%=rangeParam%>&zoid=<%=contractParam%>&action=edit">
		Изменить запись</a></li>
</ul>
		<table>
	   		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_QR))%></td>
				<td>
					<img src="engine/qr?codingString=<%=bufferToShowModel.getQr()%>"/>
				</td>
			</tr>
    		<tr>
    			<td>Ссылка: </td>
    			<td>
    				<a target="_" href="<%="http://qr.qxyz.ru/?q="+bufferToShowModel.getQr()%>">
						<%="http://qr.qxyz.ru/?q="+bufferToShowModel.getQr()%>
					</a>
				</td>
			</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_CONTRACTNUM))%></td>
   	 			<td><%=msg.obj2html(bufferToShowModel.getContractum())%></td>
   	 		</tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_contractdate))%></td>
   	 			<td><%=msg.obj2html(bufferToShowModel.getContractdate())%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_MONEY))%></td>
   	 			<td><%=msg.obj2html(bufferToShowModel.getMoney())%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_SUPPLIER))%></td>
   	 			<td><%=msg.obj2html(bufferToShowModel.getSUPPLIER())%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_CLIENT))%></td>
   	 			<td><%=msg.obj2html(bufferToShowModel.getCLIENT())%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_PRODTYPE))%></td>
   	 			<td><%=msg.obj2html(bufferToShowModel.getPRODTYPE())%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_MODEL))%></td>
   	 			<td><%=msg.obj2html(bufferToShowModel.getMODEL())%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_SN))%></td>
   	 			<td><%=msg.obj2html(bufferToShowModel.getSN())%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_prodate))%></td>
   	 			<td><%=msg.obj2html(bufferToShowModel.getProdate())%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_shipdate))%></td>
   	 			<td><%=msg.obj2html(bufferToShowModel.getShipdate())%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_SALEDATE))%></td>
   	 			<td><%=msg.obj2html(bufferToShowModel.getSALEDATE())%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_DEPARTUREDATE))%></td>
   	 			<td><%=msg.obj2html(bufferToShowModel.getDEPARTUREDATE())%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_WARRANTYSTART))%></td>
   	 			<td><%=msg.obj2html(bufferToShowModel.getWARRANTYSTART())%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_WARRANTYEND))%></td>
   	 			<td><%=msg.obj2html(bufferToShowModel.getWARRANTYEND())%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_COMMENT))%></td>
   	 			<td><%=msg.obj2html(bufferToShowModel.getCOMMENT())%></td>
   	 		</tr>
   	 	</table>

</body>
</html>
