// EustroSoft.org PSPN/CSV project
//
// (c) Alex V Eustrop & EustroSoft.org 2020
// 
// LICENSE: BALES, ISC, MIT, BSD on your choice
//
//

package org.eustrosoft.contractpkg.zcsv;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Vector;

/**
 * single row from CSV file
 */
public class ZCSVRow {
    public String DELIMETER = ";";

    private boolean is_row = false; //read only
    private boolean is_dirty = false; //read only

    private ZCSVRow previousRow = null;
    private String[] nameMap = null;
    private ArrayList dataInRow = null;

    public void setStringSpecificIndex(int i, String str) throws ZCSVException {
        if (nameMap == null) throw new ZCSVException("NameMap не заполнен!");
        if (i < 0 || i >= nameMap.length)
            throw new ZCSVException("Индекс указан неправильно!");
        if (is_row) return;
        is_dirty = true;

        if (dataInRow.isEmpty())
            for (int j = 0; j < nameMap.length; j++)
                dataInRow.add("");

        dataInRow.set(i, str);
    }

    public void setNewName(String name, String dataInRow) throws ZCSVException {
        int index = name2column(name);
        if (index == -1)
            throw new ZCSVException("Название параметра не найдено!");
        setStringSpecificIndex(index, dataInRow);
    }

    public String get(int i) throws ZCSVException {
            if (dataInRow == null)
                throw new ZCSVException("Данные не загружены!");
            if (!(nameMap == null))
                if(i < nameMap.length & i > dataInRow.size() - 1)
                    return null;
            if ((i >= dataInRow.size() || i < 0))
                throw new ZCSVException("Индекс задан неправильно!");

            return (String) dataInRow.get(i);
        }

        public String get (String name) throws ZCSVException {
            return get(name2column(name));
        }

        public int name2column (String name){
            if (!(nameMap == null || name == null)) {
                for (int i = 0; i < nameMap.length; i++) {
                    if (name.equals(nameMap[i]))
                        return (i);
                }
            }
            return (-1);
        }

        public boolean isDirty () {
            return is_dirty;
        }

        public void setRow () {
            is_row = true;
        }

        public boolean isRow () {
            return (is_row);
        }

        public void setPrevious (ZCSVRow previous){
            previousRow = previous;
        }

        public ZCSVRow getPrevious () {
            return (previousRow);
        }

        public void setNames (String[]names){
            nameMap = names;
        }

        public String[] getNames () {
            return nameMap;
        }

        public int getDataLength () {
            return dataInRow.size();
        }
        @Override
        public String toString () {
            StringBuilder returnString = new StringBuilder();

            for (int i = 0; i < dataInRow.size(); i++) {
                if (i < dataInRow.size() - 1) {
                    returnString.append(dataInRow.get(i).toString());
                    returnString.append(DELIMETER);
                } else {
                    returnString.append(dataInRow.get(i).toString());
                }
            }
            return returnString.toString();
        }

        private void splitString (String str){
            dataInRow = new ArrayList();

            Collections.addAll(dataInRow, str.split(DELIMETER));
        }

    public ZCSVRow() {
            dataInRow = new ArrayList();
        }

    public ZCSVRow(String row) {
            splitString(row);
        }

    public ZCSVRow(String row, String delimiter) {
            DELIMETER = delimiter;
            splitString(row);
        }

    public ZCSVRow(String[]values){
            setNames(values);
        }

    public ZCSVRow(String[]values, String[]names){
            setNames(names);
            for (String s : values) {
                dataInRow.add(s);
            }
        }
    } //ZCSVRow
