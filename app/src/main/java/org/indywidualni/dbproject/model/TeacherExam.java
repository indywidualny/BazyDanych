package org.indywidualni.dbproject.model;

/**
 * Created by Krzysztof Grabowski on 24.01.16.
 */
public class TeacherExam {

    public TeacherExam(int id, String przedmiot, int poziom, int rok, int termin, int punkty, int iloscZadan) {
        this.id = id;
        this.przedmiot = przedmiot;
        this.poziom = poziom;
        this.rok = rok;
        this.termin = termin;
        this.punkty = punkty;
        this.iloscZadan = iloscZadan;
    }

    private int id;
    private String przedmiot;
    private int poziom;
    private int rok;
    private int termin;
    private int punkty;
    private int iloscZadan;

    public String getId() {
        return Integer.toString(id);
    }

    public String getPrzedmiot() {
        return przedmiot;
    }

    public int getPoziom() {
        return poziom;
    }

    public int getRok() {
        return rok;
    }

    public int getTermin() {
        return termin;
    }

    public int getPunkty() {
        return punkty;
    }

    public int getIloscZadan() {
        return iloscZadan;
    }

}
