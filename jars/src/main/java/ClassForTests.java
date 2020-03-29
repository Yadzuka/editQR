import org.eustrosoft.contractpkg.Model.*;
import org.eustrosoft.contractpkg.Controller.*;
import org.eustrosoft.contractpkg.zcsv.*;

import java.awt.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.SQLOutput;


public class ClassForTests {

    private static String[] namesMap = new String[]
            {"ZRID", "ZVER", "ZDATE", "ZUID", "ZSTA", "QR  код", "№ договора", "Дата договора",
                    "Деньги по договору", "Юр-лицо поставщик", "Юр-лицо клиент", "Тип продукта", "Модель продукта",
                    "SN", "Дата производства", "Дата ввоза (ГТД)",
                    "Дата продажи", "Дата отправки клиенту", "Дата начала гарантии",
                    "Дата окончания гарантии", "Комментарий (для клиента)"};

    public static void main(String[] args) throws Exception {
        /*ZCSVFile zcsvFile;
        Members.setWayToDB("/s/qrdb/EXAMPLESD/members/");
        String rootPath = Members.getWayToDB() + "EXAMPLESD" + "/" + "0100D" + "/";
        zcsvFile = setupZCSVPaths(rootPath, "master.list.csv");
        zcsvFile.loadFromFileValidVersions();
        for(int i = 0; i < zcsvFile.getRowObjects().size(); i++){
            ZCSVRow row = zcsvFile.getRowObjectByIndex(i);
            row.setNames(namesMap);
            System.out.println(row.toString());
            for(int j = 0; j < row.getNames().length; j++){
                System.out.print(row.get(j)+" ");
            }
            System.out.println();
        }

        ZCSVRow newRow = new ZCSVRow();
        newRow.setNames(namesMap);
        for (Integer i = 0; i < namesMap.length; i++) {
            newRow.setStringSpecificIndex(i, i.toString());
        }
        zcsvFile.getRowObjects().add(newRow);
        zcsvFile.appendChangedStringsToFile();*/
        ZCSVFile file;
        Members.setWayToDB("/s/qrdb/EXAMPLESD/members/");
        String rootPath = Members.getWayToDB() + "EXAMPLESD" + "/" + "0100D" + "/";
        file = setupZCSVPaths(rootPath, "csv.tab");
        file.loadConfigureFile();

        for(int i = 0; i < file.getRowObjects().size(); i ++){
            for(int j = 0; j < file.getRowObjectByIndex(i).getDataLength(); j ++)
                System.out.print(file.getRowObjectByIndex(i).get(j));
            System.out.println();
        }



    }

    private static ZCSVFile setupZCSVPaths(String rootPath, String fileName) {
        ZCSVFile file = new ZCSVFile();
        file.setRootPath(rootPath);
        file.setFileName(fileName);
        return file;
    }

}
