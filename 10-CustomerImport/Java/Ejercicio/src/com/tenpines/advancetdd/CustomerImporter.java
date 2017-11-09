package com.tenpines.advancetdd;

import org.hibernate.Session;

import java.io.IOException;
import java.io.LineNumberReader;
import java.io.Reader;

public class CustomerImporter {

    //TODO: deberia seguir siendo static?
    public static void importCustomers(Session session, Reader reader) throws IOException {
        Customer newCustomer = null;
        LineNumberReader lineReader = new LineNumberReader(reader);
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
                newAddress.setProvince(addressData[5]);
            }

            line = lineReader.readLine();
        }
    }

}
