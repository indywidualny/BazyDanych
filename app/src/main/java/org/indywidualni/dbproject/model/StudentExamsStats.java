package org.indywidualni.dbproject.model;

/**
 * Created by Krzysztof Grabowski on 23.01.16.
 */
public class StudentExamsStats {

    public StudentExamsStats(int rok, String przedmiot, int poziom,
                             int termin, int zdajacy, int srednio,
                             int srednioProcent, int zdawalnosc) {
        this.rok = rok;
        this.przedmiot = przedmiot;
        this.poziom = poziom;
        this.termin = termin;
        this.zdajacy = zdajacy;
        this.srednio = srednio;
        this.srednioProcent = srednioProcent;
        this.zdawalnosc = zdawalnosc;
    }

    private int rok;
    private String przedmiot;
    private int poziom;
    private int termin;
    private int zdajacy;
    private int srednio;
    private int srednioProcent;
    private int zdawalnosc;

    public String getPoziom() {
        return Integer.toString(poziom);
    }

    public String getRok() {
        return Integer.toString(rok);
    }

    public String getPrzedmiot() {
        return przedmiot;
    }

    public String getTermin() {
        return Integer.toString(termin);
    }

    public String getZdajacy() {
        return Integer.toString(zdajacy);
    }

    public String getSrednio() {
        return Integer.toString(srednio);
    }

    public String getSrednioProcent() {
        return Integer.toString(srednioProcent);
    }

    public String getZdawalnosc() {
        return Integer.toString(zdawalnosc);
    }

}
