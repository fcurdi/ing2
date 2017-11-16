package com.tenpines.advancetdd;

import java.util.List;

public interface CustomerSystem {

    void start();

    void beginTransaction();

    void commit();

    void stop();

    void add(Customer customer);

    List<Customer> listCustomer();
}
