package org.indywidualni.dbproject.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.model.StudentExam;

import java.util.ArrayList;

/**
 * Created by Krzysztof Grabowski on 23.01.16.
 * Array Adapter for student's exams. A List View can be populated because of
 * the existence of this adapter.
 */
public class StudentExamsAdapter extends ArrayAdapter<StudentExam> {

    public StudentExamsAdapter(Context context, ArrayList<StudentExam> items) {
        super(context, 0, items);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        StudentExam item = getItem(position);

        // Check if an existing view is being reused, otherwise inflate the view
        if (convertView == null)
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.list_item_student_exam, parent, false);

        TextView course = (TextView) convertView.findViewById(R.id.course);
        TextView info = (TextView) convertView.findViewById(R.id.info);
        TextView date = (TextView) convertView.findViewById(R.id.date);
        TextView passed = (TextView) convertView.findViewById(R.id.passed);

        /* App is in only one language so let's do a bad thing and leave hardcoded
         * strings. Normally strings should be got from resources and formatted.
         */
        String courseLine = item.getCourse() + " (poziom " + item.getLevel() + ")";
        String infoLine = "Wynik: " + item.getResult() + "  (" + item.getPercent() + "%)";
        String dateLine = "Rok: " + item.getYear() + "   Termin: " + item.getTime();
        String passedLine = item.getPassed() ? "ZDANY" : "NIE ZDANY";

        course.setText(courseLine);
        info.setText(infoLine);
        date.setText(dateLine);
        passed.setText(passedLine);

        return convertView;
    }

}