<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.util.*"
         import="java.io.*"
         import="org.eustrosoft.contractpkg.Controller.*"
         import="org.eustrosoft.contractpkg.Model.*"
         import="org.eustrosoft.contractpkg.zcsv.*"
         import="java.text.SimpleDateFormat"
         import="java.util.Date"
         import="java.nio.file.Paths"
         import="java.nio.file.Files"
%>
<%!
    /// T - table

    private static final String CGI_NAME = "editqrpage.jsp";
    private final static String CGI_TITLE = "EDIT-QR.qxyz.ru - средство редактирования БД диапазонов QR-кодов для проданных изделий";
    private final static String JSP_VERSION = "$id$";

    private final String DB_FILENAME = "master.list.csv";
    private final String SZ_NULL = "null";

    public final String ACTION_EDIT = "edit";
    public final String ACTION_CREATE = "create";
    public final String ACTION_NEWRECORD = "new";
    public final String ACTION_SAVE = "save";
    public final String ACTION_REFRESH = "refresh";
    public final String ACTION_CANCEL = "cancel";
    public final String ACTION_GENERATEQR = "genqr";
    public final String ACTION_CHANGENAMEMAP = "changenamemap";
    // constants for request paremeters
    public final static String PARAM_CMD="cmd"; // SIC! RENAME_IT : правда странно, когда PARAM_CMD!="cmd"
    public final static String PARAM_MEMBER="member";
    public final static String PARAM_RANGE="range";
    public final static String PARAM_ZRID="zrid";
    public final static String PARAM_ACTION="action";
    public final static String[] STD_REQUEST_PARAMETERS = {PARAM_CMD, PARAM_MEMBER,PARAM_RANGE,PARAM_ZRID,PARAM_ACTION };
    // constants for CMD
    public final static String CMD_MEMBERS="members";
    public final static String CMD_RANGES="ranges";
    public final static String CMD_PRODTABLE="prodtable";
    public final static String CMD_PRODVIEW="prodview";
    public final static String CMD_UPDATE="updateprod";
    public final static String CMD_TEST="test";
    private final static String [] CMD_PARAMETERS = {CMD_MEMBERS,CMD_RANGES,CMD_PRODTABLE,CMD_PRODVIEW,CMD_UPDATE,CMD_TEST};

    private ZCSVFile zcsvFile;
    private String QRDB_PATH = null;
    private JspWriter out;
    private String[] namesMap = new String[]
            {"ZRID", "ZVER", "ZDATE", "ZUID", "ZSTA", "QR  код", "№ договора", "Дата договора",
                    "Деньги по договору", "Юр-лицо поставщик", "Юр-лицо клиент", "Тип продукта", "Модель продукта",
                    "SN", "Дата производства", "Дата ввоза (ГТД)",
                    "Дата продажи", "Дата отправки клиенту", "Дата начала гарантии",
                    "Дата окончания гарантии", "Комментарий (для клиента)"};


    private String getRequestParameter(ServletRequest request, String param) {
        return(getRequestParameter(request,param,null));
    }

    private String getRequestParameter(ServletRequest request, String param, String default_value)
    {
     String value = request.getParameter(param);
     if(value==null)
         value = default_value;
     if(value==null)
         return(null);
     switch(param) {
        case PARAM_MEMBER:
        case PARAM_RANGE:
            if (checkShellInjection(value)) { throw new RuntimeException("Shell injection detected"); } // SIC!
        }
        return(value);
    }

    private void setMembersPage() throws Exception {
        Members members = new Members();
        String[] allRegisteredMembers = members.getCompanyNames();

        beginT();
        for (int i = 0; i < allRegisteredMembers.length; i++) {
            beginTRow();
            printCell("<a href=\'" + getRequestParamsURL(CGI_NAME, CMD_RANGES, allRegisteredMembers[i]) + "\'>" + allRegisteredMembers[i] + "</a>");
            endTRow();
        }
        endT();
    }

    private void setRangesPage(String member) throws Exception {
        printUpsideMenu(
                new String[]{
                        "Назад",
                }, new String[]{
                        getRequestParamsURL(CMD_MEMBERS),
                });

        RangesController rController = new RangesController(member);
        String s = rController.getInfo();
        out.println(s);

        String[] allItems = rController.getRanges();
        out.println("<table><tr><th>Диапазон</th><th>Описание</th>");
        for (int i = 0; i < allItems.length; i++) {
            String range = allItems[i];
            beginTRow();
            printCell("<a href=\'" + getRequestParamsURL(CGI_NAME, CMD_PRODTABLE, member, range) + "\'>" + range + "</a>");
            printCell(getNailedRangDesc(range, "Диапазон: " + range));
            endTRow();
        }
        beginT();
    }

    private void setProductsPage(String member, String range) throws Exception {
        printUpsideMenu(
                new String[]{
                        "Назад",
                        "Создать новую запись",
                }, new String[]{
                        getRequestParamsURL(CMD_RANGES , member),
                        getRequestParamsURL(CMD_UPDATE , member, range, SZ_NULL, ACTION_NEWRECORD),
                });

        String rootPath = Members.getWayToDB() + member + "/" + range + "/";
        zcsvFile = setupZCSVPaths(rootPath, DB_FILENAME);

        if (Files.exists(Paths.get(zcsvFile.toString()))) {
            if (zcsvFile.tryOpenFile(1)) {
                zcsvFile.loadFromFileValidVersions();
                out.println("<table class=\"memberstable\" border=\"1\">");
                printProductsTableUpsideString(namesMap);

                for (int i = 0; i < zcsvFile.getFileRowsLength(); i++) {
                    ZCSVRow eachRow = zcsvFile.getRowObjectByIndex(i);
                    eachRow.setNames(namesMap);
                    beginTRow();
                    printCell("<a href=\'" + getRequestParamsURL(CGI_NAME, CMD_PRODVIEW, member, range, String.valueOf(i)) + "\'>" +
                                    "<карточка>" + "</a>");
                    for (int j = 5; j < namesMap.length; j++) {
                        String wroteString = (eachRow.get(j) == null || SZ_NULL.equals(eachRow.get(j))) ? "" : eachRow.get(j);
                        printCell(wroteString);
                    }
                    endTRow();
                }
                endT();
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
                        "Назад",
                        "Изменить запись",
                }, new String[]{
                        getRequestParamsURL(CMD_PRODTABLE, member, range),
                        getRequestParamsURL(CMD_UPDATE, member, range, ZRID, ACTION_EDIT),
                });

        ZCSVRow row = zcsvFile.getRowObjectByIndex(Integer.parseInt(ZRID));

        beginT();
        beginTRow();
        printCell("QR картинка:");
        beginTCell();
        out.print("<img src=\"qr?p_codingString=" + row.get(5) + "&p_imgFormat=GIF&p_imgSize=150&p_imgColor=0xFF00FF\"/>");
        endTCell();
        beginTRow();
        for (int i = 5; i < row.getNames().length; i++) {
            beginTRow();
            printCell((row.getNames()[i] == null) ? "" : row.getNames()[i]);
            printCell((row.get(i) == null | SZ_NULL.equals(row.get(i))) ? "" : row.get(i));
            endTRow();
        }
        beginT();
    }

    private void setUpdateProductPage(String member, String range, String ZRID, String action) throws Exception {
        printUpsideMenu(
                new String[]{
                        "Назад",
                        "change name map(Experimental)",
                }, new String[]{
                        getRequestParamsURL(CMD_PRODVIEW, member, range, ZRID),
                        getRequestParamsURL(CMD_UPDATE , member, range, ZRID, ACTION_CHANGENAMEMAP),
                });

        printEditForm(member, range, ZRID, action);
    }

    private void setNewRecordPage(String member, String range, String action) throws Exception {
        printUpsideMenu(
                new String[]{
                        "Назад",
                        "change name map(Experimental)",
                }, new String[]{
                        getRequestParamsURL(CMD_PRODTABLE, member, range),
                        getRequestParamsURL(CMD_UPDATE, member, range, null, ACTION_CHANGENAMEMAP),
                });
        println();
        printEditForm(member, range,null, action);
    }

    private void printEditForm(String member, String range, String ZRID, String action) throws Exception {
        if(ZRID == null || SZ_NULL.equals(ZRID)){
            startCreateForm(member, range, action);
            printUpdatePageButtons();

            beginT();
            for (int i = 5; i < namesMap.length; i++) {
                if (!namesMap[i].toLowerCase().contains("комментарий")) {
                    printTRow(new Object[]{namesMap[i], "<input type='text' name=" + i + ">"}); //!SIC лучше i -> REC_PREFIX + i -> getFieldName(i)
                } else {
                    printTRow(new Object[]{namesMap[i], "<textarea name=" + i + " " +
                            "rows='5' cols='40'> </textarea>"});
                }
            }
            endT();
            endForm();
        }else{
            Integer numberOfRow = Integer.parseInt(ZRID);
            ZCSVRow edittedRow = zcsvFile.editRowObjectByIndex(numberOfRow - 1);

            if (edittedRow != null) {
                if (edittedRow.getNames() != null) {
                    startUpdateForm(member, range, ZRID, action);
                    printUpdatePageButtons();
                    beginT();
                    for (int i = 5; i < edittedRow.getNames().length; i++) {
                        String showingParameter = (edittedRow.get(i) == null || SZ_NULL.equals(edittedRow.get(i))) ? "" : edittedRow.get(i);
                        if (!edittedRow.getNames()[i].toLowerCase().contains("комментарий")) {
                            printTRow(new Object[]{edittedRow.getNames()[i], "<input type=\"text\" name=" + i + " value=" + showingParameter + ">"});
                        } else {
                            printTRow(new Object[]{edittedRow.getNames()[i], "<textarea name=" + i + " " +
                                    "rows=\"5\" cols='40'>" + showingParameter + "</textarea>"});
                        }
                    }
                    beginT();
                    endForm();
                } else
                    throw new ZCSVException("Names won't be setted! Call the system administramtor!");
            } else {
                throw new Exception("Unknown exception");
            }
        }
    }


    private void printUpdatePageButtons() throws Exception {
        out.print("<input type=\"submit\" name=\"cancel\" value=\"Отмена\"/>&nbsp;");
        out.print("<input type=\"submit\" name=\"refresh\" value=\"Сбросить\"/>&nbsp;");
        out.print("<input type=\"submit\" name=\"save\" value=\"Сохранить\"/>&nbsp;");
    }

    private void startCreateForm(String member, String range, String action) throws Exception {
        action = "save"; // !SIC строка внизу + member -> + encode_url_value(member) -> + euv(member) и так везде надо
        out.println("<form action=\"" + getRequestParamsURL(CGI_NAME,CMD_UPDATE,member,range, null,action) + "\" method=\"POST\">");
    }

    private void startUpdateForm(String member, String range, String ZRID, String action) throws Exception {
        action = "save";
        out.println("<form action=\"" + getRequestParamsURL(CGI_NAME,CMD_UPDATE,member,range,ZRID,action) + "\" method=\"POST\">");
    }

    private void endForm() throws Exception { out.println("</form>"); }

    private ZCSVFile setupZCSVPaths(String rootPath, String fileName) {
        ZCSVFile file = new ZCSVFile();
        file.setRootPath(rootPath);
        file.setFileName(fileName);
        return file;
    }

    private void printUpsideMenu(String[] menuItems, String[] menuReferences) throws IOException, Exception {
        out.println("<ul>");
        for (int i = 0; i < menuItems.length; i++) {
            out.print("<li>");
            out.println("<a href=\'" + CGI_NAME + "?" + menuReferences[i] + "\'>" + menuItems[i] + "</a>");
            out.print("</li>");
        }
        out.println("</ul>");
        println();
    }

    private void printProductsTableUpsideString(String... outputString) throws Exception {
        beginTRow();
        for (int i = 4; i < outputString.length; i++) {
            if (i == 4) printCell("Опции");
            else printCell(outputString[i]);
        }
        endTRow();
    }

    private void beginTCell() throws Exception { out.println("<td>"); }

    private void endTCell() throws Exception { out.println("</td>"); }

    private void beginTRow() throws Exception { out.println("<tr>"); }

    private void endTRow() throws Exception { out.println("</tr>"); }

    private void beginT() throws Exception { out.print("<table>"); }

    private void endT() throws Exception { out.println("</table>"); }

    private void printCell(Object tElement) throws IOException, Exception {
        beginTCell();
        out.println(obj2str(tElement));
        endTCell();
    }

    private void printTRow(Object[] data) throws Exception {
        beginTRow();
        for (int i = 0; i < data.length; i++) {
            printCell(data[i]);
        }
        endTRow();
    }

    private String getRequestParamsURL(String ... params){
        if(params == null)
            return (null);
        StringBuffer buffer = new StringBuffer();
        int i = 0;
        if(CGI_NAME.equals(params[0])) {
            buffer.append(CGI_NAME + "?");
            i++;
        }
        for( int j = 0; i < params.length; i++, j++){
            if(i != params.length - 1)
                buffer.append(STD_REQUEST_PARAMETERS[j] +"=" + params[i] + "&");
            else
                buffer.append(STD_REQUEST_PARAMETERS[j] + "=" + params[i]);
        }
        return buffer.toString();
    }

    private boolean checkShellInjection(String parameter){ return parameter.contains(".."); }

    public static String getCurrentDate4ZDATE() throws Exception {
        return (new SimpleDateFormat("y-MM-dd HH:mm:ss").format(new Date()));
    }

    public static String getRequestUser4ZUID(HttpServletRequest request) throws Exception{
        return (request.getRemoteUser() + "@" + request.getRemoteAddr());
    }

    private String obj2str(Object obj) {
        if(obj == null)
            obj = "";
        return obj.toString();
    }

    public void println() throws Exception { out.println("<br/>"); }

    public void printerr(String msg) throws Exception { out.print("<b>" + msg + "</b>"); }

    public void printerrln(String msg) throws Exception { printerr(msg);  println(); }

    public void set_request_hints(HttpServletRequest request, HttpServletResponse response)
            throws IOException { //SIC! этому куску кода уже 15 лет, надо разобраться как сделать лучше, он еще для NN 4.x
        long enter_time = System.currentTimeMillis();
        long expire_time = enter_time + 24 * 60 * 60 * 1000;
        response.setHeader("Cache-Control", "No-cache");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", expire_time);
        request.setCharacterEncoding("UTF-8");
    }

    private void read_parameters_from_web_xml() { QRDB_PATH = getServletContext().getInitParameter("QRDB_PATH"); }

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
    <a href='<%= CGI_NAME %>?cmd=test'>Тест</a>&nbsp;
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
        read_parameters_from_web_xml();
        if (QRDB_PATH == null) {
            printerr("Путь к базе данных не задан!");
            throw new ZCSVException("Не задан параметр пути к базе данных.");
        }
        Members.setWayToDB(QRDB_PATH);

        String p_member = getRequestParameter(request,PARAM_MEMBER); // Check to SI
        String p_range = getRequestParameter(request,PARAM_RANGE); // Check to SI
        String p_ZRID = getRequestParameter(request,PARAM_ZRID);
        String p_action = getRequestParameter(request,PARAM_ACTION);

        switch (CMD) {
            case CMD_MEMBERS:
                setMembersPage();
                break;
            case CMD_RANGES:
                setRangesPage(p_member);
                break;
            case CMD_PRODTABLE:
                setProductsPage(p_member, p_range);
                break;
            case CMD_PRODVIEW:
                setProdViewPage(p_member, p_range, p_ZRID);
                break;
            case CMD_UPDATE:
                if (ACTION_EDIT.equals(p_action))
                    setUpdateProductPage(p_member, p_range, p_ZRID, p_action);
                if (ACTION_NEWRECORD.equals(p_action))
                    setNewRecordPage(p_member, p_range, p_action);
                if (ACTION_SAVE.equals(p_action)) {
                    Integer zrdsLength = zcsvFile.getRowObjects().size();
                    ZCSVRow newRow;
                    System.out.println("saved");
                    if(p_ZRID == null || SZ_NULL.equals(p_ZRID)) {
                        newRow = new ZCSVRow();
                        newRow.setNames(namesMap);
                        newRow.setStringSpecificIndex(0, zrdsLength.toString());
                        newRow.setStringSpecificIndex(1, "1");
                    }
                    else {
                        newRow = zcsvFile.getRowObjectByIndex(Integer.parseInt(p_ZRID)); //!SIC а здесь NumberFormatException словить только так
                        System.out.println("New row checked");
                    }

                    newRow.setStringSpecificIndex(2, getCurrentDate4ZDATE());
                    newRow.setStringSpecificIndex(3, getRequestUser4ZUID(request));
                    newRow.setStringSpecificIndex(4, "N");

                    for (Integer i = 5; i < namesMap.length; i++) {
                        newRow.setStringSpecificIndex(i, request.getParameter(i.toString()));
                    }
                    zcsvFile.getRowObjects().add(newRow);
                    zcsvFile.appendChangedStringsToFile();
                    out.print("Saved");
                }
                break;
            case "test":
                out.print("Hello test page!");
                break;
            default:
                response.sendRedirect("editqrpage.jsp");
                break;
        }
    } catch (IOException ex) {
        if (ex.getMessage() != null && !(SZ_NULL.equals(ex.getMessage())))
            out.println(ex.getMessage() + "Call the system administrator please.");
        else
            out.println("IO unexpected error occered! Call the system administrator please.");
    } catch (ZCSVException ex) {
        if (ex.getMessage() != null && !(SZ_NULL.equals(ex.getMessage())))
            out.println(ex.printError() + "Call the system administrator please.");
        else
            out.println("ZCSV unexpected error occered! Call the system administrator please.");
    } catch (Exception ex) {
        if (ex.getMessage() != null && !(SZ_NULL.equals(ex.getMessage())))
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
