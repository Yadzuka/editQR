package org.eustrosoft.contractpkg.zcsv;

import org.eustrosoft.contractpkg.Model.Members;
import org.junit.Assert;
import org.junit.Test;

public class zcsvFileTest {

    @Test
    public void testFile(){
        Members.setWayToDB("/s/qrdb/EXAMPLESD/members/");
        ZCSVFile zcsvFile = new ZCSVFile();
        zcsvFile.setRootPath(Members.getWayToDB()+"EXAMPLESD/0100D/");
        zcsvFile.setFileName("master.list");
        String [] namesMap = new String[]
                {"ZOID","ZVER","ZDATE","ZUID","ZSTA","QR","CONTRACTNUM", "contractdate",
                        "MONEY","SUPPLIER","CLIENT","PRODTYPE","MODEL","SN","prodate","shipdate",
                        "SALEDATE","DEPARTUREDATE","WARRANTYSTART","WARRANTYEND","COMMENT "};

        boolean res = zcsvFile.tryOpenFile(1);
        System.out.println("Exists");
        if (res) {
            zcsvFile.loadFromFileValidVersions();
            System.out.println(zcsvFile.getFileRowsLength());
            for (int i = 0; i < zcsvFile.getFileRowsLength(); i++) {
                ZCSVRow eachRow = zcsvFile.getRowObjectByIndex(i);
                eachRow.setNames(namesMap);
                for(int j = 0; j < eachRow.getNames().length; j++){
                    System.out.print(eachRow.get(j) + " ");
                }
                System.out.println();
            }
        } else {
            System.out.println("can't open file");
        }


        ZCSVRow row = zcsvFile.getRowObjectByIndex(1);
        System.out.println(row.toString());

        Assert.assertTrue(true);
    }
}
