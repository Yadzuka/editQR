package org.eustrosoft.contractpkg;


import org.eustrosoft.contractpkg.Controller.ControllerContracts;
import org.eustrosoft.contractpkg.Model.Contract;
import org.eustrosoft.contractpkg.Model.Members;

import java.util.ArrayList;

/*
	Testing class for all of capabilities
 */
class TestingClass {

    public static void main(String[] args) {
        Members member = new Members();
        int counter = member.getMembersCounter();
        String [] members = member.getCompanyNames();
        System.out.println(counter);
        for(String s : members){
            System.out.println(s);
        }

        ControllerContracts controllerContracts = new ControllerContracts();
        ArrayList<Contract> contracts = controllerContracts.getContracts();
        for(Contract c : contracts){
            System.out.println(c.getZDATE());
        }
    }
}