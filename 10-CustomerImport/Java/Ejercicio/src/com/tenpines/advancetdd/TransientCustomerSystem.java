package com.tenpines.advancetdd;

import java.util.ArrayList;
import java.util.List;

public class TransientCustomerSystem implements System<Customer> {

    private List<Customer> customers;

    @Override
    public void start() {
        customers = new ArrayList<>();
    }

    @Override
    public void beginTransaction() {
    }

    @Override
    public void commit() {
    }

    @Override
    public void stop() {
    }

    @Override
    public void add(Customer customer) {
        customers.add(customer);
    }

    @Override
    public List<Customer> list() {
        return customers;
    }
}
