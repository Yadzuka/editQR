<%@ page import="org.eustrosoft.contractpkg.Model.Members" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.OutputStream" %>
<%@ page import="java.io.InputStream" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
		Members.setWayToDB("/s/www/qr.qxyz.ru/db/members/");
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
				<a href="ranges.jsp?member=<%=allRegisteredMembers[i]%>">
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
