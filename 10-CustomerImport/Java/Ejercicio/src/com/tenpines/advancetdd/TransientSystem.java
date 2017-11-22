package com.tenpines.advancetdd;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class TransientSystem implements System {

    private List<Party> storage;

    @Override
    public void start() {
        storage = new ArrayList<>();
    }

    @Override
    public void add(Party party) {
        storage.add(party);
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
    public List<? extends Party> listAll(Class<? extends Party> aClass) {
        return storage.stream().filter(party -> party.getClass() == aClass).collect(Collectors.toList());
    }

    @Override
    public Optional<Party> findPartyWith(Identification identification) {
        return storage.stream().filter(party -> party.isIdentifiedBy(identification)).findAny();

    }
}
