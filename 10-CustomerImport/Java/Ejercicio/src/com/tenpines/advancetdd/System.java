package com.tenpines.advancetdd;

import java.util.List;
import java.util.Optional;

public interface System<T> {

    void start();

    void beginTransaction();

    void commit();

    void stop();

    void add(T entity);

    List<T> list();

    Optional<T> findWith(Identification identification);


}



