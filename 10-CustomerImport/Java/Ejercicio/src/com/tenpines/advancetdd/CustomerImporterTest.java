package com.tenpines.advancetdd;

import junit.framework.TestCase;

import java.io.Reader;
import java.io.StringReader;
import java.util.List;

import static com.tenpines.advancetdd.CustomerImporter.*;

/**
 *
 * TODO: el tema del findCustomer y el tema de hacer los asserts de que es igual a otro, parte deberia
 * ser responsabilidad del customer (ver video?)
 *
 *
 * TODO: Ver mail:
 *  -poder importar suppliers.
 *  Formato de registros:
 *  NC -> new customer, trae todos los datos ya que hay que crear uno nuevo en el sistema
 *  EC -> existing customer, ya es un que existe.
 *  (Hay que asociar los customers al supplier)
 *  A,.... -> Direcciones del supplier
 *
 *
 *  ERP SYSTEM -> composicion (no es un composite) de CutomerSystem y SupplierSystem (cada uno tendra su implementacion de persistent y transient)
 *
 *  Tipo y numero de identificacion puede llegar a necesitar una abstraccion (ya que siempre los paso juntos)
 *
 *  Party (superclase), Customer (subclase), Supplier (subclase)
 *
 *  Se puede hacer una generalizacion para los dos importadores (SupplierImporter y CustomerImporter)
 */

public class CustomerImporterTest extends TestCase {

    private CustomerSystem system;
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
