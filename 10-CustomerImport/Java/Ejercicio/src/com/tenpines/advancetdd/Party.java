package com.tenpines.advancetdd;

import javax.persistence.*;
import java.util.HashSet;
import java.util.Optional;
import java.util.Set;

@Entity
public abstract class Party {

    @Id
    @GeneratedValue
    protected long id;

    @OneToOne(cascade = CascadeType.ALL)
    protected Identification identification;

    @OneToMany(cascade = CascadeType.ALL)
    protected Set<Address> addresses;

    protected Party(String identificationType, String identificationNumber) {
        this.identification = new Identification(identificationType, identificationNumber);
        this.addresses = new HashSet<>();
    }

    public Optional<Address> addressAt(String streetName) {
        return addresses.stream().filter(address -> address.getStreetName().equals(streetName)).findAny();
    }

    public boolean isIdentifiedBy(Identification identification) {
        return this.identification.equals(identification);
    }

    public void addAddress(Address address) {
        addresses.add(address);
    }
}
