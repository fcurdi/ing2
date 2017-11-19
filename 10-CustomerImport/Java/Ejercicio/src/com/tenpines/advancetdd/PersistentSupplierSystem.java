package com.tenpines.advancetdd;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import org.hibernate.service.ServiceRegistry;
import org.hibernate.service.ServiceRegistryBuilder;

import java.util.List;

public class PersistentSupplierSystem implements SupplierSystem {

   private Session session;
    private final SessionFactory sessionFactory;

    public PersistentSupplierSystem() {
        Configuration configuration = new Configuration();
        configuration.configure();
        ServiceRegistry serviceRegistry = new ServiceRegistryBuilder().applySettings(configuration.getProperties()).buildServiceRegistry();
        sessionFactory = configuration.buildSessionFactory(serviceRegistry);
    }

    @Override
    public void start() {
        session = sessionFactory.openSession();
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
    public void add(Supplier supplier) {
        session.persist(supplier);
    }

    @Override
    public List<Supplier> listSuppliers() {
        return session.createCriteria(Supplier.class).list();
    }
}
