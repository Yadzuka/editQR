package org.eustrosoft.contractpkg;

import org.eustrosoft.contractpkg.Controller.ControllerContracts;
import org.eustrosoft.contractpkg.Model.Members;
import org.eustrosoft.contractpkg.zcsv.ZCSVFile;
import org.eustrosoft.contractpkg.zcsv.ZCSVRow;

import java.io.IOException;
import java.lang.reflect.Member;
import java.nio.file.Files;
import java.nio.file.Paths;

class TestingClass {
    public static void main(String[] args) throws IOException {
        Members.setWayToDB("/s/qrdb/EXAMPLESD/members/");
        ZCSVFile zcsvFile = new ZCSVFile();
        zcsvFile.setRootPath(Members.getWayToDB()+"EXAMPLESD/0100D/");
        zcsvFile.setFileName("master.list");
        String [] namesMap = new String[]
                {"ZOID","ZVER","ZDATE","ZUID","ZSTA","QR","CONTRACTNUM", "contractdate",
                        "MONEY","SUPPLIER","CLIENT","PRODTYPE","MODEL","SN","prodate","shipdate",
                        "SALEDATE","DEPARTUREDATE","WARRANTYSTART","WARRANTYEND","COMMENT "};
        if(Files.exists(Paths.get(zcsvFile.toString()))) {
            boolean res = zcsvFile.tryOpenFile(1);
            System.out.println("Exists");
            if (res) {
                zcsvFile.loadFromFile();
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
        }else{
            System.out.println("Doesn't exists");
        }
    }
}
