package com.tenpines.advancetdd;

import java.util.List;

public interface CustomerSystem {

    void start();

    void stop();

    void add(Customer customer);

    List<Customer> listCustomer();
}
