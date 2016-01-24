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
 * List adapter
 */
public class AdminUsersAdapter extends ArrayAdapter<AdminUser> {

    /**
     * Class constructor
     * @param context context
     * @param items items
     */
    public AdminUsersAdapter(Context context, ArrayList<AdminUser> items) {
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
        String secondName = item.getSecondName() == null ? "" : (item.getSecondName() + " ");
        String streetHouse = (item.getRoom() == null ? "" : " " + (item.getRoom() + "/"))
                + (item.getHouse() == null ? "" : item.getHouse());
        String realPhone = item.getPhone() == null ? "Brak" : item.getPhone();
        realPhone = realPhone.equals("0") ? "brak" : realPhone;

        String firstLine = item.getFirstName() + " " + secondName + item.getSurname();
        String secondLine = "Adres: " + item.getStreet() + streetHouse + ", "
                + item.getZipcode() + " " + item.getCity();
        String thirdLine = "Numer kontaktowy: " + realPhone;
        String fourthLine = "Urodzony: " + item.getBornDate();
        String fifthLine = "PESEL: " + item.getPesel();

        first.setText(firstLine);
        second.setText(secondLine);
        third.setText(thirdLine);
        fourth.setText(fourthLine);
        fifth.setText(fifthLine);

        return convertView;
    }

}