package org.eustrosoft.contractpkg.Controller;

import org.eustrosoft.contractpkg.zcsv.ZCSVFile;

import java.io.IOException;
import java.util.ArrayList;

/*
    Contract controller to manage contract date
 */
public class ControllerContracts {

    private ZCSVFile zcsvFile;

    public ControllerContracts(String qrdb, String range) {
        initContactList(qrdb, range);
    }

    private void initContactList(String qrdb, String range) {
        zcsvFile = new ZCSVFile();
        zcsvFile.setRootPath(qrdb);
    }

    public void setZCSVFilePath(String fileName){
        zcsvFile.setFileName(fileName);
    }
    public ZCSVFile getZCSVFile() {
        return zcsvFile;
    }
}
