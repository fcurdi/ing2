package com.tenpines.advancetdd;

import java.io.IOException;
import java.io.LineNumberReader;
import java.io.Reader;

public abstract class Importer {

    private LineNumberReader lineReader;
    private String line;
    protected String[] record;

    protected void from(Reader reader) throws Exception {
        lineReader = new LineNumberReader(reader);
        while (hasLinesToProcess()) {
            recordFromLine();
            parseRecord();
        }
    }

    private Boolean hasLinesToProcess() throws IOException {
        line = lineReader.readLine();
        return line != null;
    }

    private void recordFromLine() {
        record = line.split(",");
    }

    protected abstract void parseRecord() throws Exception;
}
