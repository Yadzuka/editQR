package org.eustrosoft.contractpkg.Controller;

import org.eustrosoft.contractpkg.Model.Members;
import org.eustrosoft.contractpkg.zcsv.ZCSVFile;

public class ControllerContracts {

    private ZCSVFile zcsvFile;
    private String wayToDB;

    public ControllerContracts(String member, String range) {
        wayToDB = Members.getWayToDB();
        initContactList(member, range);
    }

    private void initContactList(String member, String range) {
        zcsvFile = new ZCSVFile();
        zcsvFile.setRootPath(wayToDB + member + "/" + range + "/");
        zcsvFile.setFileName("master.list.csv");
    }

    public void setZCSVFilePath(String fileName){
        zcsvFile.setFileName(fileName);
    }

    public ZCSVFile getZcsvFile(){
        return zcsvFile;
    }

    public String getZcsvPath() {
        return zcsvFile.toString();
    }
}
