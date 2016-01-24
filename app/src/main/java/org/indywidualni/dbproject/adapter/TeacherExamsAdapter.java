package org.indywidualni.dbproject.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.model.TeacherExam;

import java.util.ArrayList;

/**
 * Created by Krzysztof Grabowski on 24.01.16.
 * List adapter
 */
public class TeacherExamsAdapter extends ArrayAdapter<TeacherExam> {

    /**
     * Class constructor
     * @param context context
     * @param items items
     */
    public TeacherExamsAdapter(Context context, ArrayList<TeacherExam> items) {
        super(context, 0, items);
    }

    /**
     * Every list view item is processed here to make it look just
     * like I want to.
     * @param position position
     * @param convertView convertView
     * @param parent parent
     * @return a converted view
     */
    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        TeacherExam item = getItem(position);

        // Check if an existing view is being reused, otherwise inflate the view
        if (convertView == null)
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.list_item_teacher_exam, parent, false);

        TextView first = (TextView) convertView.findViewById(R.id.exam_info_first);
        TextView second = (TextView) convertView.findViewById(R.id.exam_info_second);
        TextView third = (TextView) convertView.findViewById(R.id.exam_info_third);

        /* App is in only one language so let's do a bad thing and leave hardcoded
         * strings. Normally strings should be got from resources and formatted.
         */
        String firstLine = item.getId() + ": " + item.getPrzedmiot() + " (poziom " + item.getPoziom() + ", termin: " + item.getTermin() + ")";
        String secondLine = "Rok: " + item.getRok();
        String thirdLine = "Punkty: " + item.getPunkty() + "   Zadań: " + item.getIloscZadan();

        first.setText(firstLine);
        second.setText(secondLine);
        third.setText(thirdLine);

        return convertView;
    }

}