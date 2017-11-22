package com.tenpines.advancetdd;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;

@Entity
public class Identification {

    @Id
    @GeneratedValue
    private long id;

    private String identificationType;
    private String identificationNumber;

    public Identification(String identificationType, String identificationNumber) {
        this.identificationType = identificationType;
        this.identificationNumber = identificationNumber;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Identification that = (Identification) o;

        return identificationType.equals(that.identificationType) && identificationNumber.equals(that.identificationNumber);
    }

    @Override
    public int hashCode() {
        int result = identificationType.hashCode();
        result = 31 * result + identificationNumber.hashCode();
        return result;
    }

}
