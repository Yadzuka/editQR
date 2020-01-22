package org.eustrosoft.contractpkg.zcsv;

import org.eustrosoft.contractpkg.Model.Members;
import org.junit.Assert;
import org.junit.Test;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

public class zcsvFileTest {

    @Test
    public void setPath() {
        ZCSVFile testingFile = new ZCSVFile();
        testingFile.setRootPath("/s/qrdb/EXAMPLESD/members/EXAMPLESD/0100D/");
        testingFile.setFileName("master.list");
        Assert.assertTrue(Files.exists(Paths.get(testingFile.toString())));
    }

    @Test
    public void getFileRowsLength() throws IOException {
        ZCSVFile testingFile = new ZCSVFile();
        testingFile.setRootPath("/s/qrdb/EXAMPLESD/members/EXAMPLESD/0100D/");
        testingFile.setFileName("master.list");

        int stringsCounter = 0;
        String buffer;
        try {
            BufferedReader reader = new BufferedReader
                    (new InputStreamReader
                            (new FileInputStream("/s/qrdb/EXAMPLESD/members/EXAMPLESD/0100D/master.list.csv")
                                    , StandardCharsets.UTF_8));
            while((buffer = reader.readLine()) != null){
                if(buffer.startsWith("#") || buffer.trim().equals(""))
                    continue;
                stringsCounter++;
            }
            reader.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        testingFile.tryOpenFile(0);
        testingFile.loadFromFile();
        testingFile.closeFile();
        Assert.assertEquals(stringsCounter, testingFile.getFileRowsLength());
    }

    @Test
    public void closeFileRightly() throws IOException {
        ZCSVFile testingFile = new ZCSVFile();
        testingFile.setRootPath("/s/qrdb/EXAMPLESD/members/EXAMPLESD/0100D/");
        testingFile.setFileName("master.list");
        testingFile.tryOpenFile(0);
        Assert.assertTrue(testingFile.closeFile());
    }

    @Test
    public void closeFileIncorrectly() throws IOException {
        ZCSVFile testingFile = new ZCSVFile();
        testingFile.setRootPath("/s/qrdb/EXAMPLESD/members/EXAMPLESD/0100D/");
        testingFile.setFileName("master.list");
        Assert.assertFalse(testingFile.closeFile());
    }

    @Test
    public void loadFromFileRightly() throws IOException {
        ZCSVFile testingFile = new ZCSVFile();
        testingFile.setRootPath("/s/qrdb/EXAMPLESD/members/EXAMPLESD/0100D/");
        testingFile.setFileName("master.list");
        testingFile.tryOpenFile(0);
        testingFile.loadFromFile();

        String buffer;
        BufferedReader reader = new BufferedReader
                (new InputStreamReader
                        (new FileInputStream("/s/qrdb/EXAMPLESD/members/EXAMPLESD/0100D/master.list.csv")
                                , StandardCharsets.UTF_8));
        while((buffer = reader.readLine()) != null){
            if(!buffer.startsWith("#"))
                break;
        }
        ZCSVRow testingRow = testingFile.getRowObjectByIndex(0);
        reader.close();
        testingFile.closeFile();
        Assert.assertEquals(buffer, testingRow.toString());
    }

    @Test
    public void tryAppendNewStringsToFileWhenClosed() throws IOException {
        ZCSVFile testingFile = new ZCSVFile();
        testingFile.setRootPath("/s/qrdb/EXAMPLESD/members/EXAMPLESD/0100D/");
        testingFile.setFileName("master.list");
        testingFile.tryOpenFile(0);
        BufferedWriter writer = new BufferedWriter
                (new OutputStreamWriter
                        (new FileOutputStream("/s/qrdb/EXAMPLESD/members/EXAMPLESD/0100D/master.list.csv",true)
                                , StandardCharsets.UTF_8));
        try{
            testingFile.tryFileLock();
            writer.write("CSDSD");
        }
        catch (Exception ex){
                Assert.assertTrue(true);
        }finally{
            if(writer != null) writer.close();
            testingFile.closeFile();
        }
    }

    @Test
    public void getLineByIndex() throws FileNotFoundException {
        ZCSVFile testingFile = new ZCSVFile();
        testingFile.setRootPath("/s/qrdb/EXAMPLESD/members/EXAMPLESD/0100D/");
        testingFile.setFileName("master.list");
        testingFile.tryOpenFile(0);

        BufferedReader reader = new BufferedReader
                (new InputStreamReader
                        (new FileInputStream("/s/qrdb/EXAMPLESD/members/EXAMPLESD/0100D/master.list.csv")
                                , StandardCharsets.UTF_8));

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
