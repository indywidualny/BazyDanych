package org.indywidualni.dbproject.fragment;

import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import org.indywidualni.dbproject.R;

/**
 * Created by Krzysztof Grabowski on 22.01.16.
 */
public class PlaceholderFragment extends BaseFragment {

    private static final String TAG = PlaceholderFragment.class.getSimpleName();

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_placeholder, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        Log.v(TAG, "view created");
    }

}
