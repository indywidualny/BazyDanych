package org.indywidualni.dbproject.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.model.StudentSummary;

import java.util.ArrayList;

/**
 * Created by Krzysztof Grabowski on 24.01.16.
 */
public class TeacherStudentsAdapter extends ArrayAdapter<StudentSummary> {

    public TeacherStudentsAdapter(Context context, ArrayList<StudentSummary> items) {
        super(context, 0, items);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        StudentSummary item = getItem(position);

        // Check if an existing view is being reused, otherwise inflate the view
        if (convertView == null)
        convertView = LayoutInflater.from(getContext()).inflate(R.layout.list_item_teacher_student, parent, false);

        TextView info = (TextView) convertView.findViewById(R.id.info);
        TextView exams = (TextView) convertView.findViewById(R.id.exams);
        TextView average = (TextView) convertView.findViewById(R.id.average);

        /* App is in only one language so let's do a bad thing and leave hardcoded
         * strings. Normally strings should be got from resources and formatted.
         */
        String infoLine = item.getFirstName() + " " + item.getSurname() + " (PESEL: " + item.getPesel() + ")";
        String examsLine = "Zdawał: " + item.getNumberOfExams() + "   zaliczył: " + item.getPassedExams();
        String averageLine = "Średnia: " + item.getAverageResult() + "%";

        info.setText(infoLine);
        exams.setText(examsLine);
        average.setText(averageLine);

        return convertView;
    }

}