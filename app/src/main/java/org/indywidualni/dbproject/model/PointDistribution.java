package org.indywidualni.dbproject.model;

/**
 * Created by Krzysztof Grabowski on 24.01.16.
 */
public class PointDistribution {

    public PointDistribution(int examID, int exercise, int max) {
        this.examID = examID;
        this.exercise = exercise;
        this.max = max;
    }

    private int examID;
    private int exercise;
    private int max;

    public int getExamID() {
        return examID;
    }

    public int getExercise() {
        return exercise;
    }

    public int getMax() {
        return max;
    }

}
