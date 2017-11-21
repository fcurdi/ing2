package com.tenpines.advancetdd;

public class ErpSystem {

    private System<Supplier> supplierSystem;

    private System<Customer> customerSystem;

    public ErpSystem(System<Customer> customerSystem, System<Supplier> supplierSystem) {
        this.customerSystem = customerSystem;
        this.supplierSystem = supplierSystem;
    }

    public System<Supplier> getSupplierSystem() {
        return supplierSystem;
    }

    public System<Customer> getCustomerSystem() {
        return customerSystem;
    }
}
