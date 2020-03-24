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
    private final static String QR_CODE_RECORD_STATUS = "QR код"; // SIC! ну нельзя так! это не имя поля, это только заголовок, который можно переопределить

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
    private final String QR_ATTRIBUTE = "QR,";
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
    public final static String CMD_TESTTAB = "testtab"; // Testing page
    //private final static String[] CMD_PARAMETERS = {CMD_MEMBERS, CMD_RANGES, CMD_CHANGE_CONFIG, CMD_PRODTABLE, CMD_PRODVIEW, CMD_UPDATE, CMD_TEST};

    // Money counters
    private BigDecimal allMoney = BigDecimal.ZERO;
    private BigDecimal allMoneySent = BigDecimal.ZERO;
    private BigDecimal allMoneyWait = BigDecimal.ZERO;

    private ZCSVRow edittedRow;
    private ZCSVFile zcsvFile;
    private String QRDB_PATH = null;
    private JspWriter out;
    private String[] namesMap;
    private String[] getNames(){return(namesMap);} //SIC! для транзита
    private String[] showedNames;
    // new set of stores for CSVConf
    private int num_of_csvconf_fields = -1;
    private String[] csvconf_FCodes=null;
    private String[] csvconf_FNames=null;
    private String[] csvconf_FTypes=null;
    private Set<String>[] csvconf_FOptions=null;
    private String[] csvconf_FCaptions=null;
    private String[] csvconf_FComments=null;
    private Object get_csvconf_field_attribute(int i,Object[] attr_column)
    {if(i<0 || i>num_of_csvconf_fields)return(null);if(attr_column==null)return(null); if(i>=attr_column.length) return(null);return(attr_column[i]);}
    private String getFCode(int i){ return((String)get_csvconf_field_attribute(i,csvconf_FCodes)); }
    private String getFType(int i){ return((String)get_csvconf_field_attribute(i,csvconf_FTypes)); }
    private String getFName(int i){ return((String)get_csvconf_field_attribute(i,csvconf_FNames)); }
    private Set<String> getFOption(int i){ return((Set<String>)get_csvconf_field_attribute(i,csvconf_FOptions)); }
    private String getFCaption(int i){ return((String)get_csvconf_field_attribute(i,csvconf_FCaptions)); }
    private String getFComment(int i){ return((String)get_csvconf_field_attribute(i,csvconf_FComments)); }
//    private ArrayList<String> nameMap = new ArrayList();
//    private ArrayList<String> showNames = new ArrayList();
    private ArrayList<String> referencesIndex = new ArrayList();
    //
    private int csv_header_length=-1;
    private int csv_QRfield_index=-1;
    private String szDefaultCSVConf=null;
    public void initJSPGlobals() { // it's constructor-like method, use it before process any request
    // Money counters
     allMoney = BigDecimal.ZERO;
     allMoneySent = BigDecimal.ZERO;
     allMoneyWait = BigDecimal.ZERO;

     edittedRow = null;
     zcsvFile = null;
     QRDB_PATH = null;
     out = null;
     namesMap = null;
     showedNames = null;
//     nameMap = new ArrayList();
//     showNames = new ArrayList();
     referencesIndex = new ArrayList();
     //
     csv_header_length=-1;
     csv_QRfield_index=-1;
     szDefaultCSVConf=null;
    // new set of stores for CSVConf
    num_of_csvconf_fields = -1;
    csvconf_FCodes=null;
    csvconf_FNames=null;
    csvconf_FTypes=null;
    csvconf_FOptions=null;
    csvconf_FCaptions=null;
    csvconf_FComments=null;
    } // initJSPGlobals

    public int getCSVHeaderLength(){if(csv_header_length<0) return(STD_QRHEANOR_FIELDS_NUM); return(csv_header_length);}
    public int getQRFieldIndex(){if(csv_header_length<0 && csv_QRfield_index<0)return(getCSVHeaderLength());return(csv_QRfield_index);}
    public String getDefaultCSVConf()
    {
    if(szDefaultCSVConf != null) return(szDefaultCSVConf);
    szDefaultCSVConf = makeDefaultQRCSVConf();
    return(szDefaultCSVConf);
    }
//
// Гвоздями-прибытое-состояние db/ranges/ranges3.csv на 31 декабря 2019
// переделать на загрузку из файла
//
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


// набор структур для описания структуры файла по-умолчанию, унаследованного от первой версии системы edit-qr
// используется как подрузумеваемый, если нет специального файла *.tab
//
public static int STD_QRHEANOR_FIELDS_NUM=5;
private static String FieldNames[] ={
"ZRID",
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
"NN", // "ZRID",
"NUL", // "ZVER",
"NUL", // "ZDATE",
"NUL", // "ZUID",
"NUL", // "ZSTA",
"NUL,SHOW,HEX,QR,QRANGE_WARN", // "QR",
"NUL,SHOW", // "CONTRACTNUM",
"NUL", // "contractdate",
"NUL,SHOW,QRMONEY", // "MONEY",
"NUL", // "SUPPLIER",
"NUL,SHOW", // "CLIENT",
"NUL,SHOW,QRPRODTYPE", // "PRODTYPE",
"NUL,SHOW,QRPRODMODEL", // "MODEL",
"NUL,SHOW,EN", // "SN",
"NUL", // "prodate",
"NUL", // "shipdate",
"NUL", // "SALEDATE",
"NUL,QRMONEYGOT", // "DEPARTUREDATE",
"NUL", // "WARRANTYSTART",
"NUL", // "WARRANTYEND",
"NUL,TEXTAREA" // "COMMENT"
};
private static String FieldCaptions[] ={
"ZRID",
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
"ZRID - идентификатор объекта (записи) в файле, записи с одинаковым ZRID - разные версии одной записи",
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

///*
//    private String DEFAULT_CSV_TAB =
//"#Атрибут\tЗначение        Значение2/код\n" +
//"NAME\tTISC.DRow\tDW\n" +
//"OBJECT\tDocument        D\n" +
//"HEADER\tSTD_HEADER\n" +
//"PARENT\tTISC.DDocument  DD\n" +
//"CHILD\tTISC.DRProperty DP\n" +
//"#Код\tПоле    Тип     Атрибуты        Название        Описание\n" +
//"01\tZRID\ttext\tNN,UNIQ=OBJECT\tZRID\n" +
//"02\tZVER\ttext\tNUL\tZVER\n" +
//"03\tZDATE\ttext\tNUL\tZDATE\n" +
//"04\tZUID\ttext\tNUL\tZUID\n" +
//"05\tZSTA\ttext\tNUL\tZSTA\n" +
//"06\tQR\ttext\tSHOW,NUL,QR\tQR код\n" +
//"07\tcnum\ttext\tSHOW,NUL\t№ договора\n" +
//"08\tcdate\ttext\tNUL\tДата договора\n" +
//"09\tcmoney\ttext\tSHOW,NUL,QRMONEY\tДеньги по договору\n" +
//"10\tsupplyer\ttext\tSHOW,NUL\tЮр-лицо поставщик\n" +
//"11\tclient\ttext\tSHOW,NUL\tЮр-лицо клиент\n" +
//"12\tprodtype\ttext\tNUL\tТип продукта\n" +
//"13\tprodmodel\ttext\tSHOW,NUL\tМодель продукта\n" +
//"14\tsn\ttext\tSHOW,NUL\tSN\n" +
//"15\tprodate\ttext\tNUL\tДата производства\n" +
//"16\tGTD\ttext\tNUL\tНомер ГТД\n" +
//"17\tsaledate\ttext\tNUL\tДата продажи\n" +
//"18\tsendate\ttext\tNUL\tДата отправки клиенту\n" +
//"19\twarstart\ttext\tNUL\tДата начала гарантии\n" +
//"20\twarend\ttext\tNUL\tДата окончания гарантии\n" +
//"21\tcomment\ttext\tNUL\tКомментарий (для клиента)\n";
//*/
    public void loadZCSVFile4Range(String p_member, String p_range)
    {
        String rootPath = Members.getWayToDB() + p_member + "/" + p_range + "/"; //SIC! проверить параметры на shell-path injection
        zcsvFile = setupZCSVPaths(rootPath, DB_FILENAME);
	try{
        if (zcsvFile.tryOpenFile(1)) zcsvFile.loadFromFileValidVersions();
	}
	catch(Exception e){printex(e);}
        loadConfig4Range(p_member,p_range);
    }
    private ZCSVFile setupZCSVPaths(String rootPath, String fileName) {
        ZCSVFile file = new ZCSVFile();
        file.setRootPath(rootPath);
        file.setFileName(fileName);
        return file;
    }
    public void loadConfig4Range(String p_member, String p_range)
    {
        try { loadDataFromConfigFile(p_member, p_range); }
        catch (Exception e){} //SIC! сделать лучше
    }
    private void loadDataFromConfigFile(String member, String range)
     throws  ZCSVException, Exception
    {
        String rootPath = Members.getWayToDB() + member + "/" + range + "/";
        ZCSVFile configFile = setupZCSVPaths(rootPath, DB_CONFIG_FILENAME);
        ArrayList<String> nameMap = new ArrayList<>();
        ArrayList<String> showNames = new ArrayList<>();
        int i=0;
        try {configFile.loadConfigureFile();}
        catch(Exception e) {configFile.loadConfigFromString(getDefaultCSVConf());}
         List<ZCSVRow> field_rows = new ArrayList<>();
            for (i = 0; i < configFile.getFileRowsLength(); i++) { //SIC! это цикл нужно убрать, все что в нем - упразднить
                ZCSVRow configRow = configFile.getRowObjectByIndex(i);
                if (configRow.get(0).length() == 2) { // it is field "0X name...."
                    field_rows.add(configRow);
                    nameMap.add(configRow.get(4));
                    if (configRow.get(3).contains(SHOW_ATTRIBUTE)) { showNames.add(configRow.get(4)); }
                    if(configRow.get(3).contains(QR_ATTRIBUTE)) { referencesIndex.add(configRow.get(4)); }
                }
            }
            showedNames = new String[showNames.size()];
            showNames.toArray(showedNames);
            namesMap = new String[nameMap.size()];
            nameMap.toArray(namesMap);
     // new set of stores for CSVConf
     num_of_csvconf_fields = field_rows.size();
     csvconf_FCodes= new String[num_of_csvconf_fields];
     csvconf_FNames=new String[num_of_csvconf_fields];
     csvconf_FTypes=new String[num_of_csvconf_fields];
     csvconf_FOptions=new HashSet[num_of_csvconf_fields];
     csvconf_FCaptions=new String[num_of_csvconf_fields];
     csvconf_FComments=new String[num_of_csvconf_fields];
     for (i = 0; i < num_of_csvconf_fields; i++)
     {
      ZCSVRow row = field_rows.get(i);
      csvconf_FCodes[i]= get_index_value_form_ZCSVRow(row,0);
      csvconf_FNames[i]=get_index_value_form_ZCSVRow(row,1);
      csvconf_FTypes[i]=get_index_value_form_ZCSVRow(row,2);
      csvconf_FOptions[i]=extractFOptionSet(get_index_value_form_ZCSVRow(row,3));
      csvconf_FCaptions[i]=get_index_value_form_ZCSVRow(row,4);
      csvconf_FComments[i]=get_index_value_form_ZCSVRow(row,5);
     }
    } //loadDataFromConfigFile
    String get_index_value_form_ZCSVRow(ZCSVRow row, int index) // это вспомогательная функция, всегда получить значение и не развалиться
    {
     String v="";
     try{ v= row.get(index); }
     catch(Exception e){nodebug_log("get_index_value_form_ZCSVRow",e);} //SIC! да криво, но KISS
     return(v);
    }
    Set<String> extractFOptionSet(String options) // это вспомогательная функция, преобразовать строку "o1,o2,.." в набор { "o1","o2",... }
    {
     HashSet<String> hs = new HashSet<>(); if(options==null)options="";
     String[] opts = options.split(",");
     int i=0;
     for(i=0;i<opts.length;i++){String o=opts[i].trim();if(o.length()>0)hs.add(o);nodebug_log("'" + o + "'");}
     return(hs);
    }
    boolean checkFOptions(int i, String options) // true, если для поля установлены _все_ перечисленные опции
    {
     if(csvconf_FOptions==null) return(false);
     if(csvconf_FOptions.length<=i) return(false);
     Set<String> fopts = csvconf_FOptions[i];
     if(fopts==null) return(false);
     Set<String> hs = extractFOptionSet(options);
     boolean result = fopts.containsAll(hs);
     return(result);
    }
    public String makeDefaultQRCSVConf()
    {
    StringBuffer sb = new StringBuffer();
    sb.append("# Default master.list.csv.tab for edit.qr.qxyz.ru\n");
    sb.append("#Атрибут\tЗначение\tЗначение2/код\n");
    sb.append("NAME\tQR_QXYZ.Item\tDW\n");
    sb.append("OBJECT\tNone        D\n");
    sb.append("HEADER\tSTD_PSPNHEANOR\n");
    sb.append("PARENT\tnone  NN\n");
    sb.append("CHILD\tnone NN\n");
    sb.append("#Код\tПоле\tТип\tАтрибуты\tНазвание\tОписание\n");
    int num_fields = FieldNames.length; 
    int i=0;
    for(i=0;i<num_fields;i++)
    {
     sb.append(String.format("%02d",new Integer(i+1))); sb.append("\t");
     sb.append(FieldNames[i]); sb.append("\t");
     sb.append("text"); sb.append("\t");
     sb.append(FieldOptions[i]); sb.append(",\t");
     sb.append(FieldCaptions[i]); sb.append("\t");
     sb.append(FieldComments[i]);
     sb.append("\n");
    }
    return(sb.toString());
    } // makeDefaultQRCSVConf

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
            case PARAM_ACTION: // SIC! Это я такое сделал? переделать!
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
    //
    //
    // PAGES
    //
    // 
    private void setMembersPage() throws Exception {
        Members members = new Members();
        String[] allRegisteredMembers = members.getCompanyNames();
        beginT();
        for (int i = 0; i < allRegisteredMembers.length; i++) {
            beginTRow();
            printCellRaw("<a href=\'" + getRequestParamsURL(CGI_NAME, CMD_RANGES, allRegisteredMembers[i]) + "\'>" + allRegisteredMembers[i] + "</a>");
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
        wln(s);

        String[] allItems = rController.getRanges();
        beginT();
        printTRow(new String[]{"Диапазан", "Описание"});
        for (int i = 0; i < allItems.length; i++) {
            String range = allItems[i];
            beginTRow();
            printCellRaw("<a href=\'" + getRequestParamsURL(CGI_NAME, CMD_PRODTABLE, member, range) + "\'>" + range + "</a>");
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
                wln("<table class='memberstable' border='1'>"); //SIC! println Evil, '1' is better \"1\"
                printTableUpsideString(OPTIONAL_PRODUCTS_TABLE_PARAM, showedNames);
                for (int i = zcsvFile.getFileRowsLength() - 1; i >= 0; i--) {
                    ZCSVRow eachRow = zcsvFile.getRowObjectByIndex(i);
                    eachRow.setNames(namesMap);
                    if(eachRow.get(4).equals(DELETED_RECORD_STATUS))
                        continue;
                    beginTRow();
                    printCellCardTools(member,range,new Long(i+1));
                    for (int j = 0; j < showedNames.length; j++) {
                        String wroteString = eachRow.get(showedNames[j]);
                        if(referencesIndex.contains(showedNames[j])){
                            beginTCell();setReferenceQRView(getReference(wroteString), wroteString);endTCell();
                        } else {
                            printCell(wroteString);
                        }
                    }
                    endTRow();
                    BigDecimal dec_money = BigDecimal.ZERO;
                    try {
                        dec_money = MsgContract.str2dec(eachRow.get("Деньги по договору"));
                        allMoney = allMoney.add(dec_money);

                        if (isDate(eachRow.get("Дата отправки клиенту"))) { allMoneySent = allMoneySent.add(dec_money); } //SIC! так нельзя!
                        else { allMoneyWait = allMoneyWait.add(dec_money); }
                    } catch (Exception ex) {/*wln("Ошибка подсчета денег!");*/} // SIC!
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

        ZCSVRow row = zcsvFile.getRowObjectByIndex(Integer.parseInt(ZRID) - 1); //SIC! здесь что-то не так!
        String[] Captions = getNames();
        int count_captions = Captions.length;
        int count_fields = row.getDataLength();
        int max_fields_count=count_fields;
        if(count_captions > max_fields_count) max_fields_count= count_captions;
        beginT();
	if(getQRFieldIndex() >= 0 )
	{
	beginTRow(); printCell("QR картинка:"); beginTCell();
         setReferenceQRView(
                getReference(row.get(getQRFieldIndex())) ,
                "<img src=\"qr?p_codingString=" + row.get(getQRFieldIndex()) + "&p_imgFormat=GIF&p_imgSize=140&p_imgColor=0x000000\"/>" //SIC! html-injection
        );
        endTCell(); endTRow();
	}

        for (int i = getCSVHeaderLength(); i < max_fields_count; i++) {
          String caption = i + ":"; String value = "";
	    if(i< count_captions) caption = Captions[i];
          if(i< count_fields) value = row.get(i);
            beginTRow();
              printCell(caption);
              if(i==getQRFieldIndex() && value.length() > 0 ){beginTCell();setReferenceQRView(getReference(value),value);endTCell();} else //SIC! улучшить
              printCell(value);
//            printCell((getNames()[i] == null) ? "Не определенное имя" : getNames()[i]);
//            if(referencesIndex.contains(getNames()[i])) {
//                beginTCell();
//out.println(i + ":If");
//                setReferenceQRView((row.get(i) == null | SZ_NULL.equals(row.get(i))) ?
//                "" : getReference(MsgContract.csv2text(row.get(i))), MsgContract.csv2text(row.get(i)));
//                endTCell();
//            }
//	    else {
//	out.println("Else:" + i); printCell((row.get(i) == null | SZ_NULL.equals(row.get(i))) ? "" : MsgContract.csv2text(row.get(i)));
// }
            endTRow();
        } //for
        endT();
    } //setProdViewPage()

    private void setUpdateProductPage(String member, String range, String ZRID, String action) throws Exception {
        printUpsideMenu(
                new String[]{
                        "Назад",
                        "change name map(Experimental)",
                }, new String[] {
                        !ZRID.equals(SZ_NULL) ? getRequestParamsURL(CMD_PRODVIEW, member, range, ZRID)
                        : getRequestParamsURL(CMD_PRODTABLE, member, range),
                        getRequestParamsURL(CMD_UPDATE, member, range, ZRID, ACTION_CHANGENAMEMAP),
                });
        println();

        if(!ZRID.equals(SZ_NULL) & edittedRow == null)
            edittedRow = zcsvFile.getRowObjectByIndex(Integer.parseInt(ZRID) - 1).clone(); //SIC! здесь мины!
        printEditForm(member, range, ZRID, action, namesMap, edittedRow);
    }
    // printEditForm() - получает _снаружи_ все данные, необходимые для отображения формы редактирования
    // 			ни в какие файлы оно уже не лазает, ни в какие глобальные переменные тоже,
    //                  оно просто рисует форму, и ему _абсолютно_ все-равно, это новая запись, запись прочитанная из файла,
    //                  или запись реконструированная из данных html формы пришедшей методом POST
    //                  и ТОГДА кнопка "обновить" работает абсолютно естественно, а также абсолютно естественно реализуется
    //                  процедура контроля качества (QC), если она не проходит, пользователь получает обратно сообщение об
    //                  ошибке и форму со своими данными, которые он может продолжить редактировать,
    //                  и пихать в систему до посинения, пока не исправит _все_ свои ошибки
    //                  И НИКАКИХ EXCEPTION ТАКАЯ ФУКНЦИЯ ПОРОЖДАТЬ НЕ МОЖЕТ! .
    //
    //			P.S. а ещо при изменении JSP я постоянно получаю "Unexpected error occured! Call the system administrator please."
    //			сейчас этого НЕ ДОЛЖНО БЫТЬ. Пользователь редактирует форму, она не проходит потомучтоошибкавjsp, он поворачивается
    //			к нам и говорит - "поправте", мы правим и говорим "повторяй" он повторяет - и все должно работать!
    //private void printEditForm(String member, String range, String ZRID, zCSVFile config, zCSVRow rec) throws Exception {
    private void printEditForm(String member, String range, String ZRID, String action, String [] config, ZCSVRow row) throws Exception {
        //try {
            ZCSVRow edittedRow = row;
        String[] Captions = getNames();
        String[] Comments = FieldComments;
        int count_captions = Captions.length;
        int count_comments = Comments.length;
        int count_fields = row.getDataLength();
        int max_fields_count=count_fields;
        if(count_captions > max_fields_count) max_fields_count= count_captions;
            if (edittedRow.getNames() == null) {
                edittedRow.setNames(config);
            }

            startUpdateForm(member, range, ZRID, ACTION_EDIT);
            String newqr = ""; try{newqr= genNewQr(range); } catch(Exception e){sendAllert("genNewQr() опять сломался!");} //SIC! криво, но я уже 3-й раз правлю грабли там
            String parameterBuffer;
            printUpdatePageButtons();

            beginT();
            for (int i = getCSVHeaderLength(); i < max_fields_count; i++) {
              String caption = i + ":"; String value = ""; String comment = "";
              String input_field_raw = "";
	      if(i< count_captions) caption = getFCaption(i);
              if(i< count_fields) value = row.get(i);
              if(i< count_comments) comment = getFComment(i);

              if(checkFOptions(i,"TEXTAREA"))
              {
              beginTRow();
               printCell(caption);
               printCell(comment,2);
              endTRow();
              beginTRow();
               beginTCell(3);
               printInputTextarea(mkFName(i),6,72,value);
               endTCell();
              endTRow();
               continue;
              }
              input_field_raw = mkFieldInputText(mkFName(i), value, 30, 0);
              if(i==getQRFieldIndex()){
                 input_field_raw = mkFieldInputText(mkFName(i), value, 16, 16);
                 input_field_raw = "<table><tr><td>" + input_field_raw + "</td><td>" +
                    String.format("<input type=\"button\" onclick=\"setQR('%s','%s')\" value=\"новый QR\"/>",mkFName(i), newqr) +
                    "</td>" + "</tr></table>";
              }
              beginTRow();
               printCell(caption);
               printCellRaw(input_field_raw);
               printCell(comment);
              endTRow();
            }
            endT();
//            beginT();
//            for(int i = getCSVHeaderLength(); i < namesMap.length; i++) {
//                parameterBuffer = getParameterName(i);
//                if (config[i].equals(QR_CODE_RECORD_STATUS)) {
//                    if(edittedRow.get(i).equals(SZ_EMPTY))
//                        edittedRow.setStringSpecificIndex(i, newqr);
//                    printTRow(new Object[]{
//                            config[i],
//                            printInput("text", "qrcode", parameterBuffer, edittedRow.get(i)),
//                            String.format("<input type=\"button\" onclick=\"newQR('%s')\" value=\"Новый qr код\"/>", newqr),
//                            FieldComments[i],
//                    });
//                } else if (config[i].toLowerCase().contains("комментарий")) { //SIC! так не надо! см опции поля!
//                    printTRow(new Object[]{
//                            config[i],
//                            "<textarea name='" + parameterBuffer + "' " + "rows='5' cols='40'>" + edittedRow.get(i) + "</textarea>",
//                            FieldComments[i],
//                    });
//                } else {
//                    printTRow(new Object[]{
//                            config[i],
//                            printInput("text", "", parameterBuffer, edittedRow.get(i)),
//                            FieldComments[i],
//                    });
//                }
//            }
//            endT();
            endForm();
        //} catch (Exception ex) { sendAllert("An error occured"); } //SIC! remove sendAllert()
    } //printEditForm()

    private void setActions(String p_member, String p_range, String p_ZRID, String p_action, HttpServletRequest request, HttpServletResponse response) throws Exception {
        switch (p_action){
            case ACTION_EDIT:
                setUpdateProductPage(p_member, p_range, p_ZRID, p_action);
                break;
            case ACTION_NEWRECORD:
                edittedRow = new ZCSVRow();
                setUpdateProductPage(p_member, p_range, p_ZRID, p_action);
                break;
            case ACTION_CANCEL:
                if(p_ZRID.equals(SZ_NULL))
                    response.sendRedirect(getRequestParamsURL(CGI_NAME, CMD_PRODTABLE, p_member, p_range));
                else
                    response.sendRedirect(getRequestParamsURL(CGI_NAME, CMD_PRODVIEW, p_member, p_range,p_ZRID));
                break;
            case ACTION_REFRESH:
                if(edittedRow == null) {
                    edittedRow = new ZCSVRow();
                    edittedRow.setNames(namesMap);
                }
                for(Integer i = getCSVHeaderLength(); i < edittedRow.getNames().length; i++) {
                    edittedRow.setStringSpecificIndex(i, request.getParameter(getParameterName(i)));
                }
                setUpdateProductPage(p_member, p_range, p_ZRID, p_action);
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
                        if(newRow.getNames() == null)
                            newRow.setNames(namesMap);
                        Integer newVerion = Integer.parseInt(newRow.get(1)) + 1;
                        newRow.setStringSpecificIndex(1, newVerion.toString());
                    }
                    newRow.setStringSpecificIndex(2, getCurrentDate4ZDATE());
                    newRow.setStringSpecificIndex(3, getRequestUser4ZUID(request));
                    newRow.setStringSpecificIndex(4, NEW_RECORD_STATUS);

                    for (Integer i = getCSVHeaderLength(); i < newRow.getNames().length; i++) {
                        newRow.setStringSpecificIndex(i, request.getParameter(getParameterName(i)));
                    }
                    if(checkNewRecord(newRow)) {
                        zcsvFile.appendNewStringToFile(newRow);
                    }
                    response.sendRedirect(getRequestParamsURL(CGI_NAME, CMD_PRODTABLE, p_member, p_range));
                } catch (Exception ex) { ex.printStackTrace(response.getWriter()); }
                break;
            case ACTION_SEEHISTORY: setHistoryPage(p_member,p_range,p_ZRID,p_action); break;
            case ACTION_DELETE:
                try {
                    ZCSVRow row = zcsvFile.getRowObjectByIndex(Integer.parseInt(p_ZRID) - 1);
                    if(row.getNames() == null)
                        row.setNames(namesMap);
                    Integer newVersion = Integer.parseInt(row.get(1)) + 1;
                    row.setStringSpecificIndex(1, newVersion.toString());
                    row.setStringSpecificIndex(2, getCurrentDate4ZDATE());
                    row.setStringSpecificIndex(3, getRequestUser4ZUID(request));
                    row.setStringSpecificIndex(4, "D");
                    for(int i = getCSVHeaderLength(); i < row.getNames().length; i++)
                        row.setStringSpecificIndex(i, "");
                    zcsvFile.appendNewStringToFile(row);
                    response.sendRedirect(getRequestParamsURL(CGI_NAME, CMD_PRODTABLE, p_member, p_range));
                }catch (Exception ex){
                    sendAllert("Error with deleting! Please call the system admitistrator!");
                }
                break;
        }
    } //setActions()

    private void setHistoryPage(String member, String range, String ZRID, String action) throws Exception {
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
                printCell(row.get(i));
            endTRow();
            row = row.getPrevious();
        }
        endT();
    }

    /// END PAGES PART


    private String getParameterName(int index) {
        return REC_PREFIX + String.valueOf(index);
    }

    private String getReference(String code){
        return ADDITION_TO_REFERENCE + code;
    }

    private void setReference(String reference, String insides) {
        w("<a href=\""+reference+"\">");
        w(insides);
        w("</a>");
    }
    private void setReferenceQRView(String reference, String insides) {
        w("<a href='"+reference+"' target='_qrview'>");
        w(insides);
        w("</a>");
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
        w("<input type=\"submit\" name=\""+ACTION_CANCEL+"\" value=\"Отмена\"/>&nbsp;");
        w("<input type=\"submit\" name=\""+ACTION_REFRESH+"\" value=\"Обновить\"/>&nbsp;");
        w("<input type=\"submit\" name=\""+ACTION_SAVE+"\" value=\"Сохранить\"/>&nbsp;");
    }

    private void printRedirectButton(String bName, String bValue, String bHref) throws Exception {
        wln("<a href=\"" + bHref + "/\">");
        wln("<input type=\"" + bName + "\" value=\"" + bValue + "\"/>");
        wln("</a>");
    }
///*
//    private void startCreateForm(String member, String range, String action) throws Exception {
//        out.println("<form action=\"" + getRequestParamsURL(CGI_NAME, CMD_UPDATE, member, range, null, action) + "\" method=\"POST\">");
//    }
//*/
    private void startUpdateForm(String member, String range, String ZRID, String action) throws Exception {
        wln("<form action=\"" + getRequestParamsURL(CGI_NAME, CMD_UPDATE, member, range, ZRID, action) + "\" method=\"POST\">");
    }

    private void endForm() throws Exception {
        wln("</form>");
    }

    private void printUpsideMenu(String[] menuItems, String[] menuReferences) throws Exception {
        wln("<ul>");
        for (int i = 0; i < menuItems.length; i++) {
            w("<li>");
            wln("<a href=\'" + CGI_NAME + "?" + menuReferences[i] + "\'>" + menuItems[i] + "</a>");
            w("</li>");
        }
        wln("</ul>");
        println();
    }

    private String printInput(String type, String id,String name, String value) throws Exception {
        return new String("<input type='" + type + "' id='" + id + "' name='" + name + "' value='" + value + "'/>");
    }
    private String mkInput(String type, String id,String name, String value) throws Exception {
        return new String("<input type='" + type + "' id='" + id + "' name='" + name + "' value='" + value + "'/>");
    }
 // input fields construction
 // imported from ConcepTIS...WASkin.java
public void printInputTextarea(String name, int rows, int cols, String value)
{
 w("<textarea name='");
 w(mkFName(name));
 w("' rows='");
 w("" + rows);
 w("' cols='");
 w("" + cols);
 w("' >");
 w(encodeFieldValue(value));
 wln("</textarea>");
}

private String mkFName(String name){ // changed for edit.qr
return(o2v(name));
}
private String mkFName(int i){ // written for edit.qr
return(mkFName(getParameterName(i)));
}

/** this string value (null) could be used to encode SQL NULL into String." */
public static final String SZ_NULL_AS_SQLNULL="null";
/** this string value ("null") must be used instead of SZ_NULL_AS_SQLNULL." */
public static final String SZ_NULL_AS_STRING="\"null\"";

/** encode value for using it in some kind of input field.
 * this encoding must take into consideration some special cases
 * like SQL NULL values and so on. Works together with decodeFieldValue.
 * null value will be encoded as string null and 4-characters string null
 * will be encoded as 6 characters string "null" (which can't be properly
 * encoded yet).
 *
 * @see #decodeFieldValue()
 */
public String encodeFieldValue(Object value)
{
if(value == null) return(SZ_NULL_AS_SQLNULL);
String v = o2t(value);
if(SZ_NULL_AS_SQLNULL.equals(v)) v = SZ_NULL_AS_STRING;
return(o2v(v));
}

/** decode value come from  some kind of input field.
 * this function must take into consideration some special cases
 * like SQL NULL values and so on. Works together with encodeFieldValue.
 *
 * @see #encodeFieldValue()
 */
public String decodeFieldValue(String value)
{
if(value == null) return(null);
if(SZ_NULL_AS_SQLNULL.equals(value)) return(null);
if(SZ_NULL_AS_STRING.equals(value)) return(SZ_NULL_AS_SQLNULL);
return(wam.translate_tokens(value,new String[]{"\r"},new String[]{""}));
}


public String mkFieldInputHidden(String fname, String fvalue)
{
 StringBuffer sb = new StringBuffer();
 sb.append("<input type='hidden'");
 sb.append(" name='"); sb.append(mkFName(fname)); sb.append("'");
 sb.append(" value='"); sb.append(encodeFieldValue(fvalue)); sb.append("'");
 sb.append(">");
 return(sb.toString());
} // mkFieldInputHidden(String fname, String fvalue)

public String mkFieldInputCheckbox(String fname, boolean fvalue)
{
 StringBuffer sb = new StringBuffer();
 sb.append("<input type='checkbox'");
 sb.append(" name='"); sb.append(mkFName(fname)); sb.append("'");
 sb.append(" value='Y'");
 if(fvalue) sb.append(" CHECKED ");
 sb.append(">");
 return(sb.toString());
} // mkFieldInputHidden(String fname, String fvalue)

public String mkFieldInputText(String fname, String fvalue, int size, int maxlength)
{
 StringBuffer sb = new StringBuffer();
 if(size<=0 || size>72) size=72;
 if(maxlength<size && maxlength > 0) size=maxlength;
 if(maxlength<4 && maxlength>0) maxlength=4; // this is for SQL NULL encoding as null
 if(maxlength<6 && maxlength>=4) maxlength=6; // ... for encoding null as "null"
 sb.append("<input type='text'");
 sb.append(" size='" + size + "'");
 if(maxlength > 0) sb.append(" maxmaxlength='" + maxlength + "'");
 sb.append(" name='"); sb.append(mkFName(fname)); sb.append("'");
 sb.append(" id='"); sb.append(mkFName(fname)); sb.append("'"); //SIC! добавлено для edit-qr
 sb.append(" value='"); sb.append(encodeFieldValue(fvalue)); sb.append("'");
 sb.append(">");
 return(sb.toString());
} // mkFieldInputText(String fname, String fvalue, int size, int maxlength)


    private void printTableUpsideString(String optionalParam, Object... outputString) throws Exception {
        beginTRow();
        if(!(optionalParam.equals("") | optionalParam == null | optionalParam.equals("null")))
            printCell(optionalParam);
        for (int i = 0; i < outputString.length; i++) {
            printCell(outputString[i]);
        }
        endTRow();
    }

    private void beginTCell() { beginTCell(0);}
    private void beginTCell( int colspan) { if(colspan<=0) wln("<td>"); else {wln("<td colspan='" + colspan + "'>");} }

    private void endTCell() { wln("</td>"); }

    private void beginTRow() { wln("<tr>"); }

    private void endTRow() { wln("</tr>"); }

    private void beginT() { w("<table>"); }

    private void endT() { wln("</table>"); }

    private void printCell(Object tElement) {printCellRaw(t2h(o2t(tElement)));}
    private void printCell(Object tElement,int colspan) {printCellRaw(t2h(o2t(tElement)),colspan);}
    private void printCellRaw(Object tElement) { printCellRaw(tElement,0);}
    private void printCellRaw(Object tElement,int colspan) {
        beginTCell(colspan);
        wln(obj2str(tElement));
        endTCell();
    }
    public void printCellCardTools(String member, String range, Long ZRID) 
    {
      printCellRaw("<a href=\'" + getRequestParamsURL(CGI_NAME, CMD_PRODVIEW, member, range, ZRID.toString()) + "\'>" +
                            "&lt;карточка&gt;" + "</a>"); //SIC! а вообще, надо делать немного по-другому
	// +"<br/>"+ "<input type=\"button\"value=\"Удалить\" onclick=\"allertToDeleteRecord()\">");
    }

    private void printTRow(Object[] data) throws Exception {
        beginTRow();
        for (int i = 0; i < data.length; i++) {
            printCellRaw(data[i]); // SIC! Raw
        }
        endTRow();
    }

    //
    // Tools/Utils section
    //

// imported from ConcepTIS ru.mave.ConcepTIS.WASkin
//

public static MsgContract WAMessages = null; // helpful for using ConcepTIS WAMessages static methods by imported methods
public static MsgContract wam = null; // helpful for using ConcepTIS WAMessages static methods by imported methods
public boolean is_error =false;
public Exception last_exception = null;

private void w(String s)
{
 is_error=false;
 try{out.print(s);}
 catch(Exception e)
  {is_error=true;last_exception=e;}
} // w(String s)
private void wln(String s){w(s);w("\n");}
private void wln(){w("\n");}

public void print(String s){w(t2h(s));}
public void println(String s){w(t2h(s));wln("<br>");}
public void println(){wln("<br>");}
/** obj2html */
private static String t2h(String s){return(WAMessages.obj2html(s));}
/** obj2value */
private static String o2v(Object o){return(WAMessages.obj2value(o));}
/** obj2urlvalue (WARNING: must be rewritten) */
private static String o2uv(Object o){return(WAMessages.obj2value(o));}
/** obj2text */
private static String o2t(Object o){return(WAMessages.obj2text(o));}
/** obj2string */
private static String o2s(Object o){return(WAMessages.obj2string(o));}



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

//    public void println() throws Exception { out.println("<br/>"); }
    private boolean nodebug_enabled=false;
    public void nodebug_log(String msg, Exception e) {if(nodebug_enabled) debug_log(msg,e);} // SIC! заглушка, но можно сделать включаемо, сделал
    public void debug_log(String msg, Exception e)
    {
     System.err.println(msg); //SIC! собрать побольше инфы о текущем контексте
     if(e!=null) { System.err.println(e.toString()); } //SIC! потом улучшить (стек вызовов можно распечатать
    }
    public void nodebug_log(String msg) { if(nodebug_enabled) debug_log(msg,null); }
    public void debug_log(String msg) { debug_log(msg,null); }
    public void printex(Exception e){String msg= "Exception!" + e.toString(); debug_log(msg); printerr(msg);} //SIC! потом переделать это и ниже
    public void printerr(String msg) { w("<b>" + t2h(msg) + "</b>"); }
    public void printerrln(String msg) throws Exception { printerr(msg); println(); }

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

    public void sendAllert(String msg) throws Exception { // SIC! Ну не надо так!
       
        wln("<script type=\"text/javascript\">");
        wln("alert('" + msg + "');");
        wln("</script>");
    }

    private boolean checkNewRecord(ZCSVRow rowToCheck) throws Exception { //SIC! не понял, вернуться позднее
        int ZRID = Integer.parseInt(rowToCheck.get(0));
        ZCSVRow row;
        if(zcsvFile != null) {
            try {
                row = zcsvFile.getRowObjectByIndex(ZRID - 1);
                if(row.getNames() == null)
                    row.setNames(namesMap);
            } catch (IndexOutOfBoundsException | NullPointerException ex) {
                return true;
            }

            for (int i = getCSVHeaderLength(); i < row.getNames().length; i++) {
                String s1 = rowToCheck.get(i).toString();
                String s2 = row.get(i).toString();
                if (!s1.equals(s2)) {
                    return true;
                }
            }
        }
        return false;
    }

    private boolean checkForCorrectness(HttpServletRequest request) throws Exception { // SIC! это QC? это не так надо, не request
        String bufferParameter = new String();
        boolean answer = true;
        for (Integer i = getCSVHeaderLength(); i < namesMap.length; i++) {
            bufferParameter = request.getParameter(REC_PREFIX + i);
            if(i == getQRFieldIndex())
                if(bufferParameter.startsWith(request.getParameter(PARAM_RANGE)));
                    answer = false;
        }
        return answer;
    }

    private String genNewQr(String p_range)  {
        long maxQR = 0;
	    if(getQRFieldIndex()<0) return(""); // if no QR-code field
        for(int i = 0;i<zcsvFile.getFileRowsLength();i++){
           String QR = "";
           try{QR= zcsvFile.getRowObjectByIndex(i).get(getQRFieldIndex()); }catch (ZCSVException e){} //SIC! get QR-code
	   // if(QR not in range) continue; // check for range
	   if(QR==null) continue;
	   if(QR.equals("")) continue;
	   long lQR=0;
           if(QR.length()>p_range.length()){ //SIC! иначе java.lang.StringIndexOutOfBoundsException: String index out of range: -1
	   try{lQR=Long.parseLong(QR.substring(p_range.length()), 16);}catch (NumberFormatException nfe){} // ignore NFE
           }
           if(lQR > maxQR) maxQR = lQR;
        }
        maxQR++;
        return String.format("%s%03X",p_range, maxQR);
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
    initJSPGlobals();
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
    	loadConfig4Range(p_member, p_range);

        switch (CMD) {
            case CMD_MEMBERS: setMembersPage(); break;
            case CMD_RANGES: setRangesPage(p_member); break;
            case CMD_PRODTABLE: setProductsPage(p_member, p_range);  break;
            case CMD_CHANGE_CONFIG: setChangeConfigPage(p_member, p_range); break;
            case CMD_PRODVIEW: loadZCSVFile4Range(p_member,p_range); setProdViewPage(p_member, p_range, p_ZRID); break;
            case CMD_UPDATE: loadZCSVFile4Range(p_member,p_range); setActions(p_member, p_range, p_ZRID, p_action, request, response); break;
            case CMD_TEST: wln("Hello test page!<br>");
            case CMD_TESTTAB: wln("<pre>"); w(makeDefaultQRCSVConf()); wln("</pre>"); break;
            default: response.sendRedirect(CGI_NAME); break;
        }
    } catch (IOException ex) {
        if (ex.getMessage() != null && !(SZ_NULL.equals(ex.getMessage())))
            System.err.println("IOException:" + ex.getMessage() + "Call the system administrator please.");
        else
            wln("IO unexpected error occered! Call the system administrator please.");
    } catch (ZCSVException ex) {
        if (ex.getMessage() != null && !(SZ_NULL.equals(ex.getMessage())))
            wln(ex.printError() + "Call the system administrator please.");
        else
            wln("ZCSV unexpected error occered! Call the system administrator please.");
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
