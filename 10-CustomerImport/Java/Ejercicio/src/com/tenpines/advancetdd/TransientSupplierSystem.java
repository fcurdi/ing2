package com.tenpines.advancetdd;

import java.util.ArrayList;
import java.util.List;

public class TransientSupplierSystem implements System<Supplier> {

    private List<Supplier> suppliers;

    @Override
    public void start() {
        suppliers = new ArrayList<>();
    }

    @Override
    public void add(Supplier supplier) {
        suppliers.add(supplier);
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
    public List<Supplier> list() {
        return suppliers;
    }
}
