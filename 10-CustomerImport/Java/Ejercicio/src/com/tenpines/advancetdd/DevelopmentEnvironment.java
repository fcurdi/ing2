package com.tenpines.advancetdd;

public class DevelopmentEnvironment extends Environment {

    //TODO: mas que true, deberia devolver que no es integration
    @Override
    protected boolean isCurrent() {
        return true;
    }

    @Override
    protected CustomerSystem system() {
        return new TransientCustomerSystem();
    }
}
