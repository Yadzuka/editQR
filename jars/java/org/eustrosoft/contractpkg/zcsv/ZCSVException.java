// EustroSoft.org PSPN/CSV project
//
// (c) Alex V Eustrop & EustroSoft.org 2020
// 
// LICENSE: BALES, ISC, MIT, BSD on your choice
//
//

package org.eustrosoft.contractpkg.zcsv;

/**
 * exception which this package able to throw.
 */
public class ZCSVException extends Exception {

    // constructors
    public ZCSVException() { }

    ZCSVException(Exception e) {
        super(e.getMessage());
    }

    public ZCSVException(String s) {
        super(s);
    }
    //  debugging variant
    public void printError(){
        super.getMessage();
    }
} //ZCSVException
