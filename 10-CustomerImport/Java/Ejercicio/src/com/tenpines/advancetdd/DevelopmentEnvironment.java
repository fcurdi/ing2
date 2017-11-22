package com.tenpines.advancetdd;

public class DevelopmentEnvironment extends Environment {

    @Override
    protected boolean isCurrent() {
        return !(new IntegrationEnvironment()).isCurrent();
    }

    @Override
    protected System system() {
        return new TransientSystem();
    }
}
