package org.indywidualni.dbproject.models;

/**
 * Created by Krzysztof Grabowski on 20.01.16.
 */
public class StudentSummary {

    public StudentSummary(int pe, String fn, String s, int n, int pa, float a) {
        pesel = pe;
        firstName = fn;
        surname = s;
        numberOfExams = n;
        passedExams = pa;
        averageResult = a;
    }

    private int pesel;
    private String firstName;
    private String surname;
    private int numberOfExams;
    private int passedExams;
    private float averageResult;

    public String getNumberOfExams() {
        return Integer.toString(numberOfExams);
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

    public String getPassedExams() {
        return Integer.toString(passedExams);
    }

    public String getAverageResult() {
        return Float.toString(averageResult);
    }

}