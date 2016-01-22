package org.indywidualni.dbproject.fragment;

import android.app.Fragment;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;

/**
 * Created by Krzysztof Grabowski on 22.01.16.
 */
public class BaseFragment extends Fragment implements AdapterView.OnItemSelectedListener {

    public void onItemSelected(AdapterView<?> parent, View view,
                               int pos, long id) {
        // An item was selected. You can retrieve the selected item using
        // parent.getItemAtPosition(pos)
        Log.v(getClass().getName(), parent.getItemAtPosition(pos).toString());
    }

    public void onNothingSelected(AdapterView<?> parent) {
        // Another interface callback
    }

}
