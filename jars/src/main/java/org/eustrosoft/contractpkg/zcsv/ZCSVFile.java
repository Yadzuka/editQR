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
import java.util.function.Consumer;
import java.util.function.Predicate;
import java.util.stream.Stream;

/**
 * work with File as CSV database
 */
public class ZCSVFile {

    private final static String[] MODES_TO_FILE_ACCESS = {"r", "rw", "rws", "rwd"};
    private final static String NEXT_LINE_SYMBOL = "\n";

    private static FileLock lock;
    private FileChannel channel = null;
    private ByteBuffer buffer = null;

    private String configureFilePath = null;
    private String rootPath = null;
    private String sourceFileName = null;
    private ArrayList fileRows = new ArrayList();
    private ArrayList allRows = new ArrayList();

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

    public int getFileRowsLength() {
        return fileRows.size();
    }

    public ArrayList getRowObjects() { return this.fileRows; }

    // READ SECTION

    // actions on file
    // open file for read (or write, or append, or lock)
    // ALL FILE STRINGS NOW DOWNLOADED TO THE ARRAY LIST AND CHANNEL OPENED
    // IT WORKS! (in my opinion)
    public boolean tryOpenFile(int mode) throws Exception {
        if (channel == null) {
            if (mode > MODES_TO_FILE_ACCESS.length - 1 || mode < 0) {
                throw new ZCSVException("Неприавльно указан мод работы с файлом!");
            }

            RandomAccessFile raf = new RandomAccessFile(rootPath + sourceFileName, MODES_TO_FILE_ACCESS[mode]);
            channel = raf.getChannel();
            return true;
        } else {
            throw new ZCSVException("Channel already opened!");
        }

    }

    // exclusively lock file (can be used before update)
    // IT WORKS!
    public boolean tryFileLock() {
        if (channel == null) {
            return false;
        }
        try {
            lock = channel.tryLock(0, channel.size(), false);
            return true;
        } catch (IOException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    // close file and free it for others
    public boolean closeFile() throws IOException {
        if (channel != null) {
            if (channel.isOpen() || channel != null) {
                channel.close();
                return true;
            }
        }
        return false;
    }

    //actions on file content
    // load all lines from file & parse valid rows
    // Load all strings ( also with any versions )
    public void loadFromFile() {
        try {
            Files.lines(Paths.get(rootPath + sourceFileName), StandardCharsets.UTF_8).
                    filter(w -> !(w.startsWith("#") || "".
                            equals(w))).forEach(w -> fileRows.add(new ZCSVRow(w.trim())));

        } catch (IOException | NullPointerException ex) {
            ex.printStackTrace();
        }
    }

    // Load and show only last versions of contract
    // 0 index - ZRID (row). 1 index - ZVER (version)
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

    //reload data from file if changed
    /*public int reloadFromFile() {
        channel.force(true);
        return 1;
    }*/

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
    public int rewriteAllFile() {
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
            BufferedWriter writer = new BufferedWriter
                    (new OutputStreamWriter
                            (new FileOutputStream(rootPath + sourceFileName
                                    , true), StandardCharsets.UTF_8));
            for (int i = 0; i < fileRows.size(); i++) {
                ZCSVRow row = (ZCSVRow) fileRows.get(i);
                if (row.isDirty()) {
                    writer.write(row.toString() + NEXT_LINE_SYMBOL);
                }
            }
            writer.flush();
            writer.close();
    }

    // the same as as above but new file only
    public int writeNewFile(String newFileName) throws IOException {
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
        if (lock == null) {
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
        } else {
            throw new ZCSVException("File is opened");
        }
    }

    // GET ZCSVRow SECTION

    // get read-only row from loaded file by number (only proper rows, not commented lines)
    public ZCSVRow getRowObjectByIndex(int i) {
        return (ZCSVRow) fileRows.get(i);
    }

    // the same as above but ready for update, change it and use update() method of parent ZCSVFile
    public ZCSVRow editRowObjectByIndex(int i) {
        if (tryFileLock()) {
            ZCSVRow newRow = (ZCSVRow) fileRows.get(i);
            return (ZCSVRow) fileRows.get(i);
        }

        return (null);
    }

    @Override
    public String toString() {
        return rootPath + sourceFileName;
    }

    // constructors
    public ZCSVFile() {

    }
} //ZCSVFile