package org.indywidualni.dbproject.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.model.StudentExerciseResult;

import java.util.ArrayList;

/**
 * Created by Krzysztof Grabowski on 23.01.16.
 */
public class StudentExerciseResultsAdapter extends ArrayAdapter<StudentExerciseResult> {

    public StudentExerciseResultsAdapter(Context context, ArrayList<StudentExerciseResult> items) {
        super(context, 0, items);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        StudentExerciseResult item = getItem(position);

        // Check if an existing view is being reused, otherwise inflate the view
        if (convertView == null)
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.list_item_student_exercise, parent, false);

        TextView exercise = (TextView) convertView.findViewById(R.id.exercise);
        TextView description = (TextView) convertView.findViewById(R.id.description);
        TextView points = (TextView) convertView.findViewById(R.id.points);

        /* App is in only one language so let's do a bad thing and leave hardcoded
         * strings. Normally strings should be got from resources and formatted.
         */
        String exerciseLine = "Zadanie: " + item.getExercise();
        String descriptionLine = item.getDescription() == null ? "Brak komentarza" : item.getDescription();
        String pointsLine = "Punkty: " + item.getPoints();

        exercise.setText(exerciseLine);
        description.setText(descriptionLine);
        points.setText(pointsLine);

        return convertView;
    }

}