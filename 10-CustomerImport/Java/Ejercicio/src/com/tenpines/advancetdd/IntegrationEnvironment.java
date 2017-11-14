package com.tenpines.advancetdd;

public class IntegrationEnvironment extends Environment {
    @Override
    protected boolean isCurrent() {
        return false;
    }

    @Override
    protected CustomerSystem system() {
        return new PersistentCustomerSystem();
    }
}
