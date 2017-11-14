package com.tenpines.advancetdd;

public class DevelopmentEnvironment extends Environment {
    @Override
    protected boolean isCurrent() {
        return true;
    }

    @Override
    protected CustomerSystem system() {
        return new TransientCustomerSystem();
    }
}
