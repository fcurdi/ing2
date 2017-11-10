package com.tenpines.advancetdd;

import org.hibernate.Session;

import java.io.IOException;
import java.io.LineNumberReader;
import java.io.Reader;

public class CustomerImporter {

    public static final String INVALID_CUSTOMER_RECORD = "Invalid customer record";
    public static final String INVALID_ADDRESS_RECORD = "Invalid address record";
    public static final String INVALID_RECORD_TYPE = "Invalid record type";
    public static final String NO_CUSTOMER_FOR_ADDRESS = "No customer for address";
    private static String line;
    private static LineNumberReader lineReader;
    private Customer customer;
    private String[] record;
    private Session session;

    public CustomerImporter(Session session) {
        this.session = session;
    }

    public void from(Reader reader) throws Exception {
        lineReader = new LineNumberReader(reader);
        while (hasLinesToProcess()) {
            recordFromLine();
            parseRecord();
        }
    }

    private void recordFromLine() {
        record = line.split(",");
    }

    private void parseRecord() throws Exception {
        if (isCustomerRecord()) {
            loadCustomerFromRecord();
        } else if (isAddressRecord()) {
            loadAddressInCustomerFromRecord();
        } else {
            throw new Exception(INVALID_RECORD_TYPE);
        }
    }

    private void loadCustomerFromRecord() throws Exception {
        if (record.length != 5) {
            throw new Exception(INVALID_CUSTOMER_RECORD);
        }
        customer = new Customer();
        customer.setFirstName(record[1]);
        customer.setLastName(record[2]);
        customer.setIdentificationType(record[3]);
        customer.setIdentificationNumber(record[4]);
        session.persist(customer);
    }

    private void loadAddressInCustomerFromRecord() throws Exception {
        if (record.length != 6) {
            throw new Exception(INVALID_ADDRESS_RECORD);
        }
        Address newAddress = new Address();
        newAddress.setStreetName(record[1]);
        newAddress.setStreetNumber(Integer.parseInt(record[2]));
        newAddress.setTown(record[3]);
        newAddress.setZipCode(Integer.parseInt(record[4]));
        newAddress.setProvince(record[5]);
        if (customer == null) {
            throw new Exception(NO_CUSTOMER_FOR_ADDRESS);
        }
        customer.addAddress(newAddress);
    }

    private boolean isAddressRecord() {
        return "A".equals(record[0]);
    }

    private boolean isCustomerRecord() {
        return "C".equals(record[0]);
    }

    private Boolean hasLinesToProcess() throws IOException {
        line = lineReader.readLine();
        return line != null;
    }

}
