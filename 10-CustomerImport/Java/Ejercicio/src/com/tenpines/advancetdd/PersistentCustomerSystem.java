package com.tenpines.advancetdd;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import org.hibernate.service.ServiceRegistry;
import org.hibernate.service.ServiceRegistryBuilder;

import java.util.List;

public class PersistentCustomerSystem implements System<Customer> {

    private Session session;
    private final SessionFactory sessionFactory;

    public PersistentCustomerSystem() {
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
    public void add(Customer customer) {
        session.persist(customer);
    }

    @Override
    public List<Customer> list() {
        return session.createCriteria(Customer.class).list();
    }
}
