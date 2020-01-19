package org.eustrosoft.contractpkg.zcsv;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.channels.FileChannel;
import java.util.Scanner;

public class Main {

    public static void main(String[] args) throws IOException {
        ZCSVRow row = new ZCSVRow();
        ZCSVFile file = new ZCSVFile();
        int code;
        boolean success;
        file.setFileName("test");
        file.setRootPath("/home/yadzuka/workspace/Java_projects/Sources/Java_product_projects/qr.qxyz.zcsv/CSVTestFiles");
        file.setConfigureFilePath("/home/yadzuka/workspace/Java_projects/Sources/Java_product_projects" +
                "/qr.qxyz.zcsv/CSVTestFiles/ConfigurePath/HelloConfigure.csv");
        try {
            // IF OPENING MODE = 0 - WE CANT WRITE IN THE FILE. (EXCEPTION HANDLED)
                if(file.tryOpenFile(1)) {
                    file.loadFromFile();
                    file.appendNewStringsToFile();
                    file.closeFile();

                }else
                    System.err.println("Error with opening");

        }catch (Exception ex){
            ex.printStackTrace();
        }
    }


}
