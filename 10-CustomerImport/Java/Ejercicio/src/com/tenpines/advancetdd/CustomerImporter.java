package com.tenpines.advancetdd;

import org.hibernate.Session;

import java.io.IOException;
import java.io.LineNumberReader;
import java.io.Reader;

public class CustomerImporter {

    private static String line;
    private static LineNumberReader lineReader;
    private Customer customer;
    private String[] record;
    private Session session;

    public CustomerImporter(Session session) {
        this.session = session;
    }

    public void from(Reader reader) throws IOException {
        lineReader = new LineNumberReader(reader);
        while (hasLinesToProcess()) {
            recordFromLine();
            parseRecord();
        }
    }

    private void recordFromLine() {
        record = line.split(",");
    }

    private void parseRecord() {
        if (isCustomerRecord()) {
            loadCustomerFromRecord();
        } else if (isAddressRecord()) {
            loadAddressInCustomerFromRecord();
        }
    }

    private void loadCustomerFromRecord() {
        customer = new Customer();
        customer.setFirstName(record[1]);
        customer.setLastName(record[2]);
        customer.setIdentificationType(record[3]);
        customer.setIdentificationNumber(record[4]);
        session.persist(customer);
    }

    private void loadAddressInCustomerFromRecord() {
        Address newAddress = new Address();
        newAddress.setStreetName(record[1]);
        newAddress.setStreetNumber(Integer.parseInt(record[2]));
        newAddress.setTown(record[3]);
        newAddress.setZipCode(Integer.parseInt(record[4]));
        newAddress.setProvince(record[5]);
        customer.addAddress(newAddress);
    }

    private boolean isAddressRecord() {
        return line.startsWith("A");
    }

    private boolean isCustomerRecord() {
        return line.startsWith("C");
    }

    private Boolean hasLinesToProcess() throws IOException {
        line = lineReader.readLine();
        return line != null;
    }

}
