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
    private static String CMD;
    JspWriter out;

    private String QRDB_PATH = null;
    private void read_parameters_from_web_xml() {
        QRDB_PATH = getServletContext().getInitParameter("QRDB_PATH");
    }

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

    public void set_request_hints(HttpServletRequest request, HttpServletResponse response)
            throws java.io.IOException {
        long enter_time = System.currentTimeMillis();
        long expire_time = enter_time + 24 * 60 * 60 * 1000;
        response.setHeader("Cache-Control", "No-cache");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", expire_time);
        try {
            request.setCharacterEncoding("UTF-8");
        } catch (IOException ex) {
            out.print("There was some error.\nCall the system administrator.");
        }

    }

    private void setMembersPage() throws IOException {
        Members members = new Members();
        String[] allRegisteredMembers = members.getCompanyNames();

        out.println("<table class=\"memberstable\" border=\"2\" width=\"60%\">");
        for (int i = 0; i < allRegisteredMembers.length; i++) {
            out.println("<tr>");
            out.println("<td>");
            out.print("<a href=\'"+CGI_NAME+"?page=ranges&member="+allRegisteredMembers[i]+"\'>");
            out.println(allRegisteredMembers[i]);
            out.println("</a>");
            out.println("</td>");
            out.println("</tr>");
        }
        out.println("</table>");
    }

    private void setRangePage(String member) throws IOException {
        RangesController rController = new RangesController(member);
        String s = rController.getInfo();
        out.println(s);

        String [] allItems = rController.getRanges();
        out.println("<table class=\"memberstable\" border=\"2\" width=\"60%\"><tr><td>Диапазон</td><td>Описание</td>");
        for(int i =0; i <  allItems.length; i++) {
            String range = allItems[i];
            out.println("<tr>");
            out.println("<td><a href=\'"+CGI_NAME+"?page=prodtable&member="+member+"&range="+range+"\'>"+range+"</a></td>");
            out.println("<td>" + getNailedRangDesc(range, "Диапазон: " + range) + "</td>");
            out.println("</tr>");
        }
        out.println("</table>");
    }

    private void setProductsPage(String member, String range) throws IOException {
        ZCSVFile zcsvFile = new ZCSVFile();
        zcsvFile.setRootPath(Members.getWayToDB()+member+"/"+range+"/");
        zcsvFile.setFileName("master.list");
        String [] namesMap = new String[]
                {"ZOID","ZVER","ZDATE","ZUID","ZSTA","QR","CONTRACTNUM", "contractdate",
                        "MONEY","SUPPLIER","CLIENT","PRODTYPE","MODEL","SN","prodate","shipdate",
                        "SALEDATE","DEPARTUREDATE","WARRANTYSTART","WARRANTYEND","COMMENT "};
        if(Files.exists(Paths.get(zcsvFile.toString()))) {
            boolean res = zcsvFile.tryOpenFile(1);
            if (res) {
                zcsvFile.loadFromFile();

                out.println("<table>");

                for (int i = 0; i < zcsvFile.getFileRowsLength(); i++) {

                    out.println("<tr>");
                    ZCSVRow eachRow = zcsvFile.getRowObjectByIndex(i);
                    eachRow.setNames(namesMap);
                    out.println("<td>" +
                            "<a href=\'"+CGI_NAME+"?page=prodview&member="+member+"&range="+range+"&zoid="+eachRow.get(0)+"\'>" +
                                "Change card" +
                            "</a></td>");
                    for(int j = 0; j < eachRow.getNames().length; j++){
                        out.println("<td>");
                        out.print(eachRow.get(j));
                        out.println("</td>");
                    }
                    out.println("</tr>");
                }

                out.println("</table>");

            } else {
                out.println("can't open file");
            }
        }else{
            out.println("Doesn't exists");
        }
    }

    private void setProdViewPage(String member, String range, String ZOID){



    }

    public void printerr(String msg) throws java.io.IOException {
        out.print("<b>" + msg + "</b>");
    }

    public void printerrln(String msg) throws java.io.IOException {
        printerr(msg);
        out.print("<br>");
    }
%>
<html>
<head>
    <title><%= CGI_TITLE %>
    </title>
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
    if(CMD == null){
        CMD = "members";
    }

    long enter_time = System.currentTimeMillis();
    read_parameters_from_web_xml();
    Members.setWayToDB(QRDB_PATH);
    if (QRDB_PATH == null) {
        printerr("QRDB_PATH параметр не задан! отредактируйте WEB-INF/web.xml");
    }

    String [] parameters = {"member", "range", "zoid", "action"};

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
            setProdViewPage(request.getParameter(parameters[0]), request.getParameter(parameters[1]),request.getParameter(parameters[2]));
            break;
        case "updateprod":
            break;
        case "test":
            out.print("Hello test page!");
            break;
        default:
            request.getRequestDispatcher("editqrpage.jsp?page=members").forward(request,response);
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
