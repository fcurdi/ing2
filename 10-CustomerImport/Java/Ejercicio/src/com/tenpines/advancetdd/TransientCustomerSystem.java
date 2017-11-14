package com.tenpines.advancetdd;

import java.util.ArrayList;
import java.util.List;

public class TransientCustomerSystem implements CustomerSystem {

    List<Customer> customers;

    public TransientCustomerSystem() {
        customers = new ArrayList<>();
    }

    @Override
    public void start() {
    }

    @Override
    public void stop() {
    }

    @Override
    public void add(Customer customer) {
        customers.add(customer);
    }

    @Override
    public List<Customer> listCustomer() {
        return customers;
    }
}
