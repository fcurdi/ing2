package com.tenpines.advancetdd;

import org.hibernate.validator.constraints.NotEmpty;

import javax.persistence.*;
import javax.validation.constraints.Pattern;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "SUPPLIERS")
public class Supplier {

    @Id
    @GeneratedValue
    private long id;

    @NotEmpty
    private String name;

    @Pattern(regexp = "D")
    private String identificationType;

    @NotEmpty
    private String identificationNumber;

    @OneToMany(cascade = CascadeType.ALL)
    private Set<Address> addresses;

    @OneToMany(cascade = CascadeType.ALL)
    private Set<Customer> customers;

    public Supplier(String name, String identificationType, String identificationNumber) {
        this();
        this.name = name;
        this.identificationType = identificationType;
        this.identificationNumber = identificationNumber;
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

    public void setIdentificationType(String identificationType) {
        this.identificationType = identificationType;
    }

    public void setIdentificationNumber(String identificationNumber) {
        this.identificationNumber = identificationNumber;
    }

    public Address addressAt(String streetName) {
        return addresses.stream().filter(address -> address.getStreetName().equals(streetName)).findAny().get();
    }

    public Customer customerWith(String identificationNumber) {
        return customers.stream().filter(customer -> customer.getIdentificationNumber().equals(identificationNumber)).findAny().get();
    }

    public String getName() {
        return name;
    }

    public String getIdentificationType() {
        return identificationType;
    }

    public String getIdentificationNumber() {
        return identificationNumber;
    }
}