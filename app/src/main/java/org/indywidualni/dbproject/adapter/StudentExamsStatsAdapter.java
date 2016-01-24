package org.indywidualni.dbproject.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.model.StudentExamsStats;

import java.util.ArrayList;

/**
 * Created by Krzysztof Grabowski on 23.01.16.
 * List adapter
 */
public class StudentExamsStatsAdapter extends ArrayAdapter<StudentExamsStats> {

    /**
     * Class constructor
     * @param context context
     * @param items items
     */
    public StudentExamsStatsAdapter(Context context, ArrayList<StudentExamsStats> items) {
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
        StudentExamsStats item = getItem(position);

        // Check if an existing view is being reused, otherwise inflate the view
        if (convertView == null)
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.list_item_student_stats, parent, false);

        TextView first = (TextView) convertView.findViewById(R.id.first);
        TextView second = (TextView) convertView.findViewById(R.id.second);
        TextView third = (TextView) convertView.findViewById(R.id.third);
        TextView fourth = (TextView) convertView.findViewById(R.id.fourth);

        /* App is in only one language so let's do a bad thing and leave hardcoded
         * strings. Normally strings should be got from resources and formatted.
         */
        String firstLine = item.getPrzedmiot() + " (poziom " + item.getPoziom() + ")";
        String secondLine = "Średni wynik: " + item.getSrednio() + " punktów  (" + item.getSrednioProcent()  + "%)";
        String thirdLine = item.getZdajacy() + " osób zdawało " + item.getTermin() + " termin";
        String fourthLine = "Zdawalność: " + item.getZdawalnosc() + "%";

        first.setText(firstLine);
        second.setText(secondLine);
        third.setText(thirdLine);
        fourth.setText(fourthLine);

        return convertView;
    }

}