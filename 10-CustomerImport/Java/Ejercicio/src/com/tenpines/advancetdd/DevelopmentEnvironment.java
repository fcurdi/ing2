package com.tenpines.advancetdd;

public class DevelopmentEnvironment extends Environment {

    @Override
    protected boolean isCurrent() {
        return !(new IntegrationEnvironment()).isCurrent();
    }

    @Override
    protected ErpSystem system() {
        return new ErpSystem(new TransientCustomerSystem(), new TransientSupplierSystem());
    }
}
