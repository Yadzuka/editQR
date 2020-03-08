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
         import="java.math.BigDecimal"
%>
<%!
    /// Vocabulary:
    /// T - table

    private final String OPTIONAL_PRODUCTS_TABLE_PARAM = "Опции";
    private final String ADDITION_TO_REFERENCE = "http://qr.qxyz.ru/?q=";

    private final static String DELETED_RECORD_STATUS = "D";
    private final static String NEW_RECORD_STATUS = "N";
    private final static String OLD_RECORD_STATUS = "O";
    private final static String QR_CODE_RECORD_STATUS = "QR код";

    // Page info
    private final static String CGI_NAME = "editqrpage.jsp"; // Page domain name
    private final static String CGI_TITLE = "EDIT-QR.qxyz.ru - средство редактирования БД диапазонов QR-кодов для проданных изделий"; // Upper page info
    private final static String JSP_VERSION = "$id$"; // Id for jsp version
    // Other constants
    private final String DB_FILENAME = "master.list.csv"; // Database name
    private final String DB_CONFIG_FILENAME = "csv.tab"; // Config name
    private final String SZ_NULL = "null"; // Just null parameter
    private final String REC_PREFIX = "param_pref_"; // Prefix for updateform parameters
    private final String SZ_EMPTY = ""; // Empty string
    // Attributes of CSV config file
    private final String SHOW_ATTRIBUTE = "SHOW";
    private final String QR_ATTRIBUTE = "QR";
    // All possible actions on update page
    public final String ACTION_EDIT = "edit"; // Simple state for updating product/contract page
    public final String ACTION_CREATE = "create"; // Action for creating new state of product/contract
    public final String ACTION_NEWRECORD = "new"; // State for new product/contract page
    public final String ACTION_SAVE = "save"; // Saving updates
    public final String ACTION_REFRESH = "refresh"; // Refresh data in table into starting position
    public final String ACTION_CANCEL = "cancel"; // Cancel all updates and go back
    public final String ACTION_GENERATEQR = "genqr"; // Generate new QR code action
    public final String ACTION_DELETE = "delete";
    public final String ACTION_SEEHISTORY = "seehistory"; // See full history of the record
    public final String ACTION_CHANGENAMEMAP = "changenamemap"; // EXPERIMENTAL! Page with creating new name's map
    // All possible page parameters
    public final static String PARAM_CMD = "cmd"; // Page parameter
    public final static String PARAM_MEMBER = "member"; // Specific member
    public final static String PARAM_RANGE = "range"; // Specific range
    public final static String PARAM_ZRID = "ZRID"; // Specific product/contract
    public final static String PARAM_ACTION = "action"; // Specific action
    public final static String[] STD_REQUEST_PARAMETERS = {PARAM_CMD, PARAM_MEMBER, PARAM_RANGE, PARAM_ZRID, PARAM_ACTION};
    // All possible pages
    public final static String CMD_MEMBERS = "members"; // Member's page
    public final static String CMD_RANGES = "ranges"; // Range's page
    public final static String CMD_CHANGE_CONFIG = "chconfig"; // Change config page
    public final static String CMD_PRODTABLE = "prodtable"; // Product's table
    public final static String CMD_PRODVIEW = "prodview"; // Product's info
    public final static String CMD_UPDATE = "updateprod"; // Update or create product's page
    public final static String CMD_TEST = "test"; // Testing page
    private final static String[] CMD_PARAMETERS = {CMD_MEMBERS, CMD_RANGES, CMD_CHANGE_CONFIG, CMD_PRODTABLE, CMD_PRODVIEW, CMD_UPDATE, CMD_TEST};

    // Money counters
    private BigDecimal allMoney = BigDecimal.ZERO;
    private BigDecimal allMoneySent = BigDecimal.ZERO;
    private BigDecimal allMoneyWait = BigDecimal.ZERO;

    private ZCSVFile zcsvFile;
    private String QRDB_PATH = null;
    private JspWriter out;
    private String[] namesMap;
    private String[] showedNames;
    private ArrayList<String> nameMap = new ArrayList();
    private ArrayList<String> showNames = new ArrayList();
    private ArrayList<String> referencesIndex = new ArrayList();
private static String FieldNames[] ={
"ZOID",
"ZVER",
"ZDATE",
"ZUID",
"ZSTA",
"QR",
"CONTRACTNUM",
"contractdate",
"MONEY",
"SUPPLIER",
"CLIENT",
"PRODTYPE",
"MODEL",
"SN",
"prodate",
"shipdate",
"SALEDATE",
"DEPARTUREDATE",
"WARRANTYSTART",
"WARRANTYEND",
"COMMENT"
};
private static String FieldOptions[] ={
"NN", // "ZOID",
"NUL", // "ZVER",
"NUL", // "ZDATE",
"NUL", // "ZUID",
"NUL", // "ZSTA",
"NUL", // "QR",
"NUL", // "CONTRACTNUM",
"NUL", // "contractdate",
"NUL", // "MONEY",
"NUL", // "SUPPLIER",
"NUL", // "CLIENT",
"NUL", // "PRODTYPE",
"NUL", // "MODEL",
"NUL", // "SN",
"NUL", // "prodate",
"NUL", // "shipdate",
"NUL", // "SALEDATE",
"NUL", // "DEPARTUREDATE",
"NUL", // "WARRANTYSTART",
"NUL", // "WARRANTYEND",
"NUL" // "COMMENT"
};
private static String FieldCaptions[] ={
"ZOID",
"ZVER",
"ZDATE",
"ZUID",
"ZSTA",
"QR код",
"№ договора",
"дата договора",
"Деньги по договору",
"Юр-лицо поставщик",
"Юр-лицо клиент",
"Тип продукта",
"Модель продукта",
"SN",
"Дата производства",
"Дата ввоза (ГТД)",
"Дата продажи",
"Дата отправки клиенту",
"Дата начала гарантии",
"Дата окончания гарантии",
"Комментарий (для клиента)"
};
private static String FieldComments[] ={
"ZOID - идентификатор объекта (записи) в файле, записи с одинаковым ZOID - разные версии одной записи",
"ZVER - номер версии записи ",
"ZDATE - дата порождения данной версии",
"ZUID - пользователь, записавший версию",
"ZSTA - статус 'N' - актуальная, 'C' - устаревшая, 'D' - удаленная",
"QR код должен содержать ровно 8 символов, алфавит [0-9,A-F], первые 5 - это диапазон, оставшиеся 3 - номер внутри диапазона в 16-ричном",
"для новых номеров можно использовать последние 4 символа QR-кода. допустимо несколько карточек с одним номером договора",
"дата заключения договора",
"Деньги, причитающиеся поставщику, по договору за это изделие. Если изделий по договору несколько - заполняйте отдельные карточки",
"кто исполнитель по договору, если у нас более одного юр-лица или ИП",
"Юр-лицо клиента, пока только название, но можете добавить ИНН, через запятую, или еще что-то. Последним укажите город. Напр: EustroSoft,...,Москва",
"Тип продукта.",
"Модель продукта",
"Серийный номер изделия. Возможно - серийные номера агрегатов через запятую. Потом разберемся",
"Дата производства изделия",
"Сейчас - номер ГТД. Изначально хотели указывать дату ввоза в Россию, или дату поступления на склад.",
"Дата продажи - видимо дата поступления денег или гарантийного письма об оплате ",
"Дата отправки клиенту/отгрузки со склада. Обычно - это-же дата начала гарантии",
"Дата начала гарантии для конечного пользователя. т.е. при продажи дилером - задается им",
"Дата окончания гарантии. Обычно + 1 год, но нет правил без исключений",
"Этот комментарий виден клиенту! конфиденциальное пишите в поле Деньги"
};

    private String DEFAULT_CSV_TAB =
"#Атрибут\tЗначение        Значение2/код\n" +
"NAME\tTISC.DRow\tDW\n" +
"OBJECT\tDocument        D\n" +
"HEADER\tSTD_HEADER\n" +
"PARENT\tTISC.DDocument  DD\n" +
"CHILD\tTISC.DRProperty DP\n" +
"#Код\tПоле    Тип     Атрибуты        Название        Описание\n" +
"01\tZRID\ttext\tNN,UNIQ=OBJECT\tZRID\n" +
"02\tZVER\ttext\tNUL\tZVER\n" +
"03\tZDATE\ttext\tNUL\tZDATE\n" +
"04\tZUID\ttext\tNUL\tZUID\n" +
"05\tZSTA\ttext\tNUL\tZSTA\n" +
"06\tQR\ttext\tSHOW,NUL,QR\tQR код\n" +
"07\tcnum\ttext\tSHOW,NUL\t№ договора\n" +
"08\tcdate\ttext\tNUL\tДата договора\n" +
"09\tcmoney\ttext\tSHOW,NUL,QRMONEY\tДеньги по договору\n" +
"10\tsupplyer\ttext\tSHOW,NUL\tЮр-лицо поставщик\n" +
"11\tclient\ttext\tSHOW,NUL\tЮр-лицо клиент\n" +
"12\tprodtype\ttext\tNUL\tТип продукта\n" +
"13\tprodmodel\ttext\tSHOW,NUL\tМодель продукта\n" +
"14\tsn\ttext\tSHOW,NUL\tSN\n" +
"15\tprodate\ttext\tNUL\tДата производства\n" +
"16\tGTD\ttext\tNUL\tДата ввоза (ГТД)\n" +
"17\tsaledate\ttext\tNUL\tДата продажи\n" +
"18\tsendate\ttext\tNUL\tДата отправки клиенту\n" +
"19\twarstart\ttext\tNUL\tДата начала гарантии\n" +
"20\twarend\ttext\tNUL\tДата окончания гарантии\n" +
"21\tcomment\ttext\tNUL\tКомментарий (для клиента)\n";
/*
*/
    private String szDefaultCSVConf=null;
    public String getDefaultCSVConf()
    {
    if(szDefaultCSVConf != null) return(szDefaultCSVConf);
    szDefaultCSVConf = DEFAULT_CSV_TAB;
    return(szDefaultCSVConf);
    }

    private String getRequestParameter(ServletRequest request, String param) {
        return (getRequestParameter(request, param, null));
    }

    private String getRequestParameter(ServletRequest request, String param, String default_value) {
        String value = request.getParameter(param);
        if (value == null) value = default_value;
        if (value == null) return (null);
        switch (param) {
            case PARAM_MEMBER:
            case PARAM_RANGE:
                if (checkShellInjection(value)) {
                    throw new RuntimeException("Shell injection detected");
                } // SIC!
                break;
            case PARAM_ACTION:
                if (request.getParameter(ACTION_SAVE) != null) value = ACTION_SAVE;
                if (request.getParameter(ACTION_REFRESH) != null) value = ACTION_REFRESH;
                if (request.getParameter(ACTION_CANCEL) != null) value = ACTION_CANCEL;
                if (request.getParameter(ACTION_DELETE) != null) value = ACTION_DELETE;
                if (request.getParameter(ACTION_NEWRECORD) != null) value = ACTION_NEWRECORD;
                if (request.getParameter(ACTION_GENERATEQR) != null) value = ACTION_GENERATEQR;
                if(request.getParameter(ACTION_SEEHISTORY) != null) value = ACTION_SEEHISTORY;
                break;
        }
        return (value);
    }
    /// PAGES
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
                        "Назад", "Создать конфигурационный файл",
                }, new String[]{
                        getRequestParamsURL(CMD_MEMBERS), getRequestParamsURL(CMD_CHANGE_CONFIG, member)
                });

        RangesController rController = new RangesController(member);
        String s = rController.getInfo();
        out.println(s);

        String[] allItems = rController.getRanges();
        beginT();
        printTRow(new String[]{"Диапазан", "Описание"});
        for (int i = 0; i < allItems.length; i++) {
            String range = allItems[i];
            beginTRow();
            printCell("<a href=\'" + getRequestParamsURL(CGI_NAME, CMD_PRODTABLE, member, range) + "\'>" + range + "</a>");
            printCell(getNailedRangDesc(range, "Диапазон: " + range));
            endTRow();
        }
        endT();
    }

    // Under working
    private void setChangeConfigPage(String member, String range) throws Exception {
        String goBackUrl;
        if (range == null)
            goBackUrl = getRequestParamsURL(CMD_RANGES, member);
        else
            goBackUrl = getRequestParamsURL(CMD_PRODTABLE, member, range);

        printUpsideMenu(
                new String[]{
                        "Назад"
                }, new String[]{
                        goBackUrl,
                });

        if (range == null) {
            ZCSVFile configureFile = new ZCSVFile();
            configureFile.setFileName("csv.tab");
            if (configureFile.loadConfigureFile()) {

            }
        } else {
            ZCSVFile configureFile = new ZCSVFile();
            configureFile.setFileName("csv.tab");
            configureFile.setRootPath(Members.getWayToDB() + member + "/" + range + "/");
            if (configureFile.loadConfigureFile()) {
                ZCSVRow configureString = new ZCSVRow();


                for (int i = 0; i < configureFile.getFileRowsLength(); i++) {
                    configureString = configureFile.getRowObjectByIndex(i);
                    if (configureString.get(0).length() < 3) {
                    }
                }
            }
        }
    } // End config page

    private void setProductsPage(String member, String range) throws Exception {
        printUpsideMenu(
                new String[]{
                        "Назад",
                        "Создать новую запись",
                        "Изменить конфигурацию полей",
                }, new String[]{
                        getRequestParamsURL(CMD_RANGES, member),
                        getRequestParamsURL(CMD_UPDATE, member, range, SZ_NULL, ACTION_NEWRECORD),
                        getRequestParamsURL(CMD_CHANGE_CONFIG, member, range),
                });

        String rootPath = Members.getWayToDB() + member + "/" + range + "/";
        zcsvFile = setupZCSVPaths(rootPath, DB_FILENAME);

        if (Files.exists(Paths.get(zcsvFile.toString()))) { //SIC! if(!..) then err is better
            if (zcsvFile.tryOpenFile(1)) {
                zcsvFile.loadFromFileValidVersions();
                out.println("<table class='memberstable' border='1'>"); //SIC! println Evil, '1' is better \"1\"
                printTableUpsideString(OPTIONAL_PRODUCTS_TABLE_PARAM, showedNames);
                for (int i = 0; i < zcsvFile.getFileRowsLength(); i++) {
                    ZCSVRow eachRow = zcsvFile.getRowObjectByIndex(i);
                    eachRow.setNames(namesMap);
                    if(eachRow.get(4).equals(DELETED_RECORD_STATUS))
                        continue;
                    beginTRow();
                    printCellCardTools(member,range,new Long(i+1));
                    for (int j = 0; j < showedNames.length; j++) {
                        String wroteString = MsgContract.csv2text(eachRow.get(showedNames[j]));
                        if(referencesIndex.contains(showedNames[j])){
                            beginTCell();setReference(getReference(wroteString), wroteString);endTCell();
                        } else {
                            printCell(wroteString);
                        }
                    }
                    endTRow();
                    BigDecimal dec_money = BigDecimal.ZERO;
                    try {
                        dec_money = MsgContract.str2dec(eachRow.get("Деньги по договору"));
                        allMoney = allMoney.add(dec_money);

                        if (isDate(eachRow.get("Дата отправки клиенту"))) { allMoneySent = allMoneySent.add(dec_money); }
                        else { allMoneyWait = allMoneyWait.add(dec_money); }
                    } catch (Exception ex) {/*out.println("Ошибка подсчета денег!");*/} // SIC!
                }
                beginTRow();printCell("", showedNames.length - 1);printCell("Отгружено:");printCell(allMoneySent);endTRow();
                beginTRow();printCell("", showedNames.length - 1);printCell("Ждём:");printCell(allMoneyWait);endTRow();
                beginTRow();printCell("", showedNames.length - 1);printCell("Всего:");printCell(allMoney);endTRow();
                endT();
            } else { printerr("Can't open file! Call the system administrator!"); }
        } else { printerr("File doesn't exists! Call the system administrator!"); }
    }

    private void setProdViewPage(String member, String range, String ZRID) throws Exception {
        printUpsideMenu(
                new String[]{
                        "Назад",
                        "Изменить запись",
                        "Посмотреть историю изменений",
                        "Удалить запись"
                }, new String[]{
                        getRequestParamsURL(CMD_PRODTABLE, member, range),
                        getRequestParamsURL(CMD_UPDATE, member, range, ZRID, ACTION_EDIT),
                        getRequestParamsURL(CMD_UPDATE, member,range, ZRID, ACTION_SEEHISTORY),
                        getRequestParamsURL(CMD_UPDATE, member,range,ZRID, ACTION_DELETE)
                });

        ZCSVRow row = zcsvFile.getRowObjectByIndex(Integer.parseInt(ZRID) - 1);

        beginT();beginTRow();printCell("QR картинка:");beginTCell();
        setReference(
                getReference(row.get(QR_CODE_RECORD_STATUS)) ,
                "<img src=\"qr?p_codingString=" + row.get(QR_CODE_RECORD_STATUS) + "&p_imgFormat=GIF&p_imgSize=140&p_imgColor=0x000000\"/>"
        );
        endTCell();beginTRow();
        for (int i = 5; i < row.getNames().length; i++) {
            beginTRow();
            printCell((row.getNames()[i] == null) ? "Не определенное имя" : row.getNames()[i]);
            if(referencesIndex.contains(row.getNames()[i])) {
                beginTCell();
                setReference((row.get(i) == null | SZ_NULL.equals(row.get(i))) ?
                "" : getReference(MsgContract.csv2text(row.get(i))), MsgContract.csv2text(row.get(i)));
                endTCell();
            } else { printCell((row.get(i) == null | SZ_NULL.equals(row.get(i))) ? "" : MsgContract.csv2text(row.get(i))); }
            endTRow();
        }
        endT();
    }

    private void setUpdateProductPage(String member, String range, String ZRID, String action) throws Exception {
        printUpsideMenu(
                new String[]{
                        "Назад",
                        "change name map(Experimental)",
                }, new String[]{
                        getRequestParamsURL(CMD_PRODVIEW, member, range, ZRID),
                        getRequestParamsURL(CMD_UPDATE, member, range, ZRID, ACTION_CHANGENAMEMAP),
                });
        println();
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
        printEditForm(member, range, null, action);
    }

    private void printEditForm(String member, String range, String ZRID, String action) throws Exception {
        String parameterBuffer;
        String newqr = genNewQr(range);
        if (ZRID == null || SZ_NULL.equals(ZRID)) {
            try {
                startCreateForm(member, range, action);
                printUpdatePageButtons();
                if (namesMap == null)
                    out.println("null");
                beginT();
                for (int i = 5; i < namesMap.length; i++) {
                    parameterBuffer = getParameterName(i);
                    if(namesMap[i].equals(QR_CODE_RECORD_STATUS)) {
                        printTRow(new Object[]{
                                namesMap[i],
                                "<input type='text' id='qrcode' name=" + parameterBuffer + ">",
                                String.format("<input type=\"button\" onclick=\"newQR('%s')\" value=\"Новый qr код\"/>",newqr),
                                FieldComments[i],
                        });
                    }else if (namesMap[i].toLowerCase().contains("комментарий")) {
                        printTRow(new Object[]{
                                namesMap[i],
                                "<textarea name=" + parameterBuffer + " " + "rows='5' cols='40'> </textarea>",
                                FieldComments[i],
                        });
                    } else {
                        printTRow(new Object[]{
                                namesMap[i],
                                "<input type='text' name=" + parameterBuffer + ">",
                                FieldComments[i],
                        });
                    }
                }
                endT();
                endForm();
            } catch (Exception ex) {
                out.println("An error");
            }
        } else {
            Integer numberOfRow = Integer.parseInt(ZRID) - 1;
            ZCSVRow edittedRow = zcsvFile.getRowObjectByIndex(numberOfRow);

            if (edittedRow != null) {
                if (edittedRow.getNames() != null) {
                    startUpdateForm(member, range, ZRID, action);
                    printUpdatePageButtons();
                    beginT();
                    for (int i = 5; i < edittedRow.getNames().length; i++) {
                        parameterBuffer = getParameterName(i);
                        String showingParameter = edittedRow.get(i);
                        if(namesMap[i].equals(QR_CODE_RECORD_STATUS)) {
                            printTRow(new Object[]{
                                    namesMap[i],
                                    "<input type='text' id='qrcode' name=" + parameterBuffer + " value="+MsgContract.csv2text(showingParameter)+">",
                                    String.format("<input type=\"button\" onclick=\"newQR('%s')\" value=\"Новый qr код\"/>",newqr),
                                    FieldComments[i],
                            });
                        } else if(edittedRow.getNames()[i].toLowerCase().contains("комментарий")) {
                            printTRow(new Object[]{
                                    edittedRow.getNames()[i],
                                    "<textarea name=" + parameterBuffer + " " + "rows=\"5\" cols='40'>" + MsgContract.csv2text(showingParameter) + "</textarea>",
                                    FieldComments[i],
                            });
                        } else{
                            printTRow(new Object[]{
                                    edittedRow.getNames()[i],
                                    "<input type=\"text\" " + "name=" + parameterBuffer + " value=" + MsgContract.csv2text(showingParameter) + ">",
                                    FieldComments[i],
                            });
                        }
                    }
                    endT();
                    endForm();
                } else
                    throw new ZCSVException("Names didn't set! Call the system administramtor!");
            } else
                throw new Exception("Unknown exception");
        }
    }

    public void setHistoryPage(String member, String range, String ZRID, String action) throws Exception {
        printUpsideMenu(
                new String[]{
                        "Назад",
                }, new String[]{
                        getRequestParamsURL(CMD_PRODVIEW, member, range, ZRID),
                });
        if(!action.equals(ACTION_SEEHISTORY))
            return;

        ZCSVRow row = zcsvFile.getRowObjectByIndex(Integer.parseInt(ZRID) - 1);
        beginT();
        printTableUpsideString("", namesMap);

        while(row != null){
            beginTRow();
            if(row.getNames() == null)
                row.setNames(namesMap);
            for(int i =0;i < row.getNames().length;i++)
                printCell(MsgContract.csv2text(row.get(i)));
            endTRow();
            row = row.getPrevious();
        }
        endT();
    }

    /// END PAGES PART
    private void createDefaultConfig() {
    }

    private void loadDataFromConfigFile(String member, String range)
     throws IOException, ZCSVException, Exception
    {
        String rootPath = Members.getWayToDB() + member + "/" + range + "/";
        ZCSVFile configFile = setupZCSVPaths(rootPath, DB_CONFIG_FILENAME);
        nameMap = new ArrayList<>();
        showNames = new ArrayList<>();
        try {configFile.loadConfigureFile();}
        catch(Exception e) {configFile.loadConfigFromString(getDefaultCSVConf());}
            for (int i = 0; i < configFile.getFileRowsLength(); i++) {
                ZCSVRow configRow = configFile.getRowObjectByIndex(i);
                if (configRow.get(0).length() < 3) {
                    nameMap.add(configRow.get(4));

                    if (configRow.get(3).contains(SHOW_ATTRIBUTE)) { showNames.add(configRow.get(4)); }
                    if(configRow.get(3).contains(QR_ATTRIBUTE)) { referencesIndex.add(configRow.get(4)); }
                }
            }
            showedNames = new String[showNames.size()];
            showNames.toArray(showedNames);
            namesMap = new String[nameMap.size()];
            nameMap.toArray(namesMap);
    }

    private String getParameterName(int index) {
        return REC_PREFIX + String.valueOf(index);
    }

    private String getReference(String code){
        return ADDITION_TO_REFERENCE + code;
    }

    private void setReference(String reference, String insides) throws IOException {
        out.print("<a href=\""+reference+"\">");
        out.print(insides);
        out.print("</a>");
    }

    private boolean isDate(String date) {
        if (date == null) return (false);
        date = date.trim();
        if (date.equals("-")) date = SZ_EMPTY;
        if (date.equals("null")) date = SZ_EMPTY;
        if (date.equals("(null)")) date = SZ_EMPTY;
        return (!date.equals(SZ_EMPTY));
    }

    private void printUpdatePageButtons() throws Exception {
        out.print("<input type=\"submit\" name=\""+ACTION_CANCEL+"\" value=\"Отмена\"/>&nbsp;");
        out.print("<input type=\"submit\" name=\""+ACTION_REFRESH+"\" value=\"Обновить\"/>&nbsp;");
        out.print("<input type=\"submit\" name=\""+ACTION_SAVE+"\" value=\"Сохранить\"/>&nbsp;");
    }

    private void printRedirectButton(String bName, String bValue, String bHref) throws Exception {
        out.println("<a href=\"" + bHref + "/\">");
        out.println("<input type=\"" + bName + "\" value=\"" + bValue + "\"/>");
        out.println("</a>");
    }

    private void startCreateForm(String member, String range, String action) throws Exception {
        out.println("<form action=\"" + getRequestParamsURL(CGI_NAME, CMD_UPDATE, member, range, null, action) + "\" method=\"POST\">");
    }

    private void startUpdateForm(String member, String range, String ZRID, String action) throws Exception {
        out.println("<form action=\"" + getRequestParamsURL(CGI_NAME, CMD_UPDATE, member, range, ZRID, action) + "\" method=\"POST\">");
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

    private void printTableUpsideString(String optionalParam, Object... outputString) throws Exception {
        beginTRow();
        if(!(optionalParam.equals("") | optionalParam == null | optionalParam.equals("null")))
            printCell(optionalParam);
        for (int i = 0; i < outputString.length; i++) {
            printCell(outputString[i]);
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
    public void printCellCardTools(String member, String range, Long ZRID) throws IOException, Exception
    {
      printCell("<a href=\'" + getRequestParamsURL(CGI_NAME, CMD_PRODVIEW, member, range, ZRID.toString()) + "\'>" +
                            "&lt;карточка&gt;" + "</a>"); //SIC! а вообще, надо делать немного по-другому
	// +"<br/>"+ "<input type=\"button\"value=\"Удалить\" onclick=\"allertToDeleteRecord()\">");
    }

    private void printCell(Object tElement, int colspan) throws IOException, Exception {
        out.println("<td colspan='" + colspan + "'>");
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

    private String getRequestParamsURL(String... params) {
        if (params == null)
            return (null);
        StringBuffer buffer = new StringBuffer();
        int i = 0;
        if (CGI_NAME.equals(params[0])) {
            buffer.append(CGI_NAME + "?");
            i++;
        }
        for (int j = 0; i < params.length; i++, j++) {
            if (i != params.length - 1)
                buffer.append(STD_REQUEST_PARAMETERS[j] + "=" + params[i] + "&");
            else
                buffer.append(STD_REQUEST_PARAMETERS[j] + "=" + params[i]);
        }
        return buffer.toString();
    }

    private boolean checkShellInjection(String parameter) {
        return parameter.contains("..");
    }

    public static String getCurrentDate4ZDATE() throws Exception {
        return (new SimpleDateFormat("y-MM-dd HH:mm:ss").format(new Date()));
    }

    public static String getRequestUser4ZUID(HttpServletRequest request) throws Exception {
        return (request.getRemoteUser() + "@" + request.getRemoteAddr());
    }

    private String obj2str(Object obj) {
        if (obj == null) obj = "";
        return obj.toString();
    }

    public void println() throws Exception { out.println("<br/>"); }

    public void printerr(String msg) throws Exception { out.print("<b>" + msg + "</b>"); }

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

    public void sendAllert(String msg) throws Exception {
        out.println("<script type=\"text/javascript\">");
        out.println("alert('" + msg + "');");
        out.println("</script>");
    }

    private boolean checkNewRecord(ZCSVRow rowToCheck) throws Exception {
        sendAllert(rowToCheck.get(0));
        int zrid = Integer.parseInt(rowToCheck.get(0));
        ZCSVRow row;
        if(zcsvFile != null) {
            try {
                row = zcsvFile.getRowObjectByIndex(zrid - 1);
            } catch (IndexOutOfBoundsException | NullPointerException ex) {
                return true;
            }

            for (int i = 5; i < row.getNames().length; i++) {
                String s1 = rowToCheck.get(i).toString();
                String s2 = row.get(i).toString();
                if (!s1.equals(s2)) {
                    return true;
                }
            }
        }
        return false;
    }

    private boolean checkForCorrectness(HttpServletRequest request) throws Exception {
        String bufferParameter = new String();
        boolean answer = true;
        for (Integer i = 5; i < namesMap.length; i++) {
            bufferParameter = request.getParameter(REC_PREFIX + i);
            if(i == 5)
                if(bufferParameter.startsWith(request.getParameter(PARAM_RANGE)));
                    answer = false;
        }
        return answer;
    }

    private String genNewQr(String p_range) throws IOException, ZCSVException {
        long maxZOID = 0;
        for(int i = 0;i<zcsvFile.getFileRowsLength();i++){
            if(!zcsvFile.getRowObjectByIndex(i).get(5).equals("") & !zcsvFile.getRowObjectByIndex(i).get(5).equals(null))
                if(Long.parseLong(zcsvFile.getRowObjectByIndex(i).get(5).substring(p_range.length()), 16) > maxZOID)
                    maxZOID = Long.parseLong(zcsvFile.getRowObjectByIndex(i).get(5).substring(p_range.length()),16);
        }
        maxZOID++;
        return String.format("%s%03X",p_range, maxZOID);
    }
%>
<html>
<head>
    <title><%= CGI_TITLE %>
    </title>
    <link rel="stylesheet" type="text/css" href="css/webcss.css">
    <link rel="stylesheet" type="text/css" href="css/head.css">
    <script src="js/javascript.js"></script>
</head>
<body>
<h2><a href="/"><%= CGI_TITLE %></a> <!-- href to start page of system -->
</h2>
<hr>
<div>
    <a href='<%= CGI_NAME %>'>Начало</a>&nbsp;
    <a href='<%= CGI_NAME %>?cmd=test'>Тест</a>&nbsp;
    <a href='test.jsp'>test.jsp</a>&nbsp;
</div>
<%
    set_request_hints(request, response);
    long enter_time = System.currentTimeMillis();
    this.out = out;
    String CMD = getRequestParameter(request, PARAM_CMD, CMD_MEMBERS);

    allMoney = BigDecimal.ZERO;
    allMoneyWait = BigDecimal.ZERO;
    allMoneySent = BigDecimal.ZERO;

    namesMap = null;
    showedNames = null;

    try {
        read_parameters_from_web_xml();
        if (QRDB_PATH == null)
            throw new ZCSVException("Не задан параметр пути к базе данных.");
        Members.setWayToDB(QRDB_PATH);

        String p_member = getRequestParameter(request, PARAM_MEMBER); // Check to SI
        String p_range = getRequestParameter(request, PARAM_RANGE); // Check to SI
        String p_ZRID = getRequestParameter(request, PARAM_ZRID);
        String p_action = getRequestParameter(request, PARAM_ACTION);

        switch (CMD) {
            case CMD_MEMBERS: setMembersPage(); break;
            case CMD_RANGES: setRangesPage(p_member); break;
            case CMD_PRODTABLE:
                try { loadDataFromConfigFile(p_member, p_range); }
                catch (Exception e){createDefaultConfig();}
                setProductsPage(p_member, p_range);  break;
            case CMD_CHANGE_CONFIG:
                loadDataFromConfigFile(p_member, p_range); setChangeConfigPage(p_member, p_range); break;
            case CMD_PRODVIEW:
                loadDataFromConfigFile(p_member, p_range); setProdViewPage(p_member, p_range, p_ZRID); break;
            case CMD_UPDATE:
                loadDataFromConfigFile(p_member,p_range);
                switch (p_action) {
                    case ACTION_EDIT:
                        setUpdateProductPage(p_member, p_range, p_ZRID, p_action);
                        break;
                    case ACTION_NEWRECORD:
                        setNewRecordPage(p_member, p_range, p_action);
                        break;
                    case ACTION_CANCEL:
                        sendAllert("Hello");
                    case ACTION_REFRESH:
                        if(checkForCorrectness(request))
                            sendAllert("True");
                        else
                            sendAllert("False");
                        break;
                    case ACTION_SAVE:
                        try {
                            ZCSVRow newRow;
                            if (p_ZRID == null || SZ_NULL.equals(p_ZRID)) {
                                Integer zrdsLength = zcsvFile.getFileRowsLength();
                                newRow = new ZCSVRow();
                                newRow.setNames(namesMap);
                                newRow.setStringSpecificIndex(0, String.valueOf(zrdsLength + 1));
                                newRow.setStringSpecificIndex(1, "1");
                            } else {
                                newRow = zcsvFile.getRowObjectByIndex(Integer.parseInt(p_ZRID) - 1).clone();
                                Integer newVerion = Integer.parseInt(newRow.get(1)) + 1;
                                newRow.setStringSpecificIndex(1, newVerion.toString());
                            }
                            newRow.setStringSpecificIndex(2, getCurrentDate4ZDATE());
                            newRow.setStringSpecificIndex(3, getRequestUser4ZUID(request));
                            newRow.setStringSpecificIndex(4, NEW_RECORD_STATUS);

                            for (Integer i = 5; i < newRow.getNames().length; i++) {
                                newRow.setStringSpecificIndex(i, MsgContract.value2csv(request.getParameter(getParameterName(i))));
                            }
                            if(checkNewRecord(newRow)) { zcsvFile.appendNewStringToFile(newRow); }
                            response.sendRedirect(getRequestParamsURL(CGI_NAME, CMD_PRODTABLE, p_member, p_range));
                        } catch (Exception ex) { ex.printStackTrace(response.getWriter()); }
                        break;
                    case ACTION_SEEHISTORY: setHistoryPage(p_member,p_range,p_ZRID,p_action); break;
                    case ACTION_DELETE:
                        try {
                            ZCSVRow row = zcsvFile.getRowObjectByIndex(Integer.parseInt(p_ZRID) - 1);
                            Integer newVersion = Integer.parseInt(row.get(1)) + 1;
                            row.setStringSpecificIndex(1, newVersion.toString());
                            row.setStringSpecificIndex(2, getCurrentDate4ZDATE());
                            row.setStringSpecificIndex(3, getRequestUser4ZUID(request));
                            row.setStringSpecificIndex(4, "D");
                            zcsvFile.appendNewStringToFile(row);
                            response.sendRedirect(getRequestParamsURL(CGI_NAME, CMD_PRODTABLE, p_member, p_range));
                        }catch (Exception ex){
                            sendAllert("Error with deleting! Please call the system admitistrator!");
                        }
                        break;
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
    } finally {
        if(zcsvFile != null) zcsvFile.closeFile();
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
