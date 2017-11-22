package com.tenpines.advancetdd;

public class CustomerImporter extends Importer {

    public static final String INVALID_CUSTOMER_RECORD = "Invalid customer record";
    public static final String INVALID_ADDRESS_RECORD = "Invalid address record";
    public static final String INVALID_RECORD_TYPE = "Invalid record type";
    public static final String NO_CUSTOMER_FOR_ADDRESS = "No customer for address";
    private Customer customer;
    private System system;

    public CustomerImporter(System system) {
        this.system = system;
    }

    @Override
    public void parseRecord() throws Exception {
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
        customer = new Customer(record[1], record[2], record[3], record[4]);
        system.add(customer);
    }

    private void loadAddressInCustomerFromRecord() throws Exception {
        if (record.length != 6) {
            throw new Exception(INVALID_ADDRESS_RECORD);
        }
        if (customer == null) {
            throw new Exception(NO_CUSTOMER_FOR_ADDRESS);
        }
        customer.addAddress(new Address(record[1], Integer.parseInt(record[2]), record[3], Integer.parseInt(record[4]), record[5]));
    }

    private boolean isAddressRecord() {
        return "A".equals(record[0]);
    }

    private boolean isCustomerRecord() {
        return "C".equals(record[0]);
    }
}
