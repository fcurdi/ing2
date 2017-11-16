package com.tenpines.advancetdd;

public interface SupplierSystem {

    void add(Supplier supplier);

    void start();

    void beginTransaction();

    void commit();

    void stop();
}
