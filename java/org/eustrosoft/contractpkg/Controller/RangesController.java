package org.eustrosoft.contractpkg.Controller;

import org.eustrosoft.contractpkg.Model.Members;

import java.io.*;
import java.nio.charset.StandardCharsets;

/*
    Ranges controller to manage ranges system
 */
public class RangesController {

    File pathToRanges;
    File[] allDirectories;
    BufferedReader bufferedReader;

    StringBuilder sb;
    String pathToHtml;
    String bufferForWriting = "";

    // Set paths and initialize variables
    public RangesController(String context){
        pathToRanges = new File(Members.getWayToDB() + context + "/");
        allDirectories = pathToRanges.listFiles();
        sb = new StringBuilder();
    }

    public static boolean isRange(File f)
    {
     if(!f.isDirectory()) return(false);
     if(f.getName().length() != 5) return(false);
     try{ Long l = Long.valueOf(f.getName(),16);}
     catch(Exception e){return(false);}
     return(true);
    }

	public String [] getRanges(){
		int num_dir=0;
		int membersCounter = allDirectories.length;
		String[] companyNames = new String[membersCounter];
		for(int i = 0; i < membersCounter; i++){
			if(isRange(allDirectories[i]))
			{
			companyNames[num_dir] = allDirectories[i].getName();
			num_dir++;
			}
		}
		String[] names = new String[num_dir];
		for(int i = 0; i < num_dir; i++){ names[i]=companyNames[i];}
		companyNames = names;
		membersCounter = num_dir;
		return companyNames; //SIC! возврат private (было раньше в Members)
	}

    public String getInfo() throws IOException {

        // If finding *.html - read it
        for (int i = 0; i < allDirectories.length; i++) {
            if (allDirectories[i].getName().endsWith("html")) {

                pathToHtml = allDirectories[i].getAbsolutePath();
                bufferedReader = new BufferedReader(new InputStreamReader(new FileInputStream(pathToHtml),
                                                        StandardCharsets.UTF_8));

                while ((bufferForWriting = bufferedReader.readLine()) != null) {
                    sb.append(bufferForWriting);
                }
               // printWriter.println(sb.toString());
            }
        }
        bufferForWriting = sb.toString();

        // PRINT WRITER CLOSES IN JSP! BUFFERED READER AS WELL!
        return bufferForWriting;
    }
}
