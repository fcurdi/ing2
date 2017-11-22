package com.tenpines.advancetdd;

import junit.framework.TestCase;

import java.io.Reader;
import java.io.StringReader;
import java.util.List;

import static com.tenpines.advancetdd.CustomerImporter.*;

public class CustomerImporterTest extends TestCase {

    private System<Customer> system;
    private Reader reader;
    private CustomerImporter customerImporter;

    @Override
    public void setUp() throws Exception {
        super.setUp();
        system = Environment.createSystem().getCustomerSystem();
        customerImporter = new CustomerImporter(system);
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

    public void test01CustomersAreImportedCorrectly() throws Exception {
        reader = getValidData();
        customerImporter.from(reader);

        assertSystemWithNumberOfCustomers(2);
        assertCustomerPepeSanchezWasImportedCorrectly();
        assertCustomerJuanPerezWasImportedCorrectly();
    }

    public void test02CannotImportFromAnEmptySource() throws Exception {
        reader = new StringReader("");
        customerImporter.from(reader);

        assertSystemWithNumberOfCustomers(0);
    }

    public void test03CannotImportAddressWithoutCustomer() {
        reader = new StringReader("A,San Martin,3322,Olivos,1636,BsAs");

        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(NO_CUSTOMER_FOR_ADDRESS);
    }

    public void test04CannotImportRecordWithInvalidRecordType() {
        reader = new StringReader("AX,Pepe,Sanchez,D,22333444");

        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(INVALID_RECORD_TYPE);
    }

    public void test05CannotImportCustomerWithLessInformationThanRequired() {
        reader = new StringReader("C,Pepe,D,22333444");

        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(INVALID_CUSTOMER_RECORD);
    }

    public void test06CannotImportAddressWithLessInformationThanRequired() {
        reader = new StringReader("A");

        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(INVALID_ADDRESS_RECORD);
    }

    public void test07CannotImportCustomerWithMoreInformationThanRequired() {
        reader = new StringReader("C,Pepe,D,22333444,1,1");

        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(INVALID_CUSTOMER_RECORD);
    }

    public void test08CannotImportAddressWithMoreInformationThanRequired() {
        reader = new StringReader("A,San Martin,3322,Olivos,1636,BsAs,BA");

        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(INVALID_ADDRESS_RECORD);
    }

    private void assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(String exceptionMessage) {
        try {
            customerImporter.from(reader);
            fail();
        } catch (Exception e) {
            assertEquals(exceptionMessage, e.getMessage());
            assertSystemWithNumberOfCustomers(0);
        }
    }

    private StringReader getValidData() {
        return new StringReader(
                "C,Pepe,Sanchez,D,22333444\n" +
                        "A,San Martin,3322,Olivos,1636,BsAs\n" +
                        "A,Maipu,888,Florida,1122,Buenos Aires\n" +
                        "C,Juan,Perez,C,23-25666777-9\n" +
                        "A,Alem,1122,CABA,1001,CABA"
        );
    }

    private void assertSystemWithNumberOfCustomers(int numberOfCustomers) {
        List<Customer> customers = system.list();
        assertEquals(numberOfCustomers, customers.size());
    }

    private void assertCustomerPepeSanchezWasImportedCorrectly() throws Exception {
        Identification identification = new Identification("D", "22333444");
        Customer pepeSanchez = system.findWith(identification).orElseThrow(Exception::new);

        assertEquals("Pepe", pepeSanchez.getFirstName());
        assertEquals("Sanchez", pepeSanchez.getLastName());

        Address address = pepeSanchez.addressAt("San Martin").orElseThrow(Exception::new);
        assertEquals(3322, address.getStreetNumber());
        assertEquals("Olivos", address.getTown());
        assertEquals(1636, address.getZipCode());
        assertEquals("BsAs", address.getProvince());

        address = pepeSanchez.addressAt("Maipu").orElseThrow(Exception::new);
        assertEquals(888, address.getStreetNumber());
        assertEquals("Florida", address.getTown());
        assertEquals(1122, address.getZipCode());
        assertEquals("Buenos Aires", address.getProvince());
    }

    private void assertCustomerJuanPerezWasImportedCorrectly() throws Exception {
        Identification identification = new Identification("C", "23-25666777-9");
        Customer juanPerez = system.findWith(identification).orElseThrow(Exception::new);

        assertEquals("Juan", juanPerez.getFirstName());
        assertEquals("Perez", juanPerez.getLastName());

        Address address = juanPerez.addressAt("Alem").orElseThrow(Exception::new);
        assertEquals(1122, address.getStreetNumber());
        assertEquals("CABA", address.getTown());
        assertEquals(1001, address.getZipCode());
        assertEquals("CABA", address.getProvince());
    }

}
