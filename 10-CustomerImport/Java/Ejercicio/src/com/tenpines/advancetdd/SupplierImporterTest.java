package com.tenpines.advancetdd;

import junit.framework.TestCase;

import java.io.Reader;

public class SupplierImporterTest extends TestCase {

    private SupplierSystem system;
    private Reader reader;
    private SupplierImporter supplierImporter;

    @Override
    public void setUp() throws Exception {
        super.setUp();
        system = Environment.createSystem().getSupplierSystem();
        supplierImporter = new SupplierImporter(system);
        system.start();
        system.beginTransaction();
    }

    @Override
    public void tearDown() throws Exception {
        super.tearDown();
        system.commit();
        system.stop();
        reader.close();
    }

    public void test01() {

    }
}