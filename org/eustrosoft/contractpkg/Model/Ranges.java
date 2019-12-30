package org.eustrosoft.contractpkg.Model;

import java.io.File;
import java.util.regex.Pattern;

/*
    Ranges ( ALPHA NOW ) // Working with static folder name (0100D)
 */
public class Ranges {

    // Global parameters for all folders
    File pathToRanges;
    File pathToCSV;
    File [] allDirectories;

    public Ranges(){

    }
    //String officialPathToDB = "/home/yadzuka/workspace/Java_projects/qr.qxyz/db/members/";
    // Range getter
    public String getOneRange(String pathName){

        // Set paths and initialize variables
        pathToRanges = new File(Members.getWayToDB() + pathName +"/");
        pathToCSV = new File(pathToRanges.getAbsolutePath() + "/0100D");
        allDirectories  = pathToRanges.listFiles();

        if(!pathToCSV.exists()) {
            return null;
        }
        else
            return getRange(pathToCSV.getAbsolutePath());
    }

    // Splitter for folder name
    private String getRange(String way){
        String [] paths = way.split(Pattern.quote("/"));

        return paths[paths.length-1];
    }

}
