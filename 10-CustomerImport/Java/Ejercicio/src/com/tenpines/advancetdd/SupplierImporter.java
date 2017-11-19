package com.tenpines.advancetdd;

public class SupplierImporter extends Importer {

    public static final String INVALID_RECORD_TYPE = "Invalid record type";
    public static final String INVALID_ADDRESS_RECORD = "Invalid address record";
    public static final String NO_SUPPLIER_FOR_ADDRESS = "No supplier for address";
    public static final String INVALID_SUPPLIER_RECORD = "Invalid supplier record";
    public static final String INVALID_CUSTOMER_RECORD = "Invalid customer record";
    public static final String NO_SUPPLIER_FOR_CUSTOMER = "No supplier for customer";
    private final ErpSystem erpSystem;
    private Supplier supplier;

    public SupplierImporter(ErpSystem erpSystem) {
        this.erpSystem = erpSystem;
    }

    @Override
    protected void parseRecord() throws Exception {
        if (isSupplierRecord()) {
            loadSupplierFromRecord();
        } else if (isCustomerRecord()) {
            loadCustomerFromRecord();
        } else if (isAddressRecord()) {
            loadAddressInSupplierFromRecord();
        } else {
            throw new Exception(INVALID_RECORD_TYPE);
        }
    }

    private void loadAddressInSupplierFromRecord() throws Exception {
        if (record.length != 6) {
            throw new Exception(INVALID_ADDRESS_RECORD);
        }
        if (supplier == null) {
            throw new Exception(NO_SUPPLIER_FOR_ADDRESS);
        }
        supplier.addAddress(new Address(record[1], Integer.parseInt(record[2]), record[3], Integer.parseInt(record[4]), record[5]));
    }

    private void loadCustomerFromRecord() throws Exception {
        if (isNewCustomerRecord()) {
            loadNewCustomerFromRecord();
        } else if (isExistingCustomerRecord()) {
            loadExistingCustomerFromRecord();
        } else {
            throw new Exception(INVALID_CUSTOMER_RECORD);
        }
    }

    private void loadExistingCustomerFromRecord() throws Exception {
        if (record.length != 3) {
            throw new Exception(INVALID_CUSTOMER_RECORD);
        }

        if (supplier == null) {
            throw new Exception(NO_SUPPLIER_FOR_CUSTOMER);
        }

        Customer existingCustomer = erpSystem.getCustomerSystem().listCustomer().stream().filter(customer -> customer.getIdentificationNumber().equals(record[2])).findAny().get();//TODO: deberiamos ver si existe o no el customer?

        supplier.addCustomer(existingCustomer);
    }

    private void loadNewCustomerFromRecord() throws Exception {
        if (record.length != 5) {
            throw new Exception(INVALID_CUSTOMER_RECORD);
        }

        if (supplier == null) {
            throw new Exception(NO_SUPPLIER_FOR_CUSTOMER);
        }

        supplier.addCustomer(new Customer(record[1], record[2], record[3], record[4]));
    }

    private void loadSupplierFromRecord() throws Exception {
        if (record.length != 4) {
            throw new Exception(INVALID_SUPPLIER_RECORD);
        }
        supplier = new Supplier(record[1], record[2], record[3]);
        erpSystem.getSupplierSystem().add(supplier);
    }

    private boolean isSupplierRecord() {
        return "S".equals(record[0]);
    }

    private boolean isCustomerRecord() {
        return isNewCustomerRecord() || isExistingCustomerRecord();
    }

    private boolean isAddressRecord() {
        return "A".equals(record[0]);
    }

    private boolean isNewCustomerRecord() {
        return "NC".equals(record[0]);
    }

    private boolean isExistingCustomerRecord() {
        return "EC".equals(record[0]);
    }
}
