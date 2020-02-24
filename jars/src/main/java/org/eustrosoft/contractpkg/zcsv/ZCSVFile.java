package org.eustrosoft.contractpkg.zcsv;

// EustroSoft.org PSPN/CSV project
//
// (c) Alex V Eustrop & Pavle Seleznev & EustroSoft.org 2020
//
// LICENSE: BALES, ISC, MIT, BSD on your choice
//
//

import java.io.*;
import java.nio.channels.FileChannel;
import java.nio.channels.FileLock;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.ArrayList;
import java.util.stream.*;

/**
 * work with File as CSV database
 */
public class ZCSVFile {

    private final static String CONFIGURE_FILE_DELIMITER = "\t";
    private final static String CONFIGURE_FILE_EXTENSION = ".tab";
    private final static String [] CONFIGURE_FILE_NAME_MAP = {"Код","Поле","Тип","Атрибуты","Название","Описание"};

    private final static String NEXT_LINE_SYMBOL = "\n";
    private final static String[] MODES_TO_FILE_ACCESS = {"r", "rw", "rws", "rwd"};

    private static FileLock lock;
    private FileChannel channel = null;

    private String rootPath = null;
    private String sourceFileName = null;
    private ArrayList fileRows = new ArrayList(65536);

    public void setRootPath(String rootPath) { this.rootPath = rootPath; }
    public void setFileName(String fileName) { sourceFileName = fileName; }
    public String getFileName() { return sourceFileName; }
    public int getFileRowsLength() { return fileRows.size(); }
    public ArrayList getRowObjects() { return this.fileRows; }

    // READ SECTION

    // actions on file
    // open file for read (or write, or append, or lock)
    public boolean tryOpenFile(int mode) throws Exception {
        if (channel == null) {
            if (mode > MODES_TO_FILE_ACCESS.length - 1 || mode < 0) {
                throw new ZCSVException("Неприавльно указан мод работы с файлом!");
            }
            RandomAccessFile raf = new RandomAccessFile(rootPath + sourceFileName, MODES_TO_FILE_ACCESS[mode]);
            channel = raf.getChannel();
            return true;
        } else { throw new ZCSVException("Channel already opened!"); }
    }

    // exclusively lock file (can be used before update)
    public boolean tryFileLock() throws Exception {
        if (channel == null) { return false; }
        lock = channel.tryLock();
        return true;
    }

    // close file and free it for others
    public boolean closeFile() throws IOException {
        if (channel != null) { if (channel.isOpen() || channel != null) { channel.close(); return true; } }
        return false;
    }

    // Load all strings ( also with any versions )
    public void loadFromFile() throws IOException { //SIC! это надо переделать через loadFromFile(String delimiter)
        Files.lines(Paths.get(rootPath + sourceFileName), StandardCharsets.UTF_8).
                filter(w -> !(w.trim().startsWith("#") || "".
                        equals(w.trim()))).forEach(w -> fileRows.add(new ZCSVRow(w.trim())));
    }

    public void loadFromFile(String delimiter) throws IOException{
        loadFromStream(Files.lines(Paths.get(rootPath + sourceFileName), StandardCharsets.UTF_8),delimiter);
    }
    public void loadFromStream(Stream<String> ss, String delimiter) throws IOException{
                ss.filter(w -> !(w.trim().startsWith("#") || "".
                        equals(w.trim()))).forEach(w -> {
                            ZCSVRow newRow = new ZCSVRow(w.trim(), delimiter);
                            newRow.setNames(CONFIGURE_FILE_NAME_MAP);
                            fileRows.add(newRow);

        });
    }

    public boolean loadConfigureFile() throws IOException, ZCSVException{
            if (!sourceFileName.endsWith(CONFIGURE_FILE_EXTENSION))
                throw new ZCSVException("Error with configure file format");
            if (rootPath.equals("") | sourceFileName.equals(""))
                throw new ZCSVException("Error with configure file paths");
            loadFromFile(CONFIGURE_FILE_DELIMITER);
            return true;
    }
    public boolean loadConfigFromString(String conf) throws IOException, ZCSVException{
    BufferedReader sr = new BufferedReader(new StringReader(conf));
    loadFromStream(sr.lines(),CONFIGURE_FILE_DELIMITER);
    return(true);
    }

    // Load and show only last versions of contract
    public void loadFromFileValidVersions() throws Exception {
        ArrayList<Integer> zRIDS = new ArrayList<>();

        BufferedReader reader = new BufferedReader
                (new InputStreamReader
                        (new FileInputStream(rootPath + sourceFileName), StandardCharsets.UTF_8));
        String bufForStrings = "";
        while ((bufForStrings = reader.readLine()) != null) {
            bufForStrings = bufForStrings.trim();
            if ("".equals(bufForStrings) || bufForStrings.startsWith("#"))
                continue;
            else {
                ZCSVRow newRow = new ZCSVRow(bufForStrings);
                if (zRIDS.contains(Integer.parseInt(newRow.get(0)))) {
                    for (int i = 0; i < zRIDS.size(); i++) {
                        ZCSVRow row = (ZCSVRow) fileRows.get(i);
                        if (newRow.get(0).equals(row.get(0))) {
                            if (Integer.parseInt(newRow.get(1)) > Integer.parseInt(row.get(1))) {
                                fileRows.remove(i);
                                fileRows.add(i, newRow);
                                newRow.setPrevious(row);
                                break;
                            } else if (Integer.parseInt(newRow.get(1)) == Integer.parseInt(row.get(1))) {
                                break;
                            }
                        }
                    }
                } else {
                    fileRows.add(newRow);
                    zRIDS.add(Integer.parseInt(newRow.get(0)));
                }
            }
        }
    }

    // update file content based on changes done on rows
    public int updateFromChannel() throws ClassCastException {
        for (int i = 0; i < fileRows.size(); i++) {
            ZCSVRow row = (ZCSVRow) fileRows.get(i);
            if (row.isDirty()) {
                fileRows.set(i, new ZCSVRow(row.toString()));
            }
        }
        return 1;
    }

    // fully rewrite content of file with in-memory data
    // IT WORKS!
    public int rewriteAllFile() throws Exception {
        BufferedWriter writer = null;
        if (tryFileLock() && channel != null) {
            try {
                writer = new BufferedWriter
                        (new OutputStreamWriter(new FileOutputStream
                                (rootPath + sourceFileName, false), StandardCharsets.UTF_8));
                for (int i = 0; i < fileRows.size(); i++) {
                    ZCSVRow row = (ZCSVRow) fileRows.get(i);
                    writer.write(row.toString() + NEXT_LINE_SYMBOL);
                }
                writer.flush();
            } catch (IOException ex) {
                return 0;
            } finally {
                try {
                    if (writer != null) writer.close();
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
            }
        }
        return 1;
    }

    // get line from loaded file by number (as is, text upto \n)
    // IT WORKS!
    public String getLineByIndex(int i) {
        if (i < 0 || i >= fileRows.size())
            return null;
        else
            return fileRows.get(i).toString();
    }

    // WRITE SECTION

    // write changes to file but do not touch any existing data (it's paranodal-safe version of update() method
    public void appendChangedStringsToFile() throws IOException {
        if(lock != null)
            if(lock.isValid())
                return;
        BufferedWriter writer = new BufferedWriter
                (new OutputStreamWriter
                        (new FileOutputStream(rootPath + sourceFileName
                                , true), StandardCharsets.UTF_8));
        for (int i = 0; i < fileRows.size(); i++) {
            ZCSVRow row = (ZCSVRow) fileRows.get(i);
            if (row.isDirty()) {
                writer.write(row.toString() + NEXT_LINE_SYMBOL);
                row.resetDirty();
            }
        }
        writer.flush();
        writer.close();
    }

    public void appendNewStringToFile(ZCSVRow newRow) throws IOException, ZCSVException {
        if(lock != null)
            if(lock.isValid())
                return;
        int newObjectZRID = Integer.parseInt(newRow.get(0));
        boolean flagForNewObj = true;
        int index = 0;
        for(; index < fileRows.size(); index++){
            ZCSVRow buffer = (ZCSVRow) fileRows.get(index);
            if(buffer.get(0).equals(newObjectZRID)) {
                flagForNewObj = false;
                break;
            }
        }

        if(flagForNewObj){ fileRows.add(newRow); }
        else{ fileRows.remove(index); fileRows.set(index, newRow); }

        BufferedWriter writer = new BufferedWriter
                (new OutputStreamWriter
                        (new FileOutputStream(rootPath + sourceFileName
                                , true), StandardCharsets.UTF_8));
        writer.write(newRow.toString() + NEXT_LINE_SYMBOL);
        newRow.resetDirty();
        writer.flush();
        writer.close();
    }

    // the same as as above but new file only
    public int writeNewFile(String newFileName) throws IOException {
        if(lock != null)
            if(lock.isValid())
                return 0;
        ZCSVRow row;
        String fullPath = rootPath + newFileName;

        Path path = Paths.get(fullPath);
        if (!Files.exists(path)) {
            Files.createFile(path);
        } else {
            return -1;
        }
        BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream
                (fullPath, false), StandardCharsets.UTF_8));
        for (int i = 0; i < fileRows.size(); i++) {
            row = (ZCSVRow) fileRows.get(i);
            writer.write(row.toString() + NEXT_LINE_SYMBOL);
        }
        writer.flush();
        writer.close();

        return 1;
    }

    // fully rewrite file with in memory data
    public void rewriteFile() throws Exception {
        if (lock != null)
            if(lock.isValid())
                return;
            String[] firstFileMassiveOfStrings = new String[fileRows.size()];

            if (tryFileLock()) {
                BufferedWriter writer = new BufferedWriter
                        (new OutputStreamWriter
                                (new FileOutputStream(rootPath + sourceFileName
                                        , false), StandardCharsets.UTF_8));

                for (int i = 0; i < fileRows.size(); i++)
                    writer.write(fileRows.get(i).toString() + "\n");

                writer.flush();
                writer.close();
            }
    }

    // GET ZCSVRow SECTION

    // get read-only row from loaded file by number (only proper rows, not commented lines)
    public ZCSVRow getRowObjectByIndex(int i) { return (ZCSVRow) fileRows.get(i); }

    // the same as above but ready for update, change it and use update() method of parent ZCSVFile
    public ZCSVRow editRowObjectByIndex(int i) throws Exception {
        if (tryFileLock()) {
            ZCSVRow newRow = (ZCSVRow) fileRows.get(i);
            return (ZCSVRow) fileRows.get(i);
        }

        return (null);
    }

    @Override
    public String toString() { return rootPath + sourceFileName; } //SIC! надо подумать, может содиржимое файла...

    // constructors
    public ZCSVFile() { }
} //ZCSVFile
