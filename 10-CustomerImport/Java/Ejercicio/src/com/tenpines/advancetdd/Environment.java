package com.tenpines.advancetdd;

import java.util.Arrays;
import java.util.List;

public abstract class Environment {

    static private final List<Environment> environments = Arrays.asList(new IntegrationEnvironment(), new DevelopmentEnvironment());

    protected abstract boolean isCurrent();

    //TODO: rename
    protected abstract CustomerSystem system();

    //TODO: rename
    public static CustomerSystem createSystem() {
        Environment current = environments.stream()
                .filter((Environment::isCurrent))
                .findFirst()
                .orElse(new DevelopmentEnvironment());
        return current.system();
    }

}
