package com.tenpines.advancetdd;

import org.hibernate.validator.constraints.NotEmpty;

import javax.persistence.*;
import java.util.HashSet;
import java.util.Optional;
import java.util.Set;

@Entity
@Table(name = "CUSTOMERS")
public class Customer {

    @Id
    @GeneratedValue
    private long id;
    @NotEmpty
    private String firstName;
    @NotEmpty
    private String lastName;

    @OneToOne(cascade = CascadeType.ALL)
    private Identification identification;

    @OneToMany(cascade = CascadeType.ALL)
    private Set<Address> addresses;

    public Customer() {
        addresses = new HashSet<>();
    }

    public Customer(String firstName, String lastName, String identificationType, String identificationNumber) {
        this();
        this.firstName = firstName;
        this.lastName = lastName;
        this.identification = new Identification(identificationType, identificationNumber);
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public void addAddress(Address anAddress) {
        addresses.add(anAddress);
    }

    public Set<Address> getAddresses() {
        return addresses;
    }

    public Optional<Address> addressAt(String streetName) {
        return addresses.stream().filter(address -> address.getStreetName().equals(streetName)).findAny();
    }

    public Identification getIdentification() {
        return identification;
    }

    public boolean isIdentifiedBy(Identification identification){
        return this.identification.equals(identification);
    }
}
