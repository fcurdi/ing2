package com.tenpines.advancetdd;

import java.util.List;

public interface SupplierSystem {

    void add(Supplier supplier);

    void start();

    void beginTransaction();

    void commit();

    void stop();

    List<Supplier> listSuppliers();
}
