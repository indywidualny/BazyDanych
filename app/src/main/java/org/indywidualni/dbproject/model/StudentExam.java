package org.indywidualni.dbproject.model;

/**
 * Created by Krzysztof Grabowski on 23.01.16.
 */
public class StudentExam {

    public StudentExam(String c, int l, int y, int t, int r, int p, boolean pass) {
        course = c;
        level = l;
        year = y;
        time = t;
        result = r;
        percent = p;
        passed = pass;
    }

    private String course;
    private int level;
    private int year;
    private int time;
    private int result;
    private int percent;
    private boolean passed;

    public String getCourse() {
        return course;
    }

    public String getLevel() {
        return Integer.toString(level);
    }

    public String getYear() {
        return Integer.toString(year);
    }

    public String getTime() {
        return Integer.toString(time);
    }

    public String getResult() {
        return Integer.toString(result);
    }

    public String getPercent() {
        return Integer.toString(percent);
    }

    public boolean getPassed() {
        return passed;
    }

}
