package com.tenpines.advancetdd;

import java.util.List;

public interface System<T> {

    void start();

    void beginTransaction();

    void commit();

    void stop();

    void add(T entity);

    List<T> list();


}



