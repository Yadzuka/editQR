<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@
        page import="java.util.*"
             import="java.io.*"
             import="org.eustrosoft.contractpkg.Controller.*"
             import="org.eustrosoft.contractpkg.Model.*"
             import="org.eustrosoft.contractpkg.zcsv.*"
%>
<%@ page import="java.nio.file.Paths" %>
<%@ page import="java.nio.file.Files" %>
<%!
    private static final String CGI_NAME = "editqrpage.jsp";
    private final static String CGI_TITLE = "EDIT-QR.qxyz.ru - средство редактирования БД диапазонов QR-кодов для проданных изделий";
    private final static String JSP_VERSION = "$id$";
    public final String ACTION_EDIT = "edit";
    public final String ACTION_CREATE = "create";
    public final String ACTION_SAVE = "save";
    public final String ACTION_REFRESH = "refresh";
    public final String ACTION_CANCEL = "cancel";
    public final String ACTION_GENERATEQR = "genqr";
    public final String[] ACTIONS = {ACTION_EDIT, ACTION_CREATE, ACTION_SAVE, ACTION_REFRESH, ACTION_CANCEL, ACTION_GENERATEQR};

    private static boolean tryHach = false;

    private static ZCSVFile zcsvFile;
    private static String CMD;
    JspWriter out;

    private String QRDB_PATH = null;

    private void read_parameters_from_web_xml() {
        QRDB_PATH = getServletContext().getInitParameter("QRDB_PATH");
    }

    private String[] NAILED_RANGE_DESC = {
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

    public void set_request_hints(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        long enter_time = System.currentTimeMillis();
        long expire_time = enter_time + 24 * 60 * 60 * 1000;
        response.setHeader("Cache-Control", "No-cache");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", expire_time);
        try {
            request.setCharacterEncoding("UTF-8");
        } catch (IOException ex) {
            out.print("There was encoding set error!\nCall the system administrator.");
        }
    }

    private void setMembersPage() throws Exception {
        try {
            if (tryHach)
                out.print("<b>Bad game :)</b><br/> Don't try to hack us :)");

            Members members = new Members();
            String[] allRegisteredMembers = members.getCompanyNames();

            out.println("<table class=\"memberstable\" border=\"3\">");
            for (int i = 0; i < allRegisteredMembers.length; i++) {
                out.println("<tr>");
                printTableElement("<a href=\'" + CGI_NAME + "?page=ranges&member=" + allRegisteredMembers[i] + "\'>" + allRegisteredMembers[i] + "</a>");
                out.println("</tr>");
            }
            out.println("</table>");
        } catch (Exception ex) {
            printerr("There was some unknown error in Member's page! Call the system administrator!");
        }
    }

    private void setRangePage(String member) throws Exception {
        try {
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
                printTableElement("<a href=\'" + CGI_NAME + "?page=prodtable&member=" + member + "&range=" + range + "\'>" + range + "</a>");
                printTableElement(getNailedRangDesc(range, "Диапазон: " + range));
                out.println("</tr>");
            }
            out.println("</table>");
        } catch (IOException ex) {
            printerr("Error with ranges defining! Call the system administrator!");
        }
    }

    private void setProductsPage(String member, String range) throws Exception {
        try {
            printUpsideMenu(
                    new String[]{
                            "Назад", "Создать новую запись",
                    }, new String[]{
                            "page=ranges&member=" + member,
                            "page=updateprod&member=" + member + "&range=" + range + "&action=create"
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
                        printTableElement(
                                "<a href=\'" + CGI_NAME + "?page=prodview&member=" + member + "&range=" + range + "&zrid=" + eachRow.get(0) + "\'>" +
                                        "<карточка>" + "</a>");
                        for (int j = 5; j < eachRow.getNames().length; j++) {
                            printTableElement((eachRow.get(j) == null || "null".equals(eachRow.get(j)) ? "" : eachRow.get(j)));
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
        } catch (ZCSVException ex) {
            printerr("There was ZCSV exception error! Call the system administrator!");
        } catch (IOException ex) {
            ex.printStackTrace(new PrintWriter(out));
            printerr("Error with file reading! Call the system administrator!");
        }
    }

    private void setProdViewPage(String member, String range, String ZRID) throws Exception {
        try {
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
                printTableElement((row.getNames()[i] == null) ? "" : row.getNames()[i]);
                printTableElement((row.get(i) == null | "null".equals(row.get(i))) ? "" : row.get(i));
                out.println("</tr>");
            }
            out.println("</table>");
        } catch (IOException ex) {
            printerr("IOexception! Call the system administrator!");
        } catch (Exception ex) {
            ex.printStackTrace(new PrintWriter(out));
            printerr("There was some unknown error in ProdView's page! Call the system administrator!");
        }
    }

    private void setUpdateProductPage(String member, String range, String ZRID, String action) throws Exception {
        boolean newRecord = ZRID == null | "".equals(ZRID) | "null".equals(ZRID);

        if (newRecord) {
            try {
                printUpsideMenu(
                        new String[]{
                                "Назад", "Change name map(Experimental)"
                        }, new String[]{
                                "page=prodtable&member=" + member + "&range=" + range,
                                "page=updateprod&member=" + member + "&range=" + range + "action=changenm",
                        });
                out.print("<input type=\"submit\" value=\"Button\"/> ");

                printUpdateTable(member, range, ZRID, action, null);
            } catch (Exception ex) {
                printerr("Exception! Call the system administrator!");
            }
        } else {
            try {
                printUpsideMenu(
                        new String[]{
                                "Назад", "change name map(Experimental)"
                        }, new String[]{
                                "page=prodtable&member=" + member + "&range=" + range + "&ZRID=" + ZRID,
                                "page=updateprod&member=" + member + "&range=" + range + "&ZRID=" + ZRID + "action=changenm",
                        });
                ZCSVRow row = zcsvFile.getRowObjectByIndex(Integer.parseInt(ZRID) - 1);

                printUpdateTable(member,range, ZRID, action, row);
            } catch (IOException ex) {
                printerr("IOexception! Call the system administrator!");
            } catch (Exception ex) {
                ex.printStackTrace(new PrintWriter(out));
                printerr("There was some unknown error in ProdView's page! Call the system administrator!");
            }
        }
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

    private void printTable(ZCSVRow row) throws Exception {
        try {
            out.println("<table>");
            for (int i = 0; i < row.getNames().length; i++) {
                out.println("<tr>");
                printTableElement(row.get(i));
                out.println("</tr>");
            }
            out.println("</table>");
        } catch (Exception ex) {
            out.println("<b>Ошибка при создании таблицы. Свяжитесь с системным администратором.</b>");
        }
    }

    private void printProductsTableUpsideString(String... outputString) throws Exception {
        try {
            out.println("<tr>");
            for (int i = 4; i < outputString.length; i++) {
                if (i == 4) printTableElement("Опции");
                else printTableElement(outputString[i]);
            }
            out.println("</tr>");
        } catch (IOException ex) {
            printerr("Error was occured by printing products table upside string!\nCall the system administrator!");
        }
    }

    private void printUpdateTable(String member, String range, String ZRID, String action, ZCSVRow row) throws Exception {
        if (row != null) {
            if (row.getNames() != null) {

                startHTMLForm(member, range, ZRID, action);
                printUpdatePageButtons();
                out.println("<table>");
                for (int i = 5; i < row.getNames().length; i++) {
                    if(!row.getNames()[i].toLowerCase().contains("комментарий")){
                        printTableString(new Object[]{row.getNames()[i], row.get(i), "<input type=\"field\" name="+i+"/>"});
                    }else {
                        printTableString(new Object[]{row.getNames()[i], row.get(i), "<textarea name=\"commentary\" " +
                                "rows=\"5\" cols=\"40\" placeholder=\"Ваш комментарий клиенту.\"></textarea>"});
                    }
                }
                out.println("</table>");
                endHTMLForm();
            } else
                throw new ZCSVException("Names won't be setted! Call the system administramtor!");
        } else {

        }
    }

    private void printTable(ArrayList data) throws Exception {
        out.println("<table>");
        for (int i = 0; i < data.size(); i++) {
            printTableString((Object[]) data.toArray()[i]);
        }
        out.println("</table>");
    }

    private void printUpdatePageButtons() throws Exception {
        out.print("<input type=\"submit\" name=\"cancel\" value=\"Отмена\"/>&nbsp;");
        out.print("<input type=\"submit\" name=\"refresh\" value=\"Сбросить\"/>&nbsp;");
        out.print("<input type=\"submit\" name=\"save\" value=\"Сохранить\"/>&nbsp;");
    }

    private void startHTMLForm(String member, String range, String ZRID, String action) throws Exception {
        out.println("<form action="+ CGI_NAME + "?page=updateprod&member="+member+"&range="+range+"&ZRID=" + ZRID + "&action=" + action + " method=\"POST\">");
    }

    private void endHTMLForm() throws Exception {
        out.println("</form>");
    }

    private void printTableString(Object[] data) throws Exception {
        out.println("<tr>");
        for (int i = 0; i < data.length; i++) {
            printTableElement(data[i]);
        }
        out.println("</tr>");
    }

    private void printTableElement(Object tElement) throws IOException {
        out.println("<td>");
        out.println(obj2str(tElement));
        out.println("</td>");
    }

    private String obj2str(Object obj) {
        return obj.toString();
    }

    public void printerr(String msg) throws Exception {
        out.print("<b>" + msg + "</b>");
    }

    public void printerrln(String msg) throws Exception {
        printerr(msg);
        out.print("<br>");
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
    this.out = out;
    CMD = request.getParameter("page");
    if (CMD == null) {
        CMD = "members";
    }

    long enter_time = System.currentTimeMillis();
    read_parameters_from_web_xml();
    Members.setWayToDB(QRDB_PATH);
    if (QRDB_PATH == null) {
        printerr("QRDB_PATH параметр не задан! отредактируйте WEB-INF/web.xml");
    }

    String[] parameters = {"member", "range", "zrid", "action"};
    for (int i = 0; i < parameters.length; i++) {
        String x = request.getParameter(parameters[i]);
        if (x != null) {
            if (x.contains("/") || x.contains("..")) {
                tryHach = true;
                response.sendRedirect("editqrpage.jsp");
            } else {
                tryHach = false;
            }
        }
    }

    switch (CMD) {
        case "members":
            setMembersPage();
            break;
        case "ranges":
            setRangePage(request.getParameter(parameters[0]));
            break;
        case "prodtable":
            setProductsPage(request.getParameter(parameters[0]), request.getParameter(parameters[1]));
            break;
        case "prodview":
            setProdViewPage(request.getParameter(parameters[0]), request.getParameter(parameters[1]), request.getParameter(parameters[2]));
            break;
        case "updateprod":
            setUpdateProductPage(request.getParameter(parameters[0]), request.getParameter(parameters[1]), request.getParameter(parameters[2]), request.getParameter(parameters[3]));
            break;
        case "test":
            out.print("Hello test page!");
            break;
        default:
            request.getRequestDispatcher("editqrpage.jsp?page=members").forward(request, response);
            break;
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
