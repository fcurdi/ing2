package com.tenpines.advancetdd;

import junit.framework.TestCase;

import java.io.Reader;
import java.io.StringReader;
import java.util.List;

import static com.tenpines.advancetdd.CustomerImporter.*;

/**
 * TODO: renombrar tests
 */

public class CustomerImportTest extends TestCase {

    private CustomerSystem system;
    private Reader reader;
    private CustomerImporter customerImporter;

    @Override
    public void setUp() throws Exception {
        super.setUp();
        system = Environment.createSystem();
        customerImporter = new CustomerImporter(system);
        system.start();
    }

    @Override
    public void tearDown() throws Exception {
        super.tearDown();
        system.commit();
        system.stop();
        reader.close();
    }

    private void assertCustomerPepeSanchezWasImportedCorrectly(List<Customer> customers) {
        Customer pepeSanchez = findCustomerWithIdentificationNumber(customers, "22333444");

        assertEquals("Pepe", pepeSanchez.getFirstName());
        assertEquals("Sanchez", pepeSanchez.getLastName());
        assertEquals("D", pepeSanchez.getIdentificationType());
        assertEquals("22333444", pepeSanchez.getIdentificationNumber());

        Address address = pepeSanchez.addressAt("San Martin");
        assertEquals("San Martin", address.getStreetName());
        assertEquals(3322, address.getStreetNumber());
        assertEquals("Olivos", address.getTown());
        assertEquals(1636, address.getZipCode());
        assertEquals("BsAs", address.getProvince());

        address = pepeSanchez.addressAt("Maipu");
        assertEquals("Maipu", address.getStreetName());
        assertEquals(888, address.getStreetNumber());
        assertEquals("Florida", address.getTown());
        assertEquals(1122, address.getZipCode());
        assertEquals("Buenos Aires", address.getProvince());
    }

    private void assertCustomerJuanPerezWasImportedCorrectly(List<Customer> customers) {
        Customer juanPerez = findCustomerWithIdentificationNumber(customers, "23-25666777-9");

        assertEquals("Juan", juanPerez.getFirstName());
        assertEquals("Perez", juanPerez.getLastName());
        assertEquals("C", juanPerez.getIdentificationType());
        assertEquals("23-25666777-9", juanPerez.getIdentificationNumber());

        Address address = juanPerez.addressAt("Alem");
        assertEquals("Alem", address.getStreetName());
        assertEquals(1122, address.getStreetNumber());
        assertEquals("CABA", address.getTown());
        assertEquals(1001, address.getZipCode());
        assertEquals("CABA", address.getProvince());
    }

    private Customer findCustomerWithIdentificationNumber(List<Customer> customers, String identificationNumber) {
        return customers
                .stream()
                .filter(customer -> customer.getIdentificationNumber().equals(identificationNumber))
                .findAny().get();
    }

    public void test01CustomersAreImportedCorrectly() throws Exception {
        //TODO: deberia estar dentro del findCustomers
        reader = getValidData();
        customerImporter.from(reader);
        List<Customer> customers = system.listCustomer();
        assertEquals(2, customers.size());

        assertCustomerPepeSanchezWasImportedCorrectly(customers);
        assertCustomerJuanPerezWasImportedCorrectly(customers);
    }

    public void test02CannotImportFromAnEmptySource() throws Exception {
        reader = new StringReader("");
        customerImporter.from(reader);
        assertSystemWithoutCustomers();
    }

    public void test03CannotImportAddressWithoutCustomer() {
        reader = new StringReader("A,San Martin,3322,Olivos,1636,BsAs\n");
        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(NO_CUSTOMER_FOR_ADDRESS);
    }

    public void test04CannotImportCustomerWithInvalidRecordType() {
        reader = new StringReader("AX,Pepe,Sanchez,D,22333444\n");
        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(INVALID_RECORD_TYPE);
    }

    public void test05() {
        reader = new StringReader("C,Pepe,D,22333444\n");
        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(INVALID_CUSTOMER_RECORD);
    }

    public void test06() {
        reader = new StringReader("A\n");
        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(INVALID_ADDRESS_RECORD);
    }

    public void test07() {
        reader = new StringReader("C,Pepe,D,22333444,1,1");
        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(INVALID_CUSTOMER_RECORD);
    }

    public void test08() {
        reader = new StringReader("A,San Martin,3322,Olivos,1636,BsAs,BA");
        assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(INVALID_ADDRESS_RECORD);
    }

    private void assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(String exceptionMessage) {
        try {
            customerImporter.from(reader);
            fail();
        } catch (Exception e) {
            assertEquals(exceptionMessage, e.getMessage());
            assertSystemWithoutCustomers();
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

    private void assertSystemWithoutCustomers() {
        List<Customer> customers = system.listCustomer();
        assertEquals(0, customers.size());
    }

}
