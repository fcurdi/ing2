package com.tenpines.advancetdd;

import junit.framework.TestCase;

import java.io.Reader;
import java.io.StringReader;
import java.util.List;

import static com.tenpines.advancetdd.SupplierImporter.*;

public class SupplierImporterTest extends TestCase {

    //TODO: No volvi a poner los tests que tienen que ver con cargar address y customers porque ya estan cubiertos
    // en el de customerImporter.

    private SupplierSystem system;
    private Reader reader;
    private SupplierImporter supplierImporter;

    @Override
    public void setUp() throws Exception {
        super.setUp();
        system = Environment.createSystem().getSupplierSystem();
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

    private void assertNoRecordsArePersistedAndExceptionIsRaiseWithMessage(String exceptionMessage) {
        try {
            supplierImporter.from(reader);
            fail();
        } catch (Exception e) {
            assertEquals(exceptionMessage, e.getMessage());
            assertSystemWithoutSuppliers();
        }
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
        List<Supplier> suppliers = system.listSuppliers();
        assertTrue(suppliers.isEmpty());
    }

    private void assertSupplierWasImportedCorrectly() {
        List<Supplier> suppliers = system.listSuppliers();
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


        // TODO: Como asserto el customer que ya existe?


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