<%@ 
	page contentType="text/html; charset=UTF-8" 
	import="org.eustrosoft.contractpkg.Controller.ControllerContracts"
	import="org.eustrosoft.contractpkg.Model.Contract" 
	import="java.io.PrintWriter"
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
		String s =  String.format("%s%03x",rangeParam, Long.valueOf(maxZOID));
		contractToSetNewQr.setQr(s);
	}

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
	ControllerContracts contractController = new ControllerContracts();
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
	Contract bufferToShowModel = new Contract();

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
			response.sendRedirect("productstable.jsp?member="+memberParam+"&range="
					+rangeParam);
		else
			response.sendRedirect("productview.jsp?member="+memberParam+"&range="
					+rangeParam+"&zoid="+parsedContractParam);

	}
	if(ACTION_REFRESH.equals(action)){
		bufferToShowModel.setZOID(request.getParameter("zoid"));

		if(SZ_NULL.equals(bufferToShowModel.getZOID()) || bufferToShowModel.getZOID() == null )
			response.sendRedirect("update.jsp?member="+memberParam+
					"&range="+rangeParam+"&action="+ACTION_CREATE);
		else
			response.sendRedirect("update.jsp?member="+memberParam+
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

		bufferToShowModel.setZDATE(new Date().toString());
		bufferToShowModel.setZUID(request.getRemoteUser());
		bufferToShowModel.setZSTA("N");
		// data fields
		bufferToShowModel.setQr(request.getParameter("Qr"));
		bufferToShowModel.setContractum(request.getParameter("contract"));
		bufferToShowModel.setContractdate(request.getParameter("Contractdate"));
		bufferToShowModel.setMoney(request.getParameter("Money"));
		bufferToShowModel.setSUPPLIER(request.getParameter("SUPPLIER"));
		bufferToShowModel.setCLIENT(request.getParameter("CLIENT"));
		bufferToShowModel.setPRODTYPE(request.getParameter("PRODTYPE"));
		bufferToShowModel.setMODEL(request.getParameter("MODEL"));
		bufferToShowModel.setSN(request.getParameter("SN"));
		bufferToShowModel.setProdate(request.getParameter("Prodate"));
		bufferToShowModel.setShipdate(request.getParameter("Shipdate"));
		bufferToShowModel.setSALEDATE(request.getParameter("SALEDATE"));
		bufferToShowModel.setDEPARTUREDATE(request.getParameter("DEPARTUREDATE"));
		bufferToShowModel.setWARRANTYSTART(request.getParameter("WARRANTYSTART"));
		bufferToShowModel.setWARRANTYEND(request.getParameter("WARRANTYEND"));
		bufferToShowModel.setCOMMENT(request.getParameter("COMMENT"));

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

		response.sendRedirect("productview.jsp?member=" + memberParam + "&range="
				+ rangeParam + "&zoid=" + (contractsArray.size()));
	}

	if (ACTION_CREATE.equals(action)) {
		generateQR(bufferToShowModel,rangeParam,contractsArray);
	}
%>
<body>
<ul>
	<li><a href="/Contracts_1_0_SNAPSHOT_war/">go home</a></li>
	<li><a href="productstable.jsp?member=<%=memberParam%>&range=<%=rangeParam%>">Назад к списку контрактов</a></li>
</ul>
<br/>
<form action="update.jsp?member=<%=memberParam%>&range=<%=rangeParam%>&zoid=<%=zoidParam%>&action=<%=action%>" method="POST">

	<input type="submit" name="cancel" value="Отмена">
	<input type="submit" name="refresh" value="Обновить">
	<input type="submit" name="save" value="Сохранить">

		<input type="hidden" name="ZOID" value="<%=bufferToShowModel.getZOID()%>">
		<input type="hidden" name="ZVER" value="<%=bufferToShowModel.getZVER()%>">

		<table>
	   		<tr>
	   			<td>Картинка qr: </td>
				<td>
					<img src="engine/qr?codingString=<%=bufferToShowModel.getQr()%>"/>
				</td>
			</tr>
    		<tr>
    			<td>Ссылка: </td>
				<td>
					<input name="Qr" value="<%=bufferToShowModel.getQr()%>"/>
				</td>
				<td>
					<input type="submit" name="genqr" value="Сгенерировать новый код"/>
				</td>
			</tr>
   	 		<tr>
   	 			<td>Контракт: </td>
   	 			<td><input name="contract" value="<%=bufferToShowModel.getContractum()%>"></td>
   	 		</tr>
   	 		   	<td>Дата контракта: </td>
   	 			<td><input name="Contractdate" value="<%=bufferToShowModel.getContractdate()%>"></td>
   	 		</tr>
   	 		<tr>
   	 			<td>Сумма: </td>
   	 			<td><input name="Money" value="<%=bufferToShowModel.getMoney()%>"></td>
   	 		</tr>
   	 		<tr>
   	 			<td>Поставщик: </td>
   	 			<td><input name="SUPPLIER" value="<%=bufferToShowModel.getSUPPLIER()%>"></td>
   	 		</tr>
   	 		<tr>
   	 			<td>Клиент: </td>
   	 			<td><input name="CLIENT" value="<%=bufferToShowModel.getCLIENT()%>"></td>
   	 		</tr>
   	 		<tr>
   	 			<td>Тип продукта: </td>
   	 			<td><input name="PRODTYPE" value="<%=bufferToShowModel.getPRODTYPE()%>"></td>
   	 		</tr>
   	 		<tr>
   	 			<td>Модель: </td>
   	 			<td><input name="MODEL" value="<%=bufferToShowModel.getMODEL()%>"></td>
   	 		</tr>
   	 		<tr>
   	 			<td>Номер серии: </td>
   	 			<td><input name="SN" value="<%=bufferToShowModel.getSN()%>"></td>
   	 		</tr>
   	 		<tr>
   	 			<td>Дата изготовления: </td>
   	 			<td><input name="Prodate" value="<%=bufferToShowModel.getProdate()%>"></td>
   	 		</tr>
   	 		<tr>
   	 			<td>Дата привоза: </td>
   	 			<td><input name="Shipdate" value="<%=bufferToShowModel.getShipdate()%>"></td>
   	 		</tr>
   	 		<tr>
   	 			<td>Дата продажи: </td>
   	 			<td><input name="SALEDATE" value="<%=bufferToShowModel.getSALEDATE()%>"></td>
   	 		</tr>
   	 		<tr>
   	 			<td>Дата отсыла: </td>
   	 			<td><input name="DEPARTUREDATE" value="<%=bufferToShowModel.getDEPARTUREDATE()%>"></td>
   	 		</tr>
   	 		<tr>
   	 			<td>Начало гарантии: </td>
   	 			<td><input name="WARRANTYSTART" value="<%=bufferToShowModel.getWARRANTYSTART()%>"></td>
   	 		</tr>
   	 		<tr>
   	 			<td>Конец гарантии: </td>
   	 			<td><input name="WARRANTYEND" value="<%=bufferToShowModel.getWARRANTYEND()%>"></td>
   	 		</tr>
   	 		<tr>
   	 			<td>Комментарий: </td>
   	 			<td><input name="COMMENT" value="<%=bufferToShowModel.getCOMMENT()%>"></td>
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