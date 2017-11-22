package com.tenpines.advancetdd;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

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

    @Override
    public Optional<Supplier> findWith(Identification identification) {
        return suppliers.stream().filter(supplier -> supplier.isIdentifiedBy(identification)).findAny();

    }
}
