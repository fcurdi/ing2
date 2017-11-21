package com.tenpines.advancetdd;

import junit.framework.TestCase;

import java.io.Reader;
import java.io.StringReader;
import java.util.List;

import static com.tenpines.advancetdd.SupplierImporter.*;

public class SupplierImporterTest extends TestCase {

    private Reader reader;
    private SupplierImporter supplierImporter;
    private ErpSystem erpSystem;

    @Override
    public void setUp() throws Exception {
        super.setUp();
        erpSystem = Environment.createSystem();
        supplierImporter = new SupplierImporter(erpSystem);
        erpSystem.getCustomerSystem().start();
        erpSystem.getCustomerSystem().beginTransaction();
        erpSystem.getSupplierSystem().start();
        erpSystem.getSupplierSystem().beginTransaction();
    }

    @Override
    public void tearDown() throws Exception {
        super.tearDown();
        erpSystem.getCustomerSystem().commit();
        erpSystem.getCustomerSystem().stop();
        erpSystem.getSupplierSystem().commit();
        erpSystem.getSupplierSystem().stop();
        reader.close();
    }


    // FIXME: No anda con el persistent system. El problema es que cuando hace el start, hace un openSession()
    // FIXME: y ya hay una session abierta por el otro sistema.
    public void test01SuppliersAreImportedCorrectly() throws Exception {
        erpSystem.getCustomerSystem().add(new Customer("Juan", "Perez", "D", "5456774"));

        reader = getValidData();
        supplierImporter.from(reader);

        assertSupplierWasImportedCorrectly();
    }

    public void test02CannotImportFromAnEmptySource() throws Exception {
        reader = new StringReader("");
        supplierImporter.from(reader);
        assertSystemWithoutSuppliers();
    }

    public void test03CannotImportAddressWithoutSupplier() {
        reader = new StringReader("A,San Martin,3322,Olivos,1636,BsAs\n");
        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(NO_SUPPLIER_FOR_ADDRESS);
    }

    public void test04CannotImportNewCustomerWithoutSupplier() {
        reader = new StringReader("NC,Pepe,Sanchez,D,22333444");
        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(NO_SUPPLIER_FOR_CUSTOMER);
    }

    public void test05CannotImportExistingCustomerWithoutSupplier() {
        reader = new StringReader("EC,D,5456774");
        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(NO_SUPPLIER_FOR_CUSTOMER);
    }

    public void test06CannotImportSupplierWithLessInformationThanRequired() {
        reader = new StringReader("S,Supplier1");
        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(INVALID_SUPPLIER_RECORD);
    }

    public void test07CannotImportSupplierWithMoreInformationThanRequired() {
        reader = new StringReader("S,Supplier1,D,123,T,56");
        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(INVALID_SUPPLIER_RECORD);
    }

    public void test08CannotImportSupplierWithLessInformationThanRequired() {
        reader = new StringReader("EC,D,5456774,1122");
        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(INVALID_CUSTOMER_RECORD);
    }

    public void test09CannotImportSupplierWithMoreInformationThanRequired() {
        reader = new StringReader("EC,D");
        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(INVALID_CUSTOMER_RECORD);
    }

    public void test10CannotImportRecordWithInvalidRecordType() {
        reader = new StringReader("SS,Supplier1,D,123");
        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(INVALID_RECORD_TYPE);
    }

    public void test11CannotImportSupplierWithExistingCustomerIfItDoesNotReallyExist() throws Exception {
        reader = getValidData();
        assertExceptionIsRaisedWithMessage(CUSTOMER_DOES_NOT_EXIST);
    }

    private void assertExceptionIsRaisedWithMessage(String message) {
        try {
            supplierImporter.from(reader);
            fail();
        } catch (Exception e) {
            assertEquals(message, e.getMessage());
        }
    }

    private void assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(String message) {
        assertExceptionIsRaisedWithMessage(message);
        assertSystemWithoutSuppliers();
    }

    private StringReader getValidData() {
        return new StringReader(
                "S,Supplier1,D,123\n" +
                        "NC,Pepe,Sanchez,D,22333444\n" +
                        "EC,D,5456774\n" +
                        "A,San Martin,3322,Olivos,1636,BsAs\n" +
                        "A,Maipu,888,Florida,1122,Buenos Aires"
        );
    }

    private void assertSystemWithoutSuppliers() {
        assertTrue(erpSystem.getSupplierSystem().list().isEmpty());
    }

    private void assertSupplierWasImportedCorrectly() {
        List<Supplier> suppliers = erpSystem.getSupplierSystem().list();
        assertEquals(1, suppliers.size());

        Supplier supplier = suppliers.stream().findAny().get();
        assertEquals("Supplier1", supplier.getName());
        assertEquals("D", supplier.getIdentificationType());
        assertEquals("123", supplier.getIdentificationNumber());

        Customer pepeSanchez = supplier.customerWith("22333444");
        assertEquals("Pepe", pepeSanchez.getFirstName());
        assertEquals("Sanchez", pepeSanchez.getLastName());
        assertEquals("D", pepeSanchez.getIdentificationType());
        assertEquals("22333444", pepeSanchez.getIdentificationNumber());

        Customer juanPerez = supplier.customerWith("5456774");
        assertEquals("Juan", juanPerez.getFirstName());
        assertEquals("Perez", juanPerez.getLastName());
        assertEquals("D", juanPerez.getIdentificationType());
        assertEquals("5456774", juanPerez.getIdentificationNumber());

        Address address = supplier.addressAt("San Martin");
        assertEquals("San Martin", address.getStreetName());
        assertEquals(3322, address.getStreetNumber());
        assertEquals("Olivos", address.getTown());
        assertEquals(1636, address.getZipCode());
        assertEquals("BsAs", address.getProvince());

        address = supplier.addressAt("Maipu");
        assertEquals("Maipu", address.getStreetName());
        assertEquals(888, address.getStreetNumber());
        assertEquals("Florida", address.getTown());
        assertEquals(1122, address.getZipCode());
        assertEquals("Buenos Aires", address.getProvince());
    }

}