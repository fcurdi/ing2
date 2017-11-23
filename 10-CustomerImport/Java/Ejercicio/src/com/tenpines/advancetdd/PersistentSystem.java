package com.tenpines.advancetdd;

import org.hibernate.Session;

import java.util.List;
import java.util.Optional;

public class PersistentSystem implements System {

    private Session session;

    public PersistentSystem(Session session) {
        this.session = session;
    }

    @Override
    public void start() {
    }

    @Override
    public void beginTransaction() {
        session.beginTransaction();
    }

    @Override
    public void commit() {
        session.getTransaction().commit();
    }

    @Override
    public void stop() {
        session.close();
    }

    @Override
    public void add(Party party) {
        session.persist(party);
    }

    @Override
    public List<? extends Party> listAll(Class<? extends Party> aClass) {
        return session.createCriteria(aClass).list();
    }

    @Override
    public Optional<? extends Party> findPartyWith(Identification identification) {
        return listAll(Party.class).stream().filter(party -> party.isIdentifiedBy(identification)).findAny();
    }
}
