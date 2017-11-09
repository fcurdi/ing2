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
import java.util.Arrays;
import java.util.List;

public class CustomerImportTest extends TestCase {

    private Session session;
    private Reader reader;

    private Customer pepeSanchez;
    private Customer juanPerez;

    private Address sanMartinAddress;
    private Address maipuAddress;
    private Address alemAddress;

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
        sanMartinAddress = new Address();
        sanMartinAddress.setStreetName("San Martin");
        sanMartinAddress.setStreetNumber(3322);
        sanMartinAddress.setTown("Olivos");
        sanMartinAddress.setZipCode(1636);
        sanMartinAddress.setProvince("BsAs");

        maipuAddress = new Address();
        maipuAddress.setStreetName("Maipu");
        maipuAddress.setStreetNumber(888);
        maipuAddress.setTown("Florida");
        maipuAddress.setZipCode(1122);
        maipuAddress.setProvince("Buenos Aires");

        alemAddress = new Address();
        alemAddress.setStreetName("Alem");
        alemAddress.setStreetNumber(1122);
        alemAddress.setTown("CABA");
        alemAddress.setZipCode(1001);
        alemAddress.setProvince("CABA");

        pepeSanchez = new Customer();
        pepeSanchez.setIdentificationType("D");
        pepeSanchez.setIdentificationNumber("22333444");
        pepeSanchez.setFirstName("Pepe");
        pepeSanchez.setLastName("Sanchez");

        juanPerez = new Customer();
        juanPerez.setIdentificationType("C");
        juanPerez.setIdentificationNumber("23-25666777-9");
        juanPerez.setFirstName("Juan");
        juanPerez.setLastName("Perez");
    }

    @Override
    public void tearDown() throws Exception {
        super.tearDown();
        session.getTransaction().commit();
        session.close();

        reader.close();
    }

    private void assertCustomerWasLoadedCorrectly(Customer customer, Customer expectedCustomer, Address... expectedAddresses) {
        assertEquals(expectedCustomer.getFirstName(), customer.getFirstName());
        assertEquals(expectedCustomer.getLastName(), customer.getLastName());
        assertEquals(expectedCustomer.getIdentificationType(), customer.getIdentificationType());
        assertEquals(expectedCustomer.getIdentificationNumber(), customer.getIdentificationNumber());

        assertAddressesLoadedCorrectlyForCustomer(customer, expectedAddresses);
    }

    private void assertAddressesLoadedCorrectlyForCustomer(Customer customer, Address... expectedAddresses) {
        Arrays.stream(expectedAddresses).forEach(expectedAddress -> {
            Address address = customer.addressAt(expectedAddress.getStreetName());

            assertEquals(expectedAddress.getStreetName(), address.getStreetName());
            assertEquals(expectedAddress.getStreetNumber(), address.getStreetNumber());
            assertEquals(expectedAddress.getTown(), address.getTown());
            assertEquals(expectedAddress.getZipCode(), address.getZipCode());
            assertEquals(expectedAddress.getProvince(), address.getProvince());
        });

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

            //TODO: Esto deberia estar dentro del findCustomer?
            CustomerImporter.importCustomers(session, reader);
            List<Customer> customers = session.createCriteria(Customer.class).list();
            assertEquals(2, customers.size());

            Customer pepe = findCustomerWithIdentificationNumber(customers, "22333444");
            Customer juan = findCustomerWithIdentificationNumber(customers, "23-25666777-9");
            assertCustomerWasLoadedCorrectly(pepe, pepeSanchez, sanMartinAddress, maipuAddress);
            assertCustomerWasLoadedCorrectly(juan, juanPerez, alemAddress);
        } catch (Exception e) {
            fail(e.getMessage());
        }
    }


}
