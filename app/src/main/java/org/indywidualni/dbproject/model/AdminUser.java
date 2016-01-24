package org.indywidualni.dbproject.model;

/**
 * Created by Krzysztof Grabowski on 23.01.16.
 */
public class AdminUser {

    public AdminUser(int pesel, String firstName, String secondName, String surname,
                     String bornDate, String street, String room, String house,
                     String city, int zipcode, int phone) {
        this.pesel = pesel;
        this.firstName = firstName;
        this.secondName = secondName;
        this.surname = surname;
        this.bornDate = bornDate;
        this.street = street;
        this.room = room;
        this.house = house;
        this.city = city;
        this.zipcode = zipcode;
        this.phone = phone;
    }

    private int pesel;
    private String firstName;
    private String secondName;
    private String surname;
    private String bornDate;
    private String street;
    private String room;
    private String house;
    private String city;
    private int zipcode;
    private int phone;

    public String getSecondName() {
        return secondName;
    }

    public String getPesel() {
        return Integer.toString(pesel);
    }

    public String getFirstName() {
        return firstName;
    }

    public String getSurname() {
        return surname;
    }

    public String getBornDate() {
        return bornDate;
    }

    public String getStreet() {
        return street;
    }

    public String getRoom() {
        return room;
    }

    public String getHouse() {
        return house;
    }

    public String getCity() {
        return city;
    }

    public String getZipcode() {
        return Integer.toString(zipcode);
    }

    public String getPhone() {
        return Integer.toString(phone);
    }

}
