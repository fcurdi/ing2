package com.tenpines.advancetdd;

import java.util.Arrays;
import java.util.List;

public abstract class Environment {

    static private final List<Environment> environments = Arrays.asList(new IntegrationEnvironment(), new DevelopmentEnvironment());

    protected abstract boolean isCurrent();

    protected abstract ErpSystem system();

    public static ErpSystem createSystem() {
        Environment current = environments.stream()
                .filter(Environment::isCurrent)
                .findFirst().get();
        return current.system();
    }

}
