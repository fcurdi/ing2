package com.tenpines.advancetdd;

public class ErpSystem {

    private SupplierSystem supplierSystem;

    private CustomerSystem customerSystem;

    public ErpSystem(CustomerSystem customerSystem, SupplierSystem supplierSystem) {
        this.customerSystem = customerSystem;
        this.supplierSystem = supplierSystem;
    }

    public SupplierSystem getSupplierSystem() {
        return supplierSystem;
    }

    public CustomerSystem getCustomerSystem() {
        return customerSystem;
    }
}
