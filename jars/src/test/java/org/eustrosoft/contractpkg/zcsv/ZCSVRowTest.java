package org.eustrosoft.contractpkg.zcsv;

import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.*;

public class ZCSVRowTest {
    public static final String DEFAULT_TESTDB_ROOT="./src/test/resources/";
    public static final String TESTINGDATA_CSV="testingData.csv";
    public static String getTestDBFileName(String file_name){ return(DEFAULT_TESTDB_ROOT + file_name); }
    public static String getTestDBFileName(){return(getTestDBFileName("")); }

    private static String []nameMap = { "ZRID","ZVER","ZDATE","ZUID","ZSTA","QR код",
            "№ договора","Дата договора","Деньги по договору","Юр-лицо поставщик",
            "Юр-лицо клиент","Тип продукта","Модель продукта","SN","Дата производства","Дата ввода (ГТД)",
            "Дата продажи","Дата отправки клиенту","Дата начала гарантии","Дата окончания гарантии","Комментарий (для клиента)"};

    @Test
    public void setStringSpecificIndex() {
        try {
            ZCSVFile zcsvFile = new ZCSVFile();
            zcsvFile.setRootPath(DEFAULT_TESTDB_ROOT);
            zcsvFile.setFileName(TESTINGDATA_CSV);
            zcsvFile.loadFromFileValidVersions();

            ZCSVRow row = zcsvFile.getRowObjectByIndex(0);
            row.setNames(nameMap);
            row.setStringSpecificIndex(5, "Hello World!");
            Assert.assertTrue(zcsvFile.getRowObjectByIndex(0).get(5).equals("Hello World!"));
        }catch (Exception ex){
            ex.printStackTrace();
        }

    }

    @Test
    public void setNewName() {
        ZCSVRow newRow = new ZCSVRow();
        newRow.setNames(nameMap);
        boolean flag = true;
        for(int i = 0; i < nameMap.length; i++){
            if(!nameMap[i].equals(newRow.getNames()[i]))
                flag = false;
        }
        Assert.assertTrue(flag);
    }

    @Test
    public void get() throws ZCSVException {
        ZCSVRow row = new ZCSVRow(new String("1234abcd;4321rewq;"));
        row.setNames(new String[]{"1","2"});

        Assert.assertTrue("4321rewq".equals(row.get(1)) & "4321rewq".equals(row.get("2")));
    }

    /*@Test
    public void name2column(String s) {
        ZCSVRow row = new ZCSVRow();
        row.setNames(nameMap);

        Assert.assertTrue(nameMap[20].equals(row.getNames()[row.name2column("Комментарий (для клиента)")]));
    }*/

    @Test
    public void isDirty() throws Exception {
        ZCSVFile zcsvFile = new ZCSVFile();
        zcsvFile.setRootPath(DEFAULT_TESTDB_ROOT);
        zcsvFile.setFileName(TESTINGDATA_CSV);
        zcsvFile.loadFromFileValidVersions();

        ZCSVRow row = zcsvFile.getRowObjectByIndex(0);
        row.setNames(nameMap);
        row.setStringSpecificIndex(2, "New string");

        Assert.assertTrue(row.isDirty());
    }

    @Test
    public void setRow() {
    }

    @Test
    public void isRow() {
    }

    @Test
    public void setPrevious() {
    }

    @Test
    public void getPrevious() {
    }

    @Test
    public void setNames() {
    }

    @Test
    public void getNames() {
    }

    @Test
    public void testToString() {
    }
}
