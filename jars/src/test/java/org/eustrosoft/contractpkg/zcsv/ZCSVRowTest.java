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

    private static String []nameMap = {"Название","ZRID","ZVER","ZDATE","ZUID","ZSTA","QR код",
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
    }

    @Test
    public void get() {
    }

    @Test
    public void testGet() {
    }

    @Test
    public void name2column() {
    }

    @Test
    public void isDirty() {
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
