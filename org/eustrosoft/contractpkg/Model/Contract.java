package org.eustrosoft.contractpkg.Model;


import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;

/*
	Class witch contains all of needed to DOMINATOR company parameters
 */
public class Contract {

    // Global parameters for initialize form
    String[] productProperties;
    BufferedReader reader;
    String pathToDBFile;

    public static Contract InitNewRecordInDB(String comingString, char splitter,String ZOID, String ZVER,
			String ZUID, String ZSTA){
	    return new Contract(comingString, splitter,ZOID, ZVER,
				ZUID, ZSTA);
    }

    // Private constructors to init class inside
    public Contract(){
    	pathToDBFile = Members.getWayToDB() + "/EXAMPLESD/0100D/master.list.csv";
    	setProductPropertiesLength(pathToDBFile);
	}

    private Contract(String inputStringToDB,char splitter,String ZOID, String ZVER,
			String ZUID, String ZSTA){
        this();
        splitComingString(inputStringToDB,splitter,ZOID,ZVER,
    			ZUID,ZSTA);
    }

    private Contract(String[] initialProps){
    	this();
    	readFromDBFile(initialProps);
    	matchPropertiesWithMassive(productProperties);
	}

	private Contract(String[] str, String pathToFile) {
    	this();
		setProductPropertiesLength(pathToFile);
	}

    private Contract(String pathToFile) {
    	this();
        setProductPropertiesLength(pathToFile);
    }

    // Get length of parameters || MAY BE USED TO INITIALIZE ANOTHER DB || (FUTURE)
    private void setProductPropertiesLength(String pathToDBFile) {
        String sBufferToGetProps;
        int finalLengthOfProps = 0;
        try {
            reader = new BufferedReader(new InputStreamReader(new FileInputStream(pathToDBFile),
                                                            StandardCharsets.UTF_8)/*new FileReader(pathToDBFile)*/);
            if ((sBufferToGetProps = reader.readLine()) != null)
                finalLengthOfProps = sBufferToGetProps.split(";").length;
            productProperties = new String[finalLengthOfProps];
        } catch (IOException ex) {
            ex.printStackTrace();
        }finally {
        	try{
        	    reader.close();
        	}catch (IOException ex){
        		ex.printStackTrace();
			}
		}
    }

    // Fill starting array list with existing records in file
    public ArrayList<Contract> fillProductPropertiesInStart() 
    		throws NumberFormatException, IOException {
        ArrayList<Contract> startingList = new ArrayList<>();

		try {
			reader = new BufferedReader(new InputStreamReader(new FileInputStream(pathToDBFile),
                                        StandardCharsets.UTF_8));
			String stringForLine = "";
			while ((stringForLine = reader.readLine()) != null && !"".trim().equals(stringForLine)) {
				if (stringForLine.startsWith("#") || startingList.equals(""))
					continue;
				else {
					startingList.add(new Contract(stringForLine.split(";")));
				}
			}
			return startingList;
		}
        finally {
			try{
				reader.close();
			}catch (IOException ex){
				ex.printStackTrace();
			}
		}
    }

    private void readFromDBFile(String [] props){
    	if(props.length > productProperties.length) {
			System.out.println("Properties length is more than product properties length!");
			return;
		}
    	for(int i=0;i<props.length;i++){
    		productProperties[i] = props[i];
		}
	}

	private void splitComingString(String comingString, char splitter,String ZOID, String ZVER,
			String ZUID, String ZSTA){
	    String [] bufferForSplitterString = comingString.split(String.valueOf(splitter));

	    for(int i=0;i< bufferForSplitterString.length ;i++)
	        productProperties[i+5] = bufferForSplitterString[i];
	    
	    productProperties[0] = ZOID;
	    productProperties[1] = ZVER;
	    productProperties[2] = new Date().toString();
	    productProperties[3] = ZUID;
	    productProperties[4] = ZSTA;
	    
	    matchPropertiesWithMassive(productProperties);
	    createRecordInDB(comingString);
    }

	private void matchPropertiesWithMassive(String [] productProperties) {
        ZOID = productProperties[0];
        ZVER = productProperties[1];
        ZDATE = productProperties[2];
        ZUID = productProperties[3];
        ZSTA = productProperties[4];
        QR = productProperties[5];
        CONTRACTNUM = productProperties[6];
        contractdate = productProperties[7];
        MONEY = productProperties[8];
        SUPPLIER = productProperties[9];
        CLIENT = productProperties[10];
        PRODTYPE = productProperties[11];
        MODEL = productProperties[12];
        SN = productProperties[13];
        prodate = productProperties[14];
        shipdate = productProperties[15];
        SALEDATE = productProperties[16];
        DEPARTUREDATE = productProperties[17];
        WARRANTYSTART = productProperties[18];
        WARRANTYEND = productProperties[19];
        COMMENT = productProperties[20];
	}
	
	public void createRecordInDB(String stringToWrite) {
		try {
            BufferedWriter writter = new BufferedWriter
                    (new OutputStreamWriter(new FileOutputStream(pathToDBFile,true),StandardCharsets.UTF_8));
           // PrintWriter db = new PrintWriter(new BufferedWriter
            //        (new FileWriter(pathToDBFile, StandardCharsets.UTF_8,true)));
			//PrintWriter db = new PrintWriter(new BufferedWriter(new FileWriter(pathToDBFile, true)));
			try(BufferedWriter out = writter){ out.write(stringToWrite+"\n"); out.flush(); }
		} catch (IOException e) {
		    System.err.println(e);
		}
		 // ? {try {o; }catch(e) {} finally {o.close();} } try {
	}

    ////////////////////////
    //       TIS          //
    ////////////////////////

    private String ZOID;
    private String ZVER;
    private String ZDATE;
    private String ZUID;
    private String ZSTA;

    ////////////////////////
    //       Model        //
    ////////////////////////

    private String QR;
    private String CONTRACTNUM;
    private String contractdate;
    private String MONEY;
    private String SUPPLIER;
    private String CLIENT;
    private String PRODTYPE;
    private String MODEL;
    private String SN;
    private String prodate;
    private String shipdate;
    private String SALEDATE;
    private String DEPARTUREDATE;
    private String WARRANTYSTART;
    private String WARRANTYEND;
    private String COMMENT;

    ////////////////////////

    // QR Number in db
    public String getQr()
    {
        if("null".equals(QR) || QR == null)
            return "";
        else
            return QR;
    }

    public void setQr(String qr) {
        this.QR = qr;
    }

    // Contract reference
    public String getContractum() {
        if("null".equals(CONTRACTNUM) || CONTRACTNUM == null)
            return "";
        else
            return CONTRACTNUM;
    }
    
    public void setContractum(String contract) {
    	this.CONTRACTNUM = contract;
    }

    //  Contract date
    public String getContractdate()
    {
        if("null".equals(contractdate) || contractdate == null)
            return "";
        else
            return contractdate;
    }

    public void setContractdate(String contractdate) {
        this.contractdate = contractdate;
    }

    // Count of money
    public String getMoney()
    {
        if("null".equals(MONEY) || MONEY == null)
            return "";
        else
            return MONEY;
    }

    public void setMoney(String money) {
        this.MONEY = money;
    }

    //  Supplier
    public String getSUPPLIER() {
        if("null".equals(SUPPLIER) || SUPPLIER == null)
            return "";
        else
            return SUPPLIER;
    }

    public void setSUPPLIER(String sUPPLIER) {
        SUPPLIER = sUPPLIER;
    }

    //  Client
    public String getCLIENT()
    {
        if("null".equals(CLIENT) || CLIENT == null)
            return "";
        else
            return CLIENT;
    }

    public void setCLIENT(String cLIENT) {
        CLIENT = cLIENT;
    }

    //  Product type
    public String getPRODTYPE() {

        if("null".equals(PRODTYPE) || PRODTYPE == null)
            return "";
        else
            return PRODTYPE;
    }

    public void setPRODTYPE(String pRODTYPE) {
        PRODTYPE = pRODTYPE;
    }

    //  Model
    public String getMODEL() {

        if("null".equals(MODEL) || MODEL == null)
            return "";
        else
            return MODEL;
    }

    public void setMODEL(String mODEL) {
        MODEL = mODEL;
    }

    //  Serial number
    public String getSN() {

        if("null".equals(SN) || SN == null)
            return "";
        else
            return SN;
    }

    public void setSN(String sN) {
        SN = sN;
    }

    //  Product date
    public String getProdate() {

        if("null".equals(prodate) || prodate == null)
            return "";
        else
            return prodate;
    }

    public void setProdate(String prodate) {
        this.prodate = prodate;
    }

    //  Ship/Delivery date
    public String getShipdate()
    {
        if("null".equals(shipdate) || shipdate == null)
            return "";
        else
            return shipdate;
    }

    public void setShipdate(String shipdate) {
        this.shipdate = shipdate;
    }

    //  Sale date
    public String getSALEDATE()
    {
        if("null".equals(SALEDATE) || SALEDATE == null)
            return "";
        else
            return SALEDATE;
    }

    public void setSALEDATE(String sALEDATE) {
        SALEDATE = sALEDATE;
    }

    // Departure date
    public String getDEPARTUREDATE()
    {
        if("null".equals(DEPARTUREDATE) || DEPARTUREDATE == null)
            return "";
        else
            return DEPARTUREDATE;
    }

    public void setDEPARTUREDATE(String dEPARTUREDATE) {
        DEPARTUREDATE = dEPARTUREDATE;
    }

    //  Warranty period start
    public String getWARRANTYSTART()
    {
        if("null".equals(WARRANTYSTART) || WARRANTYSTART == null)
            return "";
        else
            return WARRANTYSTART;
    }

    public void setWARRANTYSTART(String wARRANTYSTART) {
        WARRANTYSTART = wARRANTYSTART;
    }

    // Warranty period end
    public String getWARRANTYEND()
    {
        if("null".equals(WARRANTYEND) || WARRANTYEND == null)
            return "";
        else
            return WARRANTYEND;
    }

    public void setWARRANTYEND(String wARRANTYEND) {
        WARRANTYEND = wARRANTYEND;
    }

    //  Commentary to deal
    public String getCOMMENT()
    {
        if("null".equals(COMMENT) || COMMENT == null)
            return "";
        else
            return COMMENT;
    }

    public void setCOMMENT(String cOMMENT) {
        COMMENT = cOMMENT;
    }

    @Override
    public String toString() {
        return ZOID+";"+ZVER+";"+ZDATE+";"+ZUID+";"
        +ZSTA+";"+QR+";"+CONTRACTNUM+";"+contractdate+";"+MONEY+";"
        +SUPPLIER+";"+CLIENT+";"+PRODTYPE+";"+MODEL+";"+SN+";"+prodate+";"
        +shipdate+";"+SALEDATE+";"+DEPARTUREDATE+";"
        +WARRANTYSTART+";"+WARRANTYEND+";"+COMMENT;
    }

    ////////////////////////////////
    //            TIS             //
    ////////////////////////////////

    public String getZOID() {
        return ZOID;
    }

    public String getZVER() {
        return ZVER;
    }

    public String getZDATE() {
        return ZDATE;
    }

    public String getZSTA() {
        return ZSTA;
    }

    public String getZUID() {
        return ZUID;
    }

    public void setZOID(String ZOID) {
        this.ZOID = ZOID;
    }

    public void setZVER(String ZVER) {
        this.ZVER= ZVER ;
    }

    public void setZDATE(String ZDATE) {
        this.ZDATE = ZDATE;
    }

    public void setZSTA(String ZSTA) {
        this.ZSTA= ZSTA ;
    }

    public void setZUID(String ZUID) {
        this.ZUID = ZUID;
    }
    ////////////////////////////////

}
