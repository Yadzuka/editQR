package org.eustrosoft.contractpkg.config;

import java.io.BufferedReader;
import java.io.InputStreamReader;

public class GenerateConfigureFile {
    private final static String [] FIRST_DESCRIPTION = {"Атрибут", "Значение", "Значение2/код"};
    private final static String [] ATTRIBUTE = {"NAME", "OBJECT", "HEADER", "PARENT", "CHILD"};
    private final static String [] ATTRIBUTE_VALUE = {"DRow", "Document", "STD_HEADER", "DDocument", "DRProperty"};
    private final static String [] ATTRIBUTE_VALUE_2 = {"", "DW", "D", "DD", "DP"};

    private final static String [] SECOND_DESCRIPTION = {"Код", "Поле", "Тип", "Атрибуты", "Название", "Описание"};
    private final static String [] TYPE = {"TEXT", "NUMBER", "MONEY"};
    private final static String [] FIELD_ATTRIBUTE = {"NUL", "NN", "UNIQ", "DIC", "ACL"};

    private static int START_CODE = 1;

    public static void main(String[] args) {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));



    }



}
