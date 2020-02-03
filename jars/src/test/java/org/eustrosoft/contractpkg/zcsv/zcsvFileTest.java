package org.eustrosoft.contractpkg.zcsv;

import org.eustrosoft.contractpkg.Model.Members;
import org.junit.Assert;
import org.junit.Test;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;

public class zcsvFileTest {
    //public static final String DEFAULT_TESTDB_ROOT="/s/proj/yadzuka/edit.qr.qxyz.ru/jars/src/test/resources/";
    public static final String DEFAULT_TESTDB_ROOT="./src/test/resources/";
    public static final String TESTINGDATA_CSV="testingData.csv";
    public static String getTestDBFileName(String file_name){ return(DEFAULT_TESTDB_ROOT + file_name); }
    public static String getTestDBFileName(){return(getTestDBFileName("")); }

    @Test
    public void setPathTest() {
        ZCSVFile testingFile = new ZCSVFile();
        testingFile.setRootPath(getTestDBFileName());
        testingFile.setFileName(TESTINGDATA_CSV);
        Assert.assertTrue(Files.exists(Paths.get(testingFile.toString())));
    }

    @Test
    public void getFileRowsLengthTest() throws Exception {
        ZCSVFile testingFile = new ZCSVFile();
        testingFile.setRootPath(getTestDBFileName());
        testingFile.setFileName(TESTINGDATA_CSV);
        int stringsCounter = 0;
        String buffer;
        try {
            BufferedReader reader = new BufferedReader
                    (new InputStreamReader
                            (new FileInputStream(getTestDBFileName(TESTINGDATA_CSV))
                                    , StandardCharsets.UTF_8));
            while((buffer = reader.readLine()) != null){
                if(buffer.startsWith("#") || buffer.trim().equals(""))
                    continue;
                stringsCounter++;
            }
            reader.close();
        testingFile.tryOpenFile(0);
        testingFile.loadFromFile();
        testingFile.closeFile();
        } catch (IOException e) {
            e.printStackTrace();
            Assert.fail();
        }
        Assert.assertEquals(stringsCounter, testingFile.getFileRowsLength());
    }

    @Test
    public void closeFileRightlyTest() throws Exception{
        ZCSVFile testingFile = new ZCSVFile();
        testingFile.setRootPath(getTestDBFileName());
        testingFile.setFileName(TESTINGDATA_CSV);
        testingFile.tryOpenFile(0);
        try {
            Assert.assertTrue(testingFile.closeFile());
        }catch (Exception ex){
            ex.printStackTrace();
            Assert.fail();
        }
    }

    @Test
    public void closeFileIncorrectlyTest() {
        ZCSVFile testingFile = new ZCSVFile();
        testingFile.setRootPath(getTestDBFileName());
        testingFile.setFileName(TESTINGDATA_CSV);
        try {
            Assert.assertFalse(testingFile.closeFile());
        }catch (Exception ex){
            ex.printStackTrace();
            Assert.fail();
        }
    }

    @Test
    public void loadFromFileRightlyTest() throws Exception{
        ZCSVFile testingFile = new ZCSVFile();
        testingFile.setRootPath(getTestDBFileName());
        testingFile.setFileName(TESTINGDATA_CSV);
        testingFile.tryOpenFile(0);
        testingFile.loadFromFile();
        String buffer = null, testingRow = null;
        try {
            BufferedReader reader = new BufferedReader
                    (new InputStreamReader
                            (new FileInputStream(getTestDBFileName(TESTINGDATA_CSV))
                                    , StandardCharsets.UTF_8));
            while ((buffer = reader.readLine()) != null) {
                if (!buffer.startsWith("#"))
                    break;
            }
            testingRow = testingFile.getLineByIndex(0);
            reader.close();
            testingFile.closeFile();
        }catch (Exception ex){
            ex.printStackTrace();
            Assert.fail();
        }finally {
            Assert.assertEquals(buffer, testingRow);
        }
    }

    @Test
    public void tryAppendNewStringsToFileWhenClosedTetst() {
        ZCSVFile testingFile = new ZCSVFile();
        testingFile.setRootPath(getTestDBFileName());
        testingFile.setFileName(TESTINGDATA_CSV);
        BufferedWriter writer = null;
        try{
        testingFile.tryOpenFile(0);
        writer = new BufferedWriter
                (new OutputStreamWriter
                        (new FileOutputStream(getTestDBFileName(TESTINGDATA_CSV),true)
                                , StandardCharsets.UTF_8));
            testingFile.tryFileLock();
            writer.write("CSDSD");
        }
        catch (Exception ex){
                Assert.assertTrue(true);
        }finally{
            try {
                if (writer != null) writer.close();
                testingFile.closeFile();
            }catch (Exception ex){
                ex.printStackTrace();
            }
        }
    }

    @Test
    public void getRawObjectByIndexTest() {
        ZCSVFile testingFile = new ZCSVFile();
        testingFile.setRootPath(getTestDBFileName());
        testingFile.setFileName(TESTINGDATA_CSV);
        try {
            testingFile.tryOpenFile(0);
            testingFile.loadFromFileValidVersions();
            BufferedReader reader = new BufferedReader
                    (new InputStreamReader
                            (new FileInputStream(getTestDBFileName(TESTINGDATA_CSV))
                                    , StandardCharsets.UTF_8));

            ZCSVRow row = testingFile.getRowObjectByIndex(0);
            for(int i=0;i<testingFile.getFileRowsLength();i++)
                System.out.println(testingFile.getRowObjectByIndex(i));
            Assert.assertTrue
                    (("1;5;Fri Jan 03 04:07:46 MSK 2020;null;N;0100D001;ds2010-01;" +
                    "2010-01-01;MONEY;ООО Доминатор;Alexey(boatclub.ru);TDME;490;SN-012344;" +
                    "2009-12-05 China;2010-05-16 SPB;2010-05-21 MSK;2010-05-21 depa;2010-05-21 WSTART;" +
                    "2011-05-21 WEND;MA125,3:1,гидравлический").equals(row.toString()));
        }catch (Exception ex){
            ex.printStackTrace();
            Assert.fail();
        }finally {
            try {
                testingFile.closeFile();
            }catch (Exception ex){
                ex.printStackTrace();
                Assert.fail();
            }
        }
    }

   /* @Test
    public void rewriteAllFile() {
        ArrayList listOfStrings = new ArrayList();
        ZCSVFile testingFile = new ZCSVFile();
        ZCSVRow row;
        try {
            testingFile.setRootPath(getTestDBFileName());
            testingFile.setFileName("testingData");
            testingFile.tryOpenFile(1);
            testingFile.loadFromFile();
            testingFile.tryFileLock();
            for(int i = 0; i < testingFile.getFileRowsLength(); i++){
                row = testingFile.getRowObjectByIndex(i);
                listOfStrings.add(row);
            }
            testingFile.rewriteAllFile();
            /*for(int i = 0; i < listOfStrings.size(); i++){
                if()
            }
        }catch (Exception ex){
            ex.printStackTrace();
            Assert.fail();
        }finally {
            try {
                testingFile.closeFile();
                Assert.assertTrue(true);
            }catch (Exception ex){
                ex.printStackTrace();
                Assert.fail();
            }
        }
    }*/

    @Test
    public void testGetFileRowsLength() {
    }

    @Test
    public void tryOpenFile() {
    }

    @Test
    public void tryFileLock() {
    }

    @Test
    public void closeFile() {
    }

    @Test
    public void loadFromFile() {
    }

    @Test
    public void loadFromFileValidVersions() {
    }

    @Test
    public void reloadFromFile() {
    }

    @Test
    public void updateFromChannel() {
    }

    @Test
    public void testRewriteAllFile() {
    }

    @Test
    public void testGetLineByIndex() {
    }

    @Test
    public void appendNewStringsToFile() {
    }

    @Test
    public void writeNewFile() {
    }

    @Test
    public void rewriteFile() {
    }

    @Test
    public void getRowObjectByIndex() {
    }

    @Test
    public void editRowObjectByIndex() {
    }

    @Test
    public void testToString() {
    }
}
