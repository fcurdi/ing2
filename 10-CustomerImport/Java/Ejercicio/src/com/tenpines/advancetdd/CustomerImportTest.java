package com.tenpines.advancetdd;

import junit.framework.TestCase;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import org.hibernate.service.ServiceRegistry;
import org.hibernate.service.ServiceRegistryBuilder;
import org.junit.Test;

import java.io.Reader;
import java.io.StringReader;
import java.util.List;

public class CustomerImportTest extends TestCase {

    private Session session;
    private Reader reader;

    @Override
    public void setUp() throws Exception {
        super.setUp();
        Configuration configuration = new Configuration();
        configuration.configure();

        ServiceRegistry serviceRegistry = new ServiceRegistryBuilder().applySettings(configuration.getProperties()).buildServiceRegistry();
        SessionFactory sessionFactory = configuration.buildSessionFactory(serviceRegistry);
        session = sessionFactory.openSession();
        session.beginTransaction();

        reader = new StringReader(
                "C,Pepe,Sanchez,D,22333444\n" +
                        "A,San Martin,3322,Olivos,1636,BsAs\n" +
                        "A,Maipu,888,Florida,1122,Buenos Aires\n" +
                        "C,Juan,Perez,C,23-25666777-9\n" +
                        "A,Alem,1122,CABA,1001,CABA"
        );


    }

    @Override
    public void tearDown() throws Exception {
        super.tearDown();
        session.getTransaction().commit();
        session.close();

        reader.close();
    }

    private void assertCustomerPepeSanchezWasLoadedCorrectly(List<Customer> customers) {
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

    private void assertCustomerJuanPerezWasLoadedCorrectly(List<Customer> customers) {
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


    @Test
    public void test01() {
        try {
            //TODO: deberia estar dentro del findCustomers
            (new CustomerImporter(session)).from(reader);
            List<Customer> customers = session.createCriteria(Customer.class).list();
            assertEquals(2, customers.size());

            assertCustomerPepeSanchezWasLoadedCorrectly(customers);
            assertCustomerJuanPerezWasLoadedCorrectly(customers);
        } catch (Exception e) {
            fail(e.getMessage());
        }
    }


}
