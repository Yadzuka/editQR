package org.eustrosoft.contractpkg.Model;

import java.io.File;
import java.util.regex.Pattern;

public class Ranges {

    File pathToRanges;
    File pathToCSV;
    File [] allDirectories;

    public Ranges(){

    }

    public String getOneRange(String pathName){

        pathToRanges = new File(Members.getWayToDB() + pathName +"/");
        pathToCSV = new File(pathToRanges.getAbsolutePath() + "/0100D");
        allDirectories  = pathToRanges.listFiles();

        if(!pathToCSV.exists()) {
            return null;
        }
        else
            return getRange(pathToCSV.getAbsolutePath());
    }

    private String getRange(String way){
        String [] paths = way.split(Pattern.quote("/"));

        return paths[paths.length-1];
    }

}
