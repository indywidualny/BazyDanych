package org.indywidualni.dbproject.models;

/**
 * Created by Krzysztof Grabowski on 20.01.16.
 */
public class Uczen {

    private long id;
    private String firstName;
    private String surname;
    private int number1;
    private int number2;
    private int avrg;

    public int getNumber1() {
        return number1;
    }

    public void setNumber1(int number1) {
        this.number1 = number1;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getSurname() {
        return surname;
    }

    public void setSurname(String surname) {
        this.surname = surname;
    }

    public int getNumber2() {
        return number2;
    }

    public void setNumber2(int number2) {
        this.number2 = number2;
    }

    public int getAvrg() {
        return avrg;
    }

    public void setAvrg(int avrg) {
        this.avrg = avrg;
    }

}