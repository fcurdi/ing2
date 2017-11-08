package com.tenpines.advancetdd;

import junit.framework.TestCase;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import org.hibernate.service.ServiceRegistry;
import org.hibernate.service.ServiceRegistryBuilder;
import org.junit.Test;

import java.io.FileReader;
import java.io.IOException;
import java.io.LineNumberReader;
import java.util.List;
import java.util.stream.Collectors;

public class CustomerImportTest extends TestCase {

    private Session session;

    public void importCustomers() throws IOException {

        Configuration configuration = new Configuration();
        configuration.configure();

        ServiceRegistry serviceRegistry = new ServiceRegistryBuilder().applySettings(configuration.getProperties()).buildServiceRegistry();
        SessionFactory sessionFactory = configuration.buildSessionFactory(serviceRegistry);
        session = sessionFactory.openSession();
        session.beginTransaction();

        FileReader reader = new FileReader("resources/input.txt");
        LineNumberReader lineReader = new LineNumberReader(reader);

        Customer newCustomer = null;
        String line = lineReader.readLine();
        while (line != null) {
            if (line.startsWith("C")) {
                String[] customerData = line.split(",");
                newCustomer = new Customer();
                newCustomer.setFirstName(customerData[1]);
                newCustomer.setLastName(customerData[2]);
                newCustomer.setIdentificationType(customerData[3]);
                newCustomer.setIdentificationNumber(customerData[4]);
                session.persist(newCustomer);
            } else if (line.startsWith("A")) {
                String[] addressData = line.split(",");
                Address newAddress = new Address();

                newCustomer.addAddress(newAddress);
                newAddress.setStreetName(addressData[1]);
                newAddress.setStreetNumber(Integer.parseInt(addressData[2]));
                newAddress.setTown(addressData[3]);
                newAddress.setZipCode(Integer.parseInt(addressData[4]));
                newAddress.setProvince(addressData[3]);
            }

            line = lineReader.readLine();
        }

        reader.close();
    }

    public void tearDown() {
        session.getTransaction().commit();
        session.close();
    }

    //TODO: usando refactors automaticos:

    // assert de que si a la session le pido todos los cutomers -> = 2. ---> DONE

    //busco en los customers de la session el primero que aparece en el input.txt (osea por igualdad de los
    //atributos) y asserto que me encuentra uno solo. Este va a fallar porque hay un error en el customerImport(arreglarlo).
    //agarrar el unico que me trae (usando algo tipo anyOne y no first, podria no ser una lista) y assertar que todos los atributos son los que figuran en el input.txt

    //testear las direcciones de ese customer que agarre:
    //  -Traerme todas las direcciones de ese customer
    //  -Assertar que todos los atributos son los que estan en el input txt (para las dos direcciones) (aca falla porque hay otro error en la implementacion del customerImport, un fourth que deberia ser sixth)
    //  -Al hacer el assert de las dos direcciones, hay codigo repetido y rompe encapsulamiento (porque la customer le hago getAdresses y hago los asserts)
    //  -La solucion es al customer agregarle un addressAt: streetName (por ejemplo) y que eso me devuelva la address esa. Y hacer los asserts sobre eso
    //  -(dejo de usar el getAdresses y buscar la que me interesa en el test y uso adressAt: street)

    //Repetir todoo lo anterior tambien para el otro customer que hay en el input txt. (copy paste de lo anterior)

    //Desacoplar el file del customerImport. Hacer que el input sea de instancia. (sacar los
    //Dejar de leer de un archivo posta y poner los datos en el test (asi el test esta en control de todoo).
    //va a haber que cambiar el tipo de lo que lee el archivo...

    //Abstraer:
    // -sacar codigo repetido y dar semantica con los nombres (EXTRACT METHOD + RENAME)

    //Por ultimo, el customerImport sigue estando en la clase de test. Moverlo a una nueva clase (no de test): CustomerImporter (MOVE)
    // lo que va a pasar es que el CustomerImporter le va a pedir al test la session y el inputStream. Lo cual no esta bien. La solucion es que
    // el CustomerImport reciba ambos como colaboradores y que en el test, el mismo test se los pase. (ADD PARAMETER)

    //va a quedar que el test sabe buscar los customers en la base de datos... esto no esta bien (pero no hay que cambiarlo por ahora)
    //Ademas el test todavia sabe como es el mapeo de la base de datos... (tmp hay que cambiarlo por ahora)



    @Test
    public void test01(){
        try {
            importCustomers();

            List<Customer> customers = session.createCriteria(Customer.class).list();

            assertEquals(2, customers.size());

            List<Customer> customersMatched = customers.stream().filter(customer -> customer.getIdentificationNumber().equals("22333444")).collect(Collectors.toList());

            assertEquals(1, customersMatched.size());
            Customer pepeSanchez = customersMatched.stream().findAny().get();

            assertEquals("Pepe", pepeSanchez.getFirstName());
            assertEquals("Sanchez", pepeSanchez.getLastName());
            assertEquals("D", pepeSanchez.getIdentificationType());
            assertEquals("22333444", pepeSanchez.getIdentificationNumber());

            List<Address> addresses = session.createCriteria(Address.class).list();

            assertEquals(3, addresses.size());

            List<Address> addressesMatched = addresses.stream().filter(address -> address.getStreetName().equals("San Martin") || address.getStreetName().equals("Maipu")).collect(Collectors.toList());

            assertEquals(2, addressesMatched.size());

        } catch (Exception e) {
            fail(e.getMessage());
        }
    }

}
