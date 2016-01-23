package org.indywidualni.dbproject.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.model.AdminUser;

import java.util.ArrayList;

/**
 * Created by Krzysztof Grabowski on 23.01.16.
 */
public class AdminUsersAdapter extends ArrayAdapter<AdminUser> {

    public AdminUsersAdapter(Context context, ArrayList<AdminUser> items) {
        super(context, 0, items);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        AdminUser item = getItem(position);

        // Check if an existing view is being reused, otherwise inflate the view
        if (convertView == null)
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.list_item_admin_user, parent, false);

        TextView first = (TextView) convertView.findViewById(R.id.first);
        TextView second = (TextView) convertView.findViewById(R.id.second);
        TextView third = (TextView) convertView.findViewById(R.id.third);
        TextView fourth = (TextView) convertView.findViewById(R.id.fourth);
        TextView fifth = (TextView) convertView.findViewById(R.id.fifth);

        /* App is in only one language so let's do a bad thing and leave hardcoded
         * strings. Normally strings should be got from resources and formatted.
         */
        String firstLine = null;
        String secondLine = null;
        String thirdLine = null;
        String fourthLine = null;
        String fifthLine = null;
/*
        String courseLine = item.getCourse() + " (poziom " + item.getLevel() + ")";
        String infoLine = "Wynik: " + item.getResult() + "  (" + item.getPercent() + "%)";
        String dateLine = "Rok: " + item.getYear() + "   Termin: " + item.getTime();
        String passedLine = item.getPassed() ? "ZDANY" : "NIE ZDANY";
*/

        first.setText(firstLine);
        second.setText(secondLine);
        third.setText(thirdLine);
        fourth.setText(fourthLine);
        fifth.setText(fifthLine);

        return convertView;
    }

}