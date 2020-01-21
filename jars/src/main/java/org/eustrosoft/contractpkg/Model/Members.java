package org.eustrosoft.contractpkg.Model;

import java.io.File;

public class Members {

	// Global parameters to get existing members
	private static String wayToDB;
	private String [] companyNames;
	private File [] listOfMembers;
	private int membersCounter;

	public static void setWayToDB(String wayToDBlink){
		wayToDB = wayToDBlink;
	}
	public static String getWayToDB(){
		return wayToDB;
	}

	public Members() {

	}

	public String [] getCompanyNames(){

		listOfMembers = new File(wayToDB).listFiles();
		int num_dir=0;

		membersCounter = listOfMembers.length;
		companyNames = new String[membersCounter];

		for(int i = 0; i < membersCounter; i++){
			if(listOfMembers[i].isDirectory())
			{
			companyNames[num_dir] = listOfMembers[i].getName();
			num_dir++;
			}
		}
		String[] names = new String[num_dir];
		for(int i = 0; i < num_dir; i++){ names[i]=companyNames[i];}
		companyNames = names;
		membersCounter = num_dir;
		return companyNames; //SIC! возврат private
	}
	private void setCompanyNames(String [] companyNames) {
		this.companyNames = companyNames;
	}

	public int getMembersCounter() {
		return membersCounter;
	}

	public void setMembersCounter(int membersCounter) {
		this.membersCounter = membersCounter;
	}
}
