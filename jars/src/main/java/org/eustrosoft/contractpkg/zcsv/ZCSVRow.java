// EustroSoft.org PSPN/CSV project
//
// (c) Alex V Eustrop & Pavle Seleznev & EustroSoft.org 2020
// 
// LICENSE: BALES, ISC, MIT, BSD on your choice
//
//

package org.eustrosoft.contractpkg.zcsv;

import java.util.ArrayList;
import java.util.Collections;
import org.eustrosoft.contractpkg.Model.MsgContract;

/**
 * single row from CSV file
 */
public class ZCSVRow {
    public static final String DELIMITER_DEFAULT = ";";
    public static final String DELIMITER2_DEFAULT = ":";
    public static final String DELIMITER_INITEM_DEFAULT = ",";
    private char TAB = '\t';
    private String DELIMITER = ";";

    public String getDelimiter(){return(DELIMITER);}
    public String setDelimiter(String v){String ov=v;DELIMITER=v;return(ov);}

    private boolean is_row = false; //read only
    private boolean is_dirty = false; //read only

    private ZCSVRow previousRow = null;
    private String[] nameMap = null;
    private ArrayList dataInRow = new ArrayList(30);

    protected void resetDirty(){ is_dirty = false; }

    public void set(int i, String value) throws ZCSVException {setStringSpecificIndex(i,value);}
    public void setStringSpecificIndex(int i, String str) throws ZCSVException {
        //SIC!{ убрать к едрене фене!
        if (nameMap == null) throw new ZCSVException("NameMap не заполнен!"); //SIC! вынести сообщения в константы, не срочно
        if (i < 0 || i >= nameMap.length) throw new ZCSVException("Индекс указан неправильно!"); //SIC!
        if (is_row) return; //SIC! и чтобы это значило?
        //}SIC!
        is_dirty = true;

        if(dataInRow.isEmpty()){
            for(int j = 0; j < nameMap.length; j++){
                dataInRow.add("");
            }
        }
        str = MsgContract.value2csv(str);
        if(i >= dataInRow.size()){
            dataInRow.add(str); //SIC! т.е. не в позицию i, а абы-в-какую-следующую? ;)
        }else {
            dataInRow.set(i, str);
        }
    }

    public void setNewName(String name, String dataInRow) throws ZCSVException {
        int index = name2column(name);
        if (index == -1)
            throw new ZCSVException("Название параметра не найдено!"); //SIC!
        setStringSpecificIndex(index, dataInRow);
    }

    public String get(int i) throws ZCSVException {
            if (dataInRow == null)
                throw new ZCSVException("Данные не загружены!"); //SIC!
            if (nameMap != null)
                if(i < nameMap.length & i > dataInRow.size() - 1)
                    return "";
            if ((i >= dataInRow.size() || i < 0))
                throw new ZCSVException("Индекс задан неправильно!"); //SIC!

            if(dataInRow.get(i).equals("null") | dataInRow.get(i) == null)
                return "";

            return MsgContract.csv2text((String) dataInRow.get(i));
        }

    public String get (String name) throws ZCSVException { return get(name2column(name)); }

    public int name2column (String name){
        if (nameMap != null & name != null) {
            for (int i = 0; i < nameMap.length; i++) {
                if (name.equals(nameMap[i]))
                    return (i);
            }
        }
        return (-1);
    }

    public boolean isDirty () { return is_dirty; }
    public void setRow () { is_row = true; }
    public boolean isRow () { return (is_row); }

    public void setPrevious (ZCSVRow previous){ previousRow = previous; }
    public ZCSVRow getPrevious () { return (previousRow); }

    public void setNames (String[]names){ nameMap = names; }
    public String[] getNames () { return nameMap; }

    public int size(){return(getDataLength());}
    public int getDataLength () { return dataInRow.size(); } //SIC! удалить!

    @Override
    public String toString () {
        StringBuilder returnString = new StringBuilder();

        for (int i = 0; i < dataInRow.size(); i++) {
            if (i < dataInRow.size() - 1) {
                returnString.append(MsgContract.value2csv(dataInRow.get(i).toString()));
                returnString.append(DELIMITER);
            } else {
                returnString.append(dataInRow.get(i).toString());
            }
        }
        return returnString.toString();
    }

    @Override
    public ZCSVRow clone(){
        ZCSVRow clone = new ZCSVRow();
        clone.setNames(this.getNames());
        clone.previousRow = this.previousRow;
        clone.dataInRow = (ArrayList) this.dataInRow.clone();
        return clone;
    }

    private void splitString (String str){
        dataInRow = new ArrayList();Collections.addAll(dataInRow, str.split(DELIMITER));
    }

    // Constructors section

    public ZCSVRow() { dataInRow = new ArrayList(); }
    public ZCSVRow(String row) { splitString(row); }
    public ZCSVRow(String row, String delimiter) { DELIMITER = delimiter; splitString(row); }
    public ZCSVRow(String[]values){ setNames(values); }
    public ZCSVRow(String[]values, String[]names){
            setNames(names);
            for (String s : values) { dataInRow.add(s); }
        }
    } //ZCSVRow
