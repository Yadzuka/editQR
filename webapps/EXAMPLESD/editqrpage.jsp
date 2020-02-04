<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@
        page import="java.util.*"
             import="java.io.*"
             import="org.eustrosoft.contractpkg.Controller.*"
             import="org.eustrosoft.contractpkg.Model.*"
             import="org.eustrosoft.contractpkg.zcsv.*"
             import="java.text.SimpleDateFormat"
             import="java.util.Date"
%>
<%@ page import="java.nio.file.Paths" %>
<%@ page import="java.nio.file.Files" %>
<%!
    private static final String CGI_NAME = "editqrpage.jsp";
    private final static String CGI_TITLE = "EDIT-QR.qxyz.ru - средство редактирования БД диапазонов QR-кодов для проданных изделий";
    private final static String JSP_VERSION = "$id$";
    public final String ACTION_EDIT = "edit";
    public final String ACTION_CREATE = "create";
    public final String ACTION_NEWRECORD = "new";
    public final String ACTION_SAVE = "save";
    public final String ACTION_REFRESH = "refresh";
    public final String ACTION_CANCEL = "cancel";
    public final String ACTION_GENERATEQR = "genqr";
    // constants for request paremeters
    public final static String PARAM_CMD="page"; // SIC! RENAME_IT : правда странно, когда PARAM_CMD!="cmd"
    public final static String PARAM_MEMBER="member";
    public final static String PARAM_RANGE="range";
    public final static String PARAM_ZRID="zrid";
    public final static String PARAM_ACTION="action";
    public final static String[] STD_REQUEST_PARAMETERS = {PARAM_MEMBER,PARAM_RANGE,PARAM_ZRID,PARAM_ACTION };
    // constants for CMD
    public final static String CMD_MEMBERS="members";
    public final static String CMD_RANGES="ranges";
    public final static String CMD_PRODTABLE="prodtable";
    public final static String CMD_PRODVIEW="prodview";
    public final static String CMD_UPDATE="updateprod";
    public final static String CMD_TEST="test";

    private boolean tryHack = false;

    private ZCSVFile zcsvFile;
    //private static String CMD; //SIC! static - это на весь сервлет, который обслуживает всех пользователей
    JspWriter out;

    private String QRDB_PATH = null; //SIC! а не статик общий для экземпляра, который тоже может обслуживать всех пользователей

    private String getRequestParameter(ServletRequest request, String param) {return(getRequestParameter(request,param,null));}
    private String getRequestParameter(ServletRequest request, String param, String default_value)
    {
     String value = request.getParameter(param);
     if(value==null) value = default_value;
     if(value==null) return(null); // null is valid, no check requred
     switch(param){ // check for shell injections attack
      case PARAM_MEMBER: 
      case PARAM_RANGE: 
        if (value.contains("/") || value.contains("..")) { throw new RuntimeException("shell injection detected"); } //!SIC надо облагородить потом
     }
     return(value);
    } // getRequestParameter

    private void setMembersPage() throws Exception {
        if (tryHack) { //!SIC не Hach а Hack раз, см SIC! к определению два
            out.print("<b>Bad game :)</b><br/> Don't try to hack us :)");
            tryHack = false;
        }

        Members members = new Members();
        String[] allRegisteredMembers = members.getCompanyNames();

        out.println("<table class=\"memberstable\" border=\"3\">");
        for (int i = 0; i < allRegisteredMembers.length; i++) {
            out.println("<tr>");
            printCell("<a href=\'" + CGI_NAME + "?page=ranges&member=" + allRegisteredMembers[i] + "\'>" + allRegisteredMembers[i] + "</a>");
            out.println("</tr>");
        }
        out.println("</table>");
    }

    private void setRangePage(String member) throws Exception {
        printUpsideMenu(
                new String[]{
                        "Назад",
                }, new String[]{
                        "page=members",
                });

        RangesController rController = new RangesController(member);
        String s = rController.getInfo();
        out.println(s);

        String[] allItems = rController.getRanges();
        out.println("<table><tr><th>Диапазон</th><th>Описание</th>");
        for (int i = 0; i < allItems.length; i++) {
            String range = allItems[i];
            out.println("<tr>");
            printCell("<a href=\'" + CGI_NAME + "?page=prodtable&member=" + member + "&range=" + range + "\'>" + range + "</a>");
            printCell(getNailedRangDesc(range, "Диапазон: " + range));
            out.println("</tr>");
        }
        out.println("</table>");
    }

    private void setProductsPage(String member, String range) throws Exception {
        printUpsideMenu(
                new String[]{
                        "Назад", "Создать новую запись",
                }, new String[]{
                        "page=ranges&member=" + member,
                        "page=updateprod&member=" + member + "&range=" + range + "&action=new"
                });

        String rootPath = Members.getWayToDB() + member + "/" + range + "/";
        zcsvFile = setupZCSVPaths(rootPath, "master.list.csv");

        if (Files.exists(Paths.get(zcsvFile.toString()))) {
            if (zcsvFile.tryOpenFile(1)) {
                zcsvFile.loadFromFileValidVersions();
                out.println("<table class=\"memberstable\" border=\"1\">");
                printProductsTableUpsideString(namesMap);

                for (int i = 0; i < zcsvFile.getFileRowsLength(); i++) {
                    ZCSVRow eachRow = zcsvFile.getRowObjectByIndex(i);
                    eachRow.setNames(namesMap);
                    out.println("<tr>");
                    printCell(
                            "<a href=\'" + CGI_NAME + "?page=prodview&member=" + member + "&range=" + range + "&zrid=" + eachRow.get(0) + "\'>" +
                                    "<карточка>" + "</a>");
                    for (int j = 5; j < eachRow.getNames().length; j++) {
                        printCell((eachRow.get(j) == null || "null".equals(eachRow.get(j)) ? "" : eachRow.get(j)));
                    }
                    out.println("</tr>");
                }
                out.println("</table>");
            } else {
                printerr("Can't open file! Call the system administrator!");
            }
        } else {
            printerr("File doesn't exists! Call the system administrator!");
        }
    }

    private void setProdViewPage(String member, String range, String ZRID) throws Exception {
        printUpsideMenu(
                new String[]{
                        "Назад", "Изменить запись",
                }, new String[]{
                        "page=prodtable&member=" + member + "&range=" + range,
                        "page=updateprod&member=" + member + "&range=" + range + "&zrid=" + ZRID + "&action=edit"
                });

        ZCSVRow row = zcsvFile.getRowObjectByIndex(Integer.parseInt(ZRID) - 1);

        out.println("<table>");
        out.print("<tr>");
        out.print("<img src=\"engine/qr?codingString=" + row.get(5) + "\">");
        out.print("<tr>");
        for (int i = 5; i < row.getNames().length; i++) {
            out.println("<tr>");
            printCell((row.getNames()[i] == null) ? "" : row.getNames()[i]);
            printCell((row.get(i) == null | "null".equals(row.get(i))) ? "" : row.get(i));
            out.println("</tr>");
        }
        out.println("</table>");
    }

    private void setUpdateProductPage(String member, String range, String ZRID, String action) throws Exception {
        printUpsideMenu(
                new String[]{
                        "Назад", "change name map(Experimental)"
                }, new String[]{
                        "page=prodview&member=" + member + "&range=" + range + "&zrid=" + ZRID,
                        "page=updateprod&member=" + member + "&range=" + range + "&zrid=" + ZRID + "action=changenm",
                });
        ZCSVRow row = zcsvFile.getRowObjectByIndex(Integer.parseInt(ZRID) - 1);
        println();
        printUpdateTable(member, range, ZRID, action, row);
    }

    // SIC! ВНИМАТЕЛЬНО СМ НИЖЕ
    // SIC! printUpdateTable и printNewRecordTable надо объеденить в printEditForm() в них нет разницы,
    // SIC! Старик Оккам завещал нам : "не плодите сущностей, сверх необходимости" 
    // SIC! СМ ВЫШЕ 
    private void printUpdateTable(String member, String range, String ZRID, String action, ZCSVRow row) throws Exception {
        if (row != null) {
            if (row.getNames() != null) {
                startUpdateForm(member, range, ZRID, action);
                printUpdatePageButtons();
                out.println("<table>");
                for (int i = 5; i < row.getNames().length; i++) {
                    String showingParameter = (row.get(i) == null || "null".equals(row.get(i))) ? "" : row.get(i);
                    if (!row.getNames()[i].toLowerCase().contains("комментарий")) {
                        printTableRow(new Object[]{row.getNames()[i], "<input type=\"text\" name=" + i + " value=" + showingParameter + ">"});
                    } else {
                        printTableRow(new Object[]{row.getNames()[i], "<textarea name=" + i + " " +
                                "rows=\"5\" cols='40'>" + showingParameter + "</textarea>"});
                    }
                }
                out.println("</table>");
                endForm();
            } else
                throw new ZCSVException("Names won't be setted! Call the system administramtor!");
        } else {
            throw new Exception("Unknown exception"); // SIC! ммм просто Exception? - Может быть IOException, но не уверен... Тут завязана на ошибке, которая может возникнуть при написании через JSPWriter
        }
    }

    private void printEditForm(String member, String range, String ZRID, String action) throws Exception {
        if(ZRID == null || "null".equals(ZRID)){
            
        }else{
            Integer numberOfRow = Integer.parseInt(ZRID);
            ZCSVRow edittedRow = zcsvFile.editRowObjectByIndex(numberOfRow - 1);
            
            
        }
    }

    private void setNewRecordPage(String member, String range, String action) throws Exception {
        printUpsideMenu(
                new String[]{
                        "Назад", "change name map(Experimental)"
                }, new String[]{
                        "page=prodtable&member=" + member + "&range=" + range,
                        "page=updateprod&member=" + member + "&range=" + range + "action=changenm",
                });
        println();
        printNewRecordTable(member, range, action);
    }
    
    private void printNewRecordTable(String member, String range, String action) throws Exception {
        startCreateForm(member, range, action);
        printUpdatePageButtons();

        out.println("<table>");
        for (int i = 5; i < namesMap.length; i++) {
            if (!namesMap[i].toLowerCase().contains("комментарий")) {
                printTableRow(new Object[]{namesMap[i], "<input type='text' name=" + i + ">"}); //!SIC лучше i -> REC_PREFIX + i -> getFieldName(i)
            } else {
                printTableRow(new Object[]{namesMap[i], "<textarea name=" + i + " " +
                        "rows='5' cols='40'> </textarea>"});
            }
        }
        out.println("</table>");
        endForm();
    }

    private void printUpdatePageButtons() throws Exception {
        out.print("<input type=\"submit\" name=\"cancel\" value=\"Отмена\"/>&nbsp;");
        out.print("<input type=\"submit\" name=\"refresh\" value=\"Сбросить\"/>&nbsp;");
        out.print("<input type=\"submit\" name=\"save\" value=\"Сохранить\"/>&nbsp;");
    }

    private void startCreateForm(String member, String range, String action) throws Exception {
        action = "save"; // !SIC строка внизу + member -> + encode_url_value(member) -> + euv(member) и так везде надо
        out.println("<form action=\"" + CGI_NAME + "?page=updateprod&member=" + member + "&range=" + range + "&action=" + action + "\" method=\"POST\">");
    }

    private void startUpdateForm(String member, String range, String ZRID, String action) throws Exception {
        action = "save";
        out.println("<form action=\"" + CGI_NAME + "?page=updateprod&member=" + member + "&range=" + range + "&zrid=" + ZRID + "&action=" + action + "\" method=\"POST\">");
    }

    private void endForm() throws Exception {
        out.println("</form>");
    }

    private ZCSVFile setupZCSVPaths(String rootPath, String fileName) {
        ZCSVFile file = new ZCSVFile();
        file.setRootPath(rootPath);
        file.setFileName(fileName);
        return file;
    }

    private void printUpsideMenu(String[] menuItems, String[] menuReferences) throws IOException {
        out.println("<ul>");
        for (int i = 0; i < menuItems.length; i++) {
            out.print("<li>");
            out.println("<a href=\'" + CGI_NAME + "?" + menuReferences[i] + "\'>" + menuItems[i] + "</a>");
            out.print("</li>");
        }
        out.println("</ul>");
        out.println("<br/>");
    }

    private void printProductsTableUpsideString(String... outputString) throws Exception { //SIC! а так можно? за это уже не сажают? ;) - А раньше сажали? :)
        out.println("<tr>");
        for (int i = 4; i < outputString.length; i++) {
            if (i == 4) printCell("Опции");
            else printCell(outputString[i]);
        }
        out.println("</tr>");
    }

    private void printTableRow(Object[] data) throws Exception { 
        out.println("<tr>");
        for (int i = 0; i < data.length; i++) {
            printCell(data[i]);
        }
        out.println("</tr>");
    }

    private void printCell(Object tElement) throws IOException { 
        out.println("<td>");
        out.println(obj2str(tElement));
        out.println("</td>");
    }

    public static String getCurrentDate4ZDATE() throws Exception {
        return (new SimpleDateFormat("y-MM-dd HH:mm:ss Z").format(new Date()));
    }

    public static String getRequestUser4ZUID(HttpServletRequest request) throws Exception{
        return (request.getRemoteUser() + "@" + request.getRemoteAddr());
    }

    private String obj2str(Object obj) {
        return obj.toString(); //SIC! ой, а если obj == null  будет NullPointerException...
    }
    
    public void println() throws Exception {
        out.println("<br/>");
    }

    public void printerr(String msg) throws Exception {
        out.print("<b>" + msg + "</b>");
    }

    public void printerrln(String msg) throws Exception {
        printerr(msg);
        println();
    }

    public void set_request_hints(HttpServletRequest request, HttpServletResponse response)
            throws IOException { //SIC! этому куску кода уже 15 лет, надо разобраться как сделать лучше, он еще для NN 4.x
        long enter_time = System.currentTimeMillis();
        long expire_time = enter_time + 24 * 60 * 60 * 1000;
        response.setHeader("Cache-Control", "No-cache");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", expire_time);
        request.setCharacterEncoding("UTF-8");
    }

    private void read_parameters_from_web_xml() {
        QRDB_PATH = getServletContext().getInitParameter("QRDB_PATH");
    }

    private String[] NAILED_RANGE_DESC = { //!SIC прибивать гвоздями плохо, просто 31-го очень к столу успеть хотелось
            "01000", "(Пример) - по каждому объекту (QR-коду) ведется отдельная страница",
            "0100A", "(Пример) здесь будет пример информации защищенной паролем",
            "0100F", "(Пример) здесь будет пример перенаправления на другие сайты",
            "0100D", "(Пример) Примеры на основе первых проданных двигателей TDME",
            "0100E", "(Пример) Отладочный пример, на основе данных Доминатор 01012 - реальные продажи TDME 2010-2017",
            "01011", ":+:2019-11-18:DOMINATOR:list:Данные о продажах от начала работы до конца 2011 г",
            "01012", "Доминатор - реальные продажи TDME 2010-2017 (Money_2)",
            "01017", "DOMINATOR:list:Данные о продажах в 2017 г. (предложение к использованию)",
            "01018", "DOMINATOR:list:Данные о продажах в 2018 г. (предложение к использованию)",
            "01019", ":+:2019-11-24:DOMINATOR:list:Данные о продажах в 2019 г.",
            "0101A", ":+:2019-11-24:DOMINATOR:list:Данные о продажах в 2020 г.",
            "0101E", ":+:2019-11-27:DOMINATOR::Diesel Engines models",
            "01020", ":+:2019-11-21:EUSTROSOFT::Various EustroSoft QR-info pages",
            "01021", ":+:2019-12-22:EUSTROSOFT::EustroSoft's inventory-list",
            "01030", ":-:2019-12-17:NS-RESERVED",
            "01031", ":-:2019-12-17:MH-RESERVED",
            "01032", ":-:2019-12-17:GL-RESERVED",
            "01033", ":-:2019-12-17:MA-RESERVED",
            "01034", ":-:2019-12-17:SN-RESERVED",
            "01035", ":-:2019-12-22:LYRA-SNT",
            "01036", "выделен 2019-12-22 для rubmaster.ru",
            "01037", "выделен 2019-12-22 для boatswain.org",
            "FFFF", ""
    };

    private String[] namesMap = new String[]
            {"ZRID", "ZVER", "ZDATE", "ZUID", "ZSTA", "QR  код", "№ договора", "Дата договора",
                    "Деньги по договору", "Юр-лицо поставщик", "Юр-лицо клиент", "Тип продукта", "Модель продукта",
                    "SN", "Дата производства", "Дата ввоза (ГТД)",
                    "Дата продажи", "Дата отправки клиенту", "Дата начала гарантии",
                    "Дата окончания гарантии", "Комментарий (для клиента)"};

    public String getNailedRangDesc(String r, String desc) {
        int i = 0;
        String new_desc = desc;
        if (new_desc == null) new_desc = "";
        for (i = 0; i < (NAILED_RANGE_DESC.length / 2); i++) {
            if (NAILED_RANGE_DESC[i * 2].equals(r)) {
                new_desc = new_desc + " " + NAILED_RANGE_DESC[i * 2 + 1];
                break;
            }
        }
        return (new_desc);
    }
%>
<html>
<head>
    <title><%= CGI_TITLE %>
    </title>
    <link rel="stylesheet" type="text/css" href="css/webcss.css">
    <link rel="stylesheet" type="text/css" href="css/head.css">
</head>
<body>
<h2><%= CGI_TITLE %>
</h2>
<hr>
<div>
    <a href='<%= CGI_NAME %>'>Начало</a>&nbsp;
    <a href='<%= CGI_NAME %>?page=test'>Тест</a>&nbsp;
    <a href='test.jsp'>test.jsp</a>&nbsp;
    <!--
    -->
</div>
<%
    set_request_hints(request, response);
    long enter_time = System.currentTimeMillis();
    this.out = out;
    String CMD = getRequestParameter(request, PARAM_CMD, CMD_MEMBERS);

    try {
        read_parameters_from_web_xml(); //SIC! следующие 4 строки не в том порядке - раз, не защищают от пустого пути - два
        Members.setWayToDB(QRDB_PATH);
        if (QRDB_PATH == null) {
            printerr("QRDB_PATH параметр не задан! отредактируйте WEB-INF/web.xml"); //SIC! а если он будет не из web.xml кто всмомнит это переписать?
        }

        String p_member = getRequestParameter(request,PARAM_MEMBER); // shell injection checed inside getRequestParameter
        String p_range = getRequestParameter(request,PARAM_RANGE); // shell injection checed inside getRequestParameter
        String p_ZRID = getRequestParameter(request,PARAM_ZRID);
        String p_action = getRequestParameter(request,PARAM_ACTION);
        String[] parameters = STD_REQUEST_PARAMETERS; // was: {"member", "range", "zrid", "action"};
        for (int i = 0; i < parameters.length; i++) { // SIC! DEV_NULL этот блок кода уйдет в /dev/null и предыдущую строку возьмет с собой
            String parameter = request.getParameter(parameters[i]);
            if (parameter != null) {
                if (parameter.contains("/") || parameter.contains("..")) {
                    tryHack = true;
                    response.sendRedirect("editqrpage.jsp"); //SIC! CGI_NAME у нас зачем ;)
                } else {
                    tryHack = false;
                }
            }
        }

        switch (CMD) {
            case CMD_MEMBERS:
                setMembersPage();
                break;
            case CMD_RANGES:
                setRangePage(p_member);
                break;
            case CMD_PRODTABLE:
                setProductsPage(p_member, p_range);
                break;
            case CMD_PRODVIEW:
                setProdViewPage(p_member, p_range, p_ZRID);
                break;
            case CMD_UPDATE:
                String action = p_action; //SIC! а теперь - упростить
                if (ACTION_EDIT.equals(action))
                    setUpdateProductPage(p_member, p_range, p_ZRID, p_action);
                if (ACTION_NEWRECORD.equals(action))
                    setNewRecordPage(p_member, p_range, p_action);
                if (ACTION_SAVE.equals(action)) {
                    Integer zrdsLength = zcsvFile.getRowObjects().size();
                    ZCSVRow newRow;
                    System.out.println("saved");
                    if(p_ZRID == null || "null".equals(p_ZRID)) {
                        newRow = new ZCSVRow();
                        newRow.setNames(namesMap);
                        newRow.setStringSpecificIndex(0, zrdsLength.toString());
                        newRow.setStringSpecificIndex(1, "1");
                    }
                    else {
                        newRow = zcsvFile.getRowObjectByIndex(Integer.parseInt(p_ZRID)); //!SIC а здесь NumberFormatException словить только так
                        System.out.println("New row checked");
                    }
/*
                    newRow.setStringSpecificIndex(2, new Date().toString());
                    newRow.setStringSpecificIndex(3, request.getRemoteUser().toString());
                    newRow.setStringSpecificIndex(4, "N");

                    for (Integer i = 5; i < namesMap.length; i++) {
                        newRow.setStringSpecificIndex(i, request.getParameter(i.toString()));
                    }
                    zcsvFile.getRowObjects().add(newRow);
                    zcsvFile.appendChangedStringsToFile();
                    out.print("Saved");
*/
                }
                break;
            case "test":
                out.print("Hello test page!");
                break;
            default:
                request.getRequestDispatcher("editqrpage.jsp?page=members").forward(request, response); //SIC! CGI_NAME у нас зачем ;) forward - в топку
                break;
        }
    } catch (IOException ex) {
        if (ex.getMessage() != null && !("null".equals(ex.getMessage())))
            out.println(ex.getMessage() + "Call the system administrator please.");
        else
            out.println("IO unexpected error occered! Call the system administrator please.");
    } catch (ZCSVException ex) {
        if (ex.getMessage() != null && !("null".equals(ex.getMessage())))
            out.println(ex.printError() + "Call the system administrator please.");
        else
            out.println("ZCSV unexpected error occered! Call the system administrator please.");
    } catch (Exception ex) {
        if (ex.getMessage() != null && !("null".equals(ex.getMessage())))
            out.print(ex.getMessage() + "Call the system administrator please.");
        else
            out.println("Unexpected error occured! Call the system administrator please.");
    }
%>

<hr>
<i>timing : <%= ((System.currentTimeMillis() - enter_time) + " ms") %>
</i>
<br>
Hello! your web-server is <%= application.getServerInfo() %><br>
<i><%= JSP_VERSION %>
</i>
<!-- Привет this is just for UTF-8 testing (must be russian word "Privet") -->
</body>
</html>
