package com.tenpines.advancetdd;

public class IntegrationEnvironment extends Environment {

    @Override
    protected boolean isCurrent() {
        return false;
    }

    @Override
    protected ErpSystem system() {
        return new ErpSystem(new PersistentCustomerSystem(), new PersistentSupplierSystem());
    }
}
