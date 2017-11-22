package com.tenpines.advancetdd;

import org.hibernate.Session;
import org.hibernate.cfg.Configuration;
import org.hibernate.service.ServiceRegistry;
import org.hibernate.service.ServiceRegistryBuilder;

public class IntegrationEnvironment extends Environment {

    @Override
    protected boolean isCurrent() {
        return false;
    }

    @Override
    protected System system() {
        Configuration configuration = new Configuration();
        configuration.configure();
        ServiceRegistry serviceRegistry = new ServiceRegistryBuilder().applySettings(configuration.getProperties()).buildServiceRegistry();
        Session session = configuration.buildSessionFactory(serviceRegistry).openSession();
        return new PersistentSystem(session);
    }
}
