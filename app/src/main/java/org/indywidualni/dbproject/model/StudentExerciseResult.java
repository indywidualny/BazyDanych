package org.indywidualni.dbproject.model;

/**
 * Created by Krzysztof Grabowski on 23.01.16.
 */
public class StudentExerciseResult {

    public StudentExerciseResult(int exercise, int points, String description) {
        this.exercise = exercise;
        this.points = points;
        this.description = description;
    }

    private int exercise;
    private int points;
    private String description;

    public String getDescription() {
        return description;
    }

    public String getExercise() {
        return Integer.toString(exercise);
    }

    public String getPoints() {
        return Integer.toString(points);
    }

}
