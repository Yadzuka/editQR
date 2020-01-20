package org.eustrosoft.contractpkg.zcsv;// EustroSoft.org PSPN/CSV project
//
// (c) Alex V Eustrop & yadzuka & EustroSoft.org 2020
//
// LICENSE: BALES, ISC, MIT, BSD on your choice
//
//

import java.io.*;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.channels.FileLock;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.ArrayList;
import java.util.stream.Stream;

/**
 * work with File as CSV database
 */
public class ZCSVFile {

    private final static String[] MODES_TO_FILE_ACCESS = {"r", "rw", "rws", "rwd"};
    private final static String NEXT_LINE_SYMBOL = "\n";
    private final static String FILE_EXTENSION = ".csv";

    private static FileLock lock;
    private FileChannel channel = null;
    private ByteBuffer buffer = null;

    private String configureFilePath = null;
    private String rootPath = null;
    private String sourceFileName = null;
    private ArrayList fileRows = new ArrayList();

    public void setConfigureFilePath(String path) {
        configureFilePath = path;
    }

    public void setRootPath(String rootPath) {
        this.rootPath = rootPath;
    }
    public void setFileName(String fileName) {
        sourceFileName = fileName;
    }
    public String getFileName() {
        return sourceFileName;
    }
    // actions on file
    // open file for read (or write, or append, or lock)
    // ALL FILE STRINGS NOW DOWNLOADED TO THE ARRAY LIST AND CHANNEL OPENED
    // IT WORKS! (in my opinion)
    public boolean tryOpenFile(int mode) {
        if (Files.exists(Paths.get(configureFilePath))) {
            try {
                if (channel == null) {
                    if (mode > MODES_TO_FILE_ACCESS.length - 1 || mode < 0) {
                        throw new ZCSVException("Неприавльно указан мод работы с файлом!");
                    }

                    RandomAccessFile raf = new RandomAccessFile(rootPath + sourceFileName + FILE_EXTENSION, MODES_TO_FILE_ACCESS[mode]);
                    channel = raf.getChannel();
                    return true;
                } else {
                    throw new ZCSVException("Channel already opened!");
                }
            } catch (FileNotFoundException ex) {
                ex.printStackTrace();
                return false;
            } catch (ZCSVException ex) {
                ex.printError();
                return false;
            }
        }
        return false;
    }
    // close file and free it for others
    // IT WORKS! (MB)
    public boolean closeFile() throws IOException {
        if (channel != null) {
            if (channel.isOpen()) {
                channel.close();
                channel = null;
                return true;
            }
        }
        return false;
    }
    // exclusively lock file (can be used before update)
    // IT WORKS!
    private boolean tryFileLock() {
        if (channel == null) {
            return false;
        }
        try {
            if(lock == null) {
                lock = channel.tryLock(0, channel.size(), false);
                return true;
            }
            else
                return false;
        } catch (IOException ex) {
            ex.printStackTrace();
            return false;
        }
    }
    //actions on file content
    // load all lines from file & parse valid rows
    // IT WORKS!
    public void loadFromFile() {
        try {
            /*buffer = ByteBuffer.allocate((int) channel.size());
            channel.read(buffer);

            byte[] bytes = buffer.array();
            String f = new String(bytes, StandardCharsets.UTF_8);*/
            BufferedReader reader = new BufferedReader
                    (new InputStreamReader
                            (new FileInputStream(rootPath + sourceFileName + FILE_EXTENSION), StandardCharsets.UTF_8));

            String bufForStrings = "";
            while((bufForStrings = reader.readLine()) != null) {
                bufForStrings.trim();
                if ("".equals(bufForStrings) || bufForStrings.startsWith("#"))
                    continue;
                else
                    fileRows.add(new ZCSVRow(bufForStrings));
            }
            System.out.println("Array filled by each string!");

        } catch (IOException | NullPointerException ex) {
            System.out.println("Array does not filled!");
        }
    }
    //reload data from file if changed
    public int reloadFromFile() {
       // channel.force(true);
        return 1;
    }
    // update file content based on changes done on rows
    public int updateFromChannel() throws IOException {
        try {
            for(int i = 0;i < fileRows.size(); i++){
                System.out.println(fileRows.get(i).toString());
                ZCSVRow row = (ZCSVRow) fileRows.get(i);
                if(row.isDirty()){
                    fileRows.set(i, row.toString());
                }
            }
            return 1;
        } catch (ClassCastException ex) {
            return 0;
        }
    }
    // fully rewrite content of file with in-memory data
    // IT WORKS!
    public int rewriteAllFile() {
        BufferedWriter writer = null;
        try {
            writer = new BufferedWriter
                    (new OutputStreamWriter(new FileOutputStream
                            (rootPath + sourceFileName + FILE_EXTENSION, false),StandardCharsets.UTF_8));
            for (int i = 0; i < fileRows.size(); i++) {
                ZCSVRow row = (ZCSVRow) fileRows.get(i);
                writer.write(row.toString() + NEXT_LINE_SYMBOL);
            }
            writer.flush();
        } catch (IOException ex) {
            return 0;
        }finally{
            try{
                if(writer != null) writer.close();
            }catch(IOException ex){
                ex.printStackTrace();
            }
        }
        return 1;
    }
                    //fileRows.set(i, row.toString());
    // the same as as above but new file only
    // IT WORKS!
    public int writeNewFile(String newFileName) throws IOException {
        ZCSVRow row;
        String fullPath = rootPath + newFileName + FILE_EXTENSION;
        try {
            Path path = Paths.get(fullPath);
            if(!Files.exists(path)) {
                Files.createFile(path);
            }
            else {
                return -1;
            }
            BufferedWriter writer = new BufferedWriter(new FileWriter(fullPath));
            for (int i = 0; i < fileRows.size(); i++) {
                row = (ZCSVRow) fileRows.get(i);
                writer.write(row.toString() + NEXT_LINE_SYMBOL);
            }
            writer.flush();
            writer.close();
        } catch (ClassCastException | IOException ex) {
            ex.printStackTrace();
            return -1;
        }
        return 1;
    }
    // write changes to file but do not touch any existing data (it's paranodal-safe version of update() method)
    // IT WORKS!
    public void appendNewStringsToFile() throws IOException {
        if(tryFileLock()) {
            BufferedWriter writer = new BufferedWriter
                    (new OutputStreamWriter
                            (new FileOutputStream(rootPath + sourceFileName
                                    + FILE_EXTENSION, true), StandardCharsets.UTF_8));
            for (int i = 0; i < fileRows.size(); i++) {
                ZCSVRow row = (ZCSVRow) fileRows.get(i);
                if (row.isDirty()) {
                    writer.write(row.toString() + NEXT_LINE_SYMBOL);
                }
            }
            writer.flush();
            writer.close();
        }
    }
    // get line from loaded file by number (as is, text upto \n)
    // IT WORKS!
    public String getLineByIndex(int i) throws IOException {
        String stringToGet;
        BufferedReader reader = new BufferedReader
                (new InputStreamReader
                        (new FileInputStream(rootPath + sourceFileName + FILE_EXTENSION), StandardCharsets.UTF_8));
        while ((stringToGet = reader.readLine()) != null) {
            if (i < 0) {
                return "Not valid value";
            } else if (i > 0) {
                i--;
            } else {
                return stringToGet;
            }
        }
        return "This string does not existing";
    }

    // fully rewrite file with in memory data
    public void rewriteFile() throws IOException{
        try {
            if(lock == null) {
                String[] firstFileMassiveOfStrings = new String[fileRows.size()];

                if (tryFileLock()) {
                    BufferedWriter writer = new BufferedWriter
                            (new OutputStreamWriter
                                    (new FileOutputStream(rootPath + sourceFileName
                                            + FILE_EXTENSION, false), StandardCharsets.UTF_8));

                    for (int i = 0; i < fileRows.size(); i++)
                        writer.write(fileRows.get(i).toString() + "\n");

                    writer.flush();
                    writer.close();
                }
            }else{
                throw new ZCSVException("File is opened");
            }
        } catch (ZCSVException ex) {
            ex.printError();
        }finally{
            try{
                if(lock != null) {lock.release(); lock.close();}
            }catch (Exception ex){
                ex.printStackTrace();
            }
        }
    }
    private void compireFileAndArray() throws IOException {
        ByteBuffer secondBuffer = ByteBuffer.allocate((int)channel.size());
        channel.read(secondBuffer);

        String stringForSecondV = new String(secondBuffer.array(), StandardCharsets.UTF_8);
        String [] massiveOfFIleStrings = stringForSecondV.trim().split(NEXT_LINE_SYMBOL);
        int countOfString = stringForSecondV.trim().split(NEXT_LINE_SYMBOL).length;
        for(int i = 0; i <  countOfString; i++){
            if(massiveOfFIleStrings[i].equals(fileRows.get(i).toString())){
                continue;
            }else{

            }
        }
    }
    // get read-only row from loaded file by number (only proper rows, not commented lines)
    public ZCSVRow getRowObjectByIndex(int i) {
        return (ZCSVRow) fileRows.get(i);
    }
    // the same as above but ready for update, change it and use update() method of parent ZCSVFile
    public ZCSVRow editRowObjectByIndex(int i) {
        try {
            if (tryFileLock()) {
                ZCSVRow newRow = (ZCSVRow) fileRows.get(i);
                return (ZCSVRow) fileRows.get(i);
            }
        }catch (Exception ex){
            System.err.println(ex);
        }finally{
            try {
                if(lock != null) {lock.release(); lock = null;}
            }catch (IOException ex){
                System.err.println(ex);
            }
        }
        return (null);
    }
    @Override
    public String toString(){
        return rootPath+sourceFileName;
    }
    // constructors
    public ZCSVFile() {

    }
} //ZCSVFile
