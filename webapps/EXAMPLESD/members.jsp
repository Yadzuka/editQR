<%@ page import="org.eustrosoft.contractpkg.Model.Members" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.OutputStream" %>
<%@ page import="java.io.InputStream" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String CGI_NAME = null; try{ CGI_NAME=(String)request.getAttribute("CGI_NAME"); } catch(Exception e){} //it's ok! see before&after
if(CGI_NAME == null) {out.println("<div> no attr_dispatch_canary - exit </div>"); return; }
%>
<html>
<head>
	<title>
		Member's table
	</title>
	<link rel="stylesheet" type="text/css" href="css/webcss.css"/>
	<link rel="stylesheet" type="text/css" href="css/head.css">
</head>
<body>


	<%
	//	Members.setWayToDB("/s/www/qr.qxyz.ru/db/members/");
	%>
	<table class="memberstable" border="3">
		<tr>
			<td>Organization names</td>
		</tr>
    <%
		// Set global parameters
		Members members = new Members(); // Use member's bean to taking all need information
		String [] allRegisteredMembers = members.getCompanyNames();
		// Cycle for each member ( directory ) in the main (members) path
		for(int i =0; i <  members.getMembersCounter(); i++) {
			// It also sets directory name in GET parameter
			
	%>
		<tr>
			<td>
				<a href="<%= CGI_NAME %>?cmd=rl&member=<%=allRegisteredMembers[i]%>">
					<%= allRegisteredMembers[i] %>
				</a>
			</td>
		</tr>
	<% } %>
		<form>
			<input type="submit" name="Опубликовать" value="Enter">


		</form>
	</table>
</body>
</html>
