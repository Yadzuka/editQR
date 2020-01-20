<%@ 
	page contentType="text/html; charset=UTF-8" 
	import="org.eustrosoft.contractpkg.Controller.ControllerContracts"
	import="org.eustrosoft.contractpkg.Model.Contract" 
	import="java.io.PrintWriter"
	import="java.text.SimpleDateFormat"
%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Random" %>
<%@ page import="java.lang.reflect.Array" %>
<%!
	public static void generateQR(Contract contractToSetNewQr, String rangeParam, ArrayList<Contract> contractsArray){
		StringBuffer bufferForSecondPartOfLink = new StringBuffer();
		Integer maxZOID = Integer.parseInt(contractsArray.get(0).getZOID());
		for(int i = 0;i<contractsArray.size();i++){
			if(Integer.parseInt(contractsArray.get(i).getZOID()) > maxZOID)
				maxZOID = Integer.parseInt(contractsArray.get(i).getZOID());
		}
		maxZOID++;
		String s =  String.format("%s%03X",rangeParam, Long.valueOf(maxZOID));
		contractToSetNewQr.setQr(s);
	}
	public static String getCurrentDate4ZDATE()
	{
	return(new SimpleDateFormat("y-MM-dd HH:mm:ss Z").format(new Date()));
	}
	public static String getRequestUser4ZUID(HttpServletRequest request)
	{
		return(request.getRemoteUser() + "@" + request.getRemoteAddr());
	}
	//
	public org.eustrosoft.contractpkg.Model.MsgContract msg;

	// Actions that may be invoked
	public final String ACTION_EDIT = "edit";
	public final String ACTION_CREATE = "create";
	public final String ACTION_SAVE = "save";
	public final String ACTION_REFRESH = "refresh";
	public final String ACTION_CANCEL = "cancel";
	public final String ACTION_GENERATEQR ="genqr";
	public final String [] ACTIONS = {ACTION_EDIT,ACTION_CREATE,ACTION_SAVE,ACTION_REFRESH, ACTION_CANCEL, ACTION_GENERATEQR};
	
	// buttons
	public final String BTN_EDIT = ACTION_EDIT;
	public final String BTN_CREATE = ACTION_CREATE;	
	public final String BTN_SAVE = ACTION_SAVE;
	public final String BTN_REFRESH = ACTION_REFRESH;
	public final String BTN_CANCEL = ACTION_CANCEL;
	public final String BTN_GENERATEQR = ACTION_GENERATEQR;
	public final String [] BUTTONS = {BTN_EDIT, BTN_CREATE, BTN_SAVE, BTN_REFRESH, BTN_CANCEL, BTN_GENERATEQR};
	
	// NULL CONSTANT
	public final String SZ_NULL = "null";

	// 16 system to create default links
	final char [] availableSymbols = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};

	// All link length
	final int linkLength = 8;

	// Massive of all qr links
	ArrayList<String> allInaccessibleLinks;
%>
<%
String CGI_NAME = null; try{ CGI_NAME=(String)request.getAttribute("CGI_NAME"); } catch(Exception e){} //it's ok! see before&after
if(CGI_NAME == null) {out.println("<div> no attr_dispatch_canary - exit </div>"); return; }
String range = null; try{ range=(String)request.getParameter("range"); } catch(Exception e){}
String member = null; try{ member=(String)request.getParameter("member"); } catch(Exception e){}
%>
<html>
<head>
	<title>
		Update record
	</title>
	<link rel="stylesheet" type="text/css" href="css/head.css">
</head>
<%

	// From psql.jsp
	long enter_time = System.currentTimeMillis();
	long expire_time = enter_time + 24*60*60*1000;
	response.setHeader("Cache-Control","No-cache");
	response.setHeader("Pragma","no-cache");
	response.setDateHeader("Expires",expire_time);
	request.setCharacterEncoding("UTF-8");
//
	ControllerContracts contractController = new ControllerContracts(member,range);
	ArrayList<Contract> contractsArray = contractController.getContracts();

	int parsedContractParam;
	String memberParam = request.getParameter("member");
	String rangeParam = request.getParameter("range");
	String zoidParam = request.getParameter("zoid");
	String action = request.getParameter("action");
	if(!SZ_NULL.equals(zoidParam) && zoidParam != null)
		parsedContractParam = Integer.parseInt(zoidParam);
	else
		parsedContractParam = contractsArray.size();
	Contract bufferToShowModel = new Contract(member,range);

	// Count and add addresses witch are existing
	String unicsQR = contractsArray.get(0).getQr();
	allInaccessibleLinks = new ArrayList();
	allInaccessibleLinks.add(unicsQR);
	for(Contract c : contractsArray)
		if(c.getQr() != unicsQR)
			allInaccessibleLinks.add(c.getQr());


	if (request.getParameter(BTN_EDIT) != null) action = ACTION_EDIT;
	if (request.getParameter(BTN_CREATE) != null) action = ACTION_CREATE;
	if (request.getParameter(BTN_SAVE) != null) action = ACTION_SAVE;
	if (request.getParameter(BTN_REFRESH) != null) action = ACTION_REFRESH;
	if(request.getParameter(BTN_CANCEL) != null) action = ACTION_CANCEL;
	if(request.getParameter(BTN_GENERATEQR) != null) action = ACTION_GENERATEQR;
	if (!Arrays.asList(ACTIONS).contains(action)) action = null;
	//default action
	if (action == null) action = "edit"; //edit, create, save, refresh

	if(ACTION_GENERATEQR.equals(action)){

		StringBuffer bufferForSecondPartOfLink = new StringBuffer();
		Integer maxZOID = Integer.parseInt(contractsArray.get(0).getZOID());
		for(int i = 0;i<contractsArray.size();i++){
			if(Integer.parseInt(contractsArray.get(i).getZOID()) > maxZOID)
				maxZOID = Integer.parseInt(contractsArray.get(i).getZOID());
		}
		maxZOID++;
		String s =  String.format("%s%03x",rangeParam, Long.valueOf(maxZOID));
		bufferToShowModel.setQr(s);
	}

	if (ACTION_CANCEL.equals(action)) {
		bufferToShowModel.setZOID(request.getParameter("zoid"));

		if(SZ_NULL.equals(bufferToShowModel.getZOID()) || bufferToShowModel.getZOID() == null )
			response.sendRedirect(CGI_NAME+"?cmd=il&member="+memberParam+"&range="
					+rangeParam);
		else
			response.sendRedirect(CGI_NAME +"?cmd=iv&member="+memberParam+"&range="
					+rangeParam+"&zoid="+parsedContractParam);

	}
	if(ACTION_REFRESH.equals(action)){
		bufferToShowModel.setZOID(request.getParameter("zoid"));

		if(SZ_NULL.equals(bufferToShowModel.getZOID()) || bufferToShowModel.getZOID() == null )
			response.sendRedirect(CGI_NAME +"?cmd=ie&member="+memberParam+
					"&range="+rangeParam+"&action="+ACTION_CREATE);
		else
			response.sendRedirect(CGI_NAME +"?cmd=ie&member="+memberParam+
					"&range="+rangeParam+"&zoid="+parsedContractParam);
	}
	if (ACTION_EDIT.equals(action)) {
		bufferToShowModel = contractController.getContract(parsedContractParam);
	}
	// Set all model parameters
	if (ACTION_SAVE.equals(action)) {
		// STD_HEADER fields
		bufferToShowModel.setZOID(request.getParameter("ZOID"));
		// Write to file and set version to +1 of the latest
		Contract biggestZOIDContract = contractsArray.get(0);
		if (SZ_NULL.equals(bufferToShowModel.getZOID()) || bufferToShowModel.getZOID() == null) {
			Integer buffer = 0;
			for (int i = 0; i < contractsArray.size(); i++) {
				if (buffer < Integer.parseInt(contractsArray.get(i).getZOID()))
					biggestZOIDContract = contractsArray.get(i);
				buffer = Integer.parseInt(biggestZOIDContract.getZOID());
			}
			buffer++;
			bufferToShowModel.setZOID(buffer.toString());
		}

		bufferToShowModel.setZVER(request.getParameter("ZVER"));
		if (SZ_NULL.equals(bufferToShowModel.getZVER()) || bufferToShowModel.getZVER() == null) {
			bufferToShowModel.setZVER("0");
		}

		bufferToShowModel.setZDATE(getCurrentDate4ZDATE());
		bufferToShowModel.setZUID(msg.value2csv(getRequestUser4ZUID(request)));

		bufferToShowModel.setZSTA("N");
		// data fields
		bufferToShowModel.setQr(msg.value2csv(request.getParameter("Qr")));
		bufferToShowModel.setContractum(msg.value2csv(request.getParameter("contract")));
		bufferToShowModel.setContractdate(msg.value2csv(request.getParameter("Contractdate")));
		bufferToShowModel.setMoney(msg.value2csv(request.getParameter("Money")));
		bufferToShowModel.setSUPPLIER(msg.value2csv(request.getParameter("SUPPLIER")));
		bufferToShowModel.setCLIENT(msg.value2csv(request.getParameter("CLIENT")));
		bufferToShowModel.setPRODTYPE(msg.value2csv(request.getParameter("PRODTYPE")));
		bufferToShowModel.setMODEL(msg.value2csv(request.getParameter("MODEL")));
		bufferToShowModel.setSN(msg.value2csv(request.getParameter("SN")));
		bufferToShowModel.setProdate(msg.value2csv(request.getParameter("Prodate")));
		bufferToShowModel.setShipdate(msg.value2csv(request.getParameter("Shipdate")));
		bufferToShowModel.setSALEDATE(msg.value2csv(request.getParameter("SALEDATE")));
		bufferToShowModel.setDEPARTUREDATE(msg.value2csv(request.getParameter("DEPARTUREDATE")));
		bufferToShowModel.setWARRANTYSTART(msg.value2csv(request.getParameter("WARRANTYSTART")));
		bufferToShowModel.setWARRANTYEND(msg.value2csv(request.getParameter("WARRANTYEND")));
		bufferToShowModel.setCOMMENT(msg.value2csv(request.getParameter("COMMENT")));

		if (SZ_NULL.equals(bufferToShowModel.getQr()) || bufferToShowModel.getQr() == null) {
			Random randLinkCreater = new Random();
			String firstPartLink = rangeParam;
			StringBuilder secondLinkPart = new StringBuilder();

			String allLink = "";
			do {
				int remainderPartOfQr = linkLength - rangeParam.length();

				while (remainderPartOfQr != 0) {
					int buffer = randLinkCreater.nextInt(16);
					char randomCharToSecondPart = availableSymbols[buffer];
					secondLinkPart.append(randomCharToSecondPart);

					remainderPartOfQr--;
				}
				allLink = firstPartLink + secondLinkPart.toString();
			} while (allInaccessibleLinks.contains(allLink));
			bufferToShowModel.setQr(allLink);
		}

		String bufferToUpdateVersion = bufferToShowModel.getZVER();
		Integer numberOfSecondProductVersion = Integer.parseInt(bufferToUpdateVersion);
		bufferToShowModel.setZVER((++numberOfSecondProductVersion).toString());
		bufferToShowModel.createRecordInDB(bufferToShowModel.toString());

		response.sendRedirect(CGI_NAME + "?cmd=iv&member=" + memberParam + "&range="
				+ rangeParam + "&zoid=" + (contractsArray.size()));
	}

	if (ACTION_CREATE.equals(action)) {
		generateQR(bufferToShowModel,rangeParam,contractsArray);
	}
%>
<body>
<ul>
	<li><a href="<%= CGI_NAME %>">go home</a></li>
	<li><a href="<%= CGI_NAME %>?cmd=il&member=<%=memberParam%>&range=<%=rangeParam%>">Назад к списку контрактов</a></li>
</ul>
<br/>
<form action="<%= CGI_NAME %>?cmd=ie&member=<%=memberParam%>&range=<%=rangeParam%>&zoid=<%=zoidParam%>&action=<%=action%>" method="POST">

	<input type="submit" name="cancel" value="Отмена">
	<input type="submit" name="refresh" value="Обновить">
	<input type="submit" name="save" value="Сохранить">

		<input type="hidden" name="ZOID" value="<%=msg.obj2value(bufferToShowModel.getZOID())%>">
		<input type="hidden" name="ZVER" value="<%=msg.obj2value(bufferToShowModel.getZVER())%>">

		<table>
<!--
	   		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_QR))%></td>
				<td>
					<img src="engine/qr?codingString=<%=msg.obj2value(bufferToShowModel.getQr())%>"/>
				</td>
				<td></td>
			</tr>
-->
    		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_QR))%></td>
				<td>
					<input name="Qr" value="<%=msg.obj2value(bufferToShowModel.getQr())%>"/>
				</td>
				<td>
					<input type="submit" name="genqr" value="Сгенерировать новый код"/>
				<%=msg.obj2html(msg.getComment(msg.FN_QR))%>
				</td>
			</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_CONTRACTNUM))%></td>
   	 			<td><input name="contract" value="<%=msg.obj2value(bufferToShowModel.getContractum())%>"></td>
				<td><%=msg.obj2html(msg.getComment(msg.FN_CONTRACTNUM))%></td>
   	 		</tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_contractdate))%></td>
   	 			<td><input name="Contractdate" value="<%=msg.obj2value(bufferToShowModel.getContractdate())%>"></td>
				<td><%=msg.obj2html(msg.getComment(msg.FN_contractdate))%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_MONEY))%></td>
   	 			<td><input name="Money" value="<%=msg.obj2value(bufferToShowModel.getMoney())%>"></td>
				<td><%=msg.obj2html(msg.getComment(msg.FN_MONEY))%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_SUPPLIER))%></td>
   	 			<td><input name="SUPPLIER" value="<%=msg.obj2value(bufferToShowModel.getSUPPLIER())%>"></td>
				<td><%=msg.obj2html(msg.getComment(msg.FN_SUPPLIER))%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_CLIENT))%></td>
   	 			<td><input name="CLIENT" value="<%=msg.obj2value(bufferToShowModel.getCLIENT())%>"></td>
				<td><%=msg.obj2html(msg.getComment(msg.FN_CLIENT))%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_PRODTYPE))%></td>
   	 			<td><input name="PRODTYPE" value="<%=msg.obj2value(bufferToShowModel.getPRODTYPE())%>"></td>
				<td><%=msg.obj2html(msg.getComment(msg.FN_PRODTYPE))%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_MODEL))%></td>
   	 			<td><input name="MODEL" value="<%=msg.obj2value(bufferToShowModel.getMODEL())%>"></td>
				<td><%=msg.obj2html(msg.getComment(msg.FN_MODEL))%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_SN))%></td>
   	 			<td><input name="SN" value="<%=msg.obj2value(bufferToShowModel.getSN())%>"></td>
				<td><%=msg.obj2html(msg.getComment(msg.FN_SN))%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_prodate))%></td>
   	 			<td><input name="Prodate" value="<%=msg.obj2value(bufferToShowModel.getProdate())%>"></td>
				<td><%=msg.obj2html(msg.getComment(msg.FN_prodate))%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_shipdate))%></td>
   	 			<td><input name="Shipdate" value="<%=msg.obj2value(bufferToShowModel.getShipdate())%>"></td>
				<td><%=msg.obj2html(msg.getComment(msg.FN_shipdate))%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_SALEDATE))%></td>
   	 			<td><input name="SALEDATE" value="<%=msg.obj2value(bufferToShowModel.getSALEDATE())%>"></td>
				<td><%=msg.obj2html(msg.getComment(msg.FN_SALEDATE))%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_DEPARTUREDATE))%></td>
   	 			<td><input name="DEPARTUREDATE" value="<%=msg.obj2value(bufferToShowModel.getDEPARTUREDATE())%>"></td>
				<td><%=msg.obj2html(msg.getComment(msg.FN_DEPARTUREDATE))%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_WARRANTYSTART))%></td>
   	 			<td><input name="WARRANTYSTART" value="<%=msg.obj2value(bufferToShowModel.getWARRANTYSTART())%>"></td>
				<td><%=msg.obj2html(msg.getComment(msg.FN_WARRANTYSTART))%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_WARRANTYEND))%></td>
   	 			<td><input name="WARRANTYEND" value="<%=msg.obj2value(bufferToShowModel.getWARRANTYEND())%>"></td>
				<td><%=msg.obj2html(msg.getComment(msg.FN_WARRANTYEND))%></td>
   	 		</tr>
   	 		<tr>
	<td><%=msg.obj2html(msg.getCaption(msg.FN_COMMENT))%></td>
<!--
   	 			<td><input name="COMMENT" value="<%=msg.obj2value(bufferToShowModel.getCOMMENT())%>"></td>
-->
				<td colspan="2"><b><%=msg.obj2html(msg.getComment(msg.FN_COMMENT))%></b></td>
   	 		</tr>
   	 		<tr>
			<td colspan="3">
<textarea name="COMMENT" rows="10" cols="72"><%=msg.obj2value(bufferToShowModel.getCOMMENT())%></textarea>
			</td>
   	 		</tr>
   	 	</table>
	<input type="submit" name="save" value="Сохранить">
	<input type="submit" name="refresh" value="Обновить">
	<input type="submit" name="cancel" value="Отмена">
</form>

	<%
	
		// Correction level
		
		/*
		
		*/
	%>
<!-- Привет this is just for UTF-8 testing (must be russian word "Privet") -->	
</body>
</html>
