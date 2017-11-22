package com.tenpines.advancetdd;

import junit.framework.TestCase;

import java.io.Reader;
import java.io.StringReader;
import java.util.List;
import java.util.stream.Collectors;

import static com.tenpines.advancetdd.SupplierImporter.*;

public class SupplierImporterTest extends TestCase {

    private Reader reader;
    private SupplierImporter supplierImporter;
    private System system;

    @Override
    public void setUp() throws Exception {
        super.setUp();
        system = Environment.createSystem();
        supplierImporter = new SupplierImporter(system);
        system.start();
        system.beginTransaction();
    }

    @Override
    public void tearDown() throws Exception {
        super.tearDown();
        system.commit();
        system.stop();
        reader.close();
    }

    public void test01SuppliersAreImportedCorrectly() throws Exception {
        system.add(new Customer("Juan", "Perez", "D", "5456774"));

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
        assertTrue(system.listAll(Supplier.class).isEmpty());
    }

    private void assertSupplierWasImportedCorrectly() throws Exception {
        List<Supplier> suppliers = (List<Supplier>) system.listAll(Supplier.class);
        assertEquals(1, suppliers.size());

        Identification supplierIdentification = new Identification("D", "123");
        Supplier supplier = (Supplier) system.findPartyWith(supplierIdentification).orElseThrow(Exception::new);
        assertEquals("Supplier1", supplier.getName());

        Identification pepeSanchezIdentification = new Identification("D", "22333444");
        Customer pepeSanchez = supplier.customerWith(pepeSanchezIdentification).orElseThrow(Exception::new);
        assertEquals("Pepe", pepeSanchez.getFirstName());
        assertEquals("Sanchez", pepeSanchez.getLastName());

        Identification juanPerezIdentification = new Identification("D", "5456774");
        Customer juanPerez = supplier.customerWith(juanPerezIdentification).orElseThrow(Exception::new);
        assertEquals("Juan", juanPerez.getFirstName());
        assertEquals("Perez", juanPerez.getLastName());

        Address address = supplier.addressAt("San Martin").orElseThrow(Exception::new);
        assertEquals(3322, address.getStreetNumber());
        assertEquals("Olivos", address.getTown());
        assertEquals(1636, address.getZipCode());
        assertEquals("BsAs", address.getProvince());

        address = supplier.addressAt("Maipu").orElseThrow(Exception::new);
        assertEquals(888, address.getStreetNumber());
        assertEquals("Florida", address.getTown());
        assertEquals(1122, address.getZipCode());
        assertEquals("Buenos Aires", address.getProvince());
    }

}