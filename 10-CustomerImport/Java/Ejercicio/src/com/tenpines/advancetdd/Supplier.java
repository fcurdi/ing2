package com.tenpines.advancetdd;

import org.hibernate.validator.constraints.NotEmpty;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import java.util.HashSet;
import java.util.Optional;
import java.util.Set;

@Entity
@Table(name = "SUPPLIERS")
public class Supplier extends Party {

    @NotEmpty
    private String name;

    @OneToMany(cascade = CascadeType.ALL)
    private Set<Customer> customers;

    public Supplier(String name, String identificationType, String identificationNumber) {
        super(identificationType, identificationNumber);
        this.name = name;
        customers = new HashSet<>();
    }

    public Optional<Customer> customerWith(Identification identification) {
        return customers.stream().filter(customer -> customer.isIdentifiedBy(identification)).findAny();
    }

    public String getName() {
        return name;
    }

    public void addCustomer(Customer customer) {
        customers.add(customer);
    }

}
