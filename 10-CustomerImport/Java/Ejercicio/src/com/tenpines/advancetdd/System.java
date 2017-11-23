package com.tenpines.advancetdd;

import java.util.List;
import java.util.Optional;

public interface System {

    void start();

    void beginTransaction();

    void commit();

    void stop();

    void add(Party entity);

    List<? extends Party> listAll(Class<? extends Party> aClass);

    Optional<? extends Party> findPartyWith(Identification identification);


}



