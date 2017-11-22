package com.tenpines.advancetdd;

import org.hibernate.validator.constraints.NotEmpty;

import javax.persistence.*;
import java.util.HashSet;
import java.util.Optional;
import java.util.Set;

@Entity
@Table(name = "SUPPLIERS")
public class Supplier {

    @Id
    @GeneratedValue
    private long id;

    @NotEmpty
    private String name;

    @OneToOne(cascade = CascadeType.ALL)
    private Identification identification;

    @OneToMany(cascade = CascadeType.ALL)
    private Set<Address> addresses;

    @OneToMany(cascade = CascadeType.ALL)
    private Set<Customer> customers;

    public Supplier(String name, String identificationType, String identificationNumber) {
        this();
        this.name = name;
        this.identification = new Identification(identificationType, identificationNumber);
    }

    public Supplier() {
        addresses = new HashSet<>();
        customers = new HashSet<>();
    }

    public void addAddress(Address address) {
        addresses.add(address);
    }

    public void addCustomer(Customer customer) {
        customers.add(customer);
    }

    public void setName(String name) {
        this.name = name;
    }


    public Optional<Address> addressAt(String streetName) {
        return addresses.stream().filter(address -> address.getStreetName().equals(streetName)).findAny();
    }

    public Optional<Customer> customerWith(Identification identification) {
        return customers.stream().filter(customer -> customer.isIdentifiedBy(identification)).findAny();
    }

    public String getName() {
        return name;
    }


    public Identification getIdentification() {
        return identification;
    }

    public boolean isIdentifiedBy(Identification identification){
        return this.identification.equals(identification);
    }

}
