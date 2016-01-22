package org.indywidualni.dbproject.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import org.indywidualni.dbproject.R;

/**
 * Created by Krzysztof Grabowski on 22.01.16.
 */
public class PlaceholderFragment extends Fragment {

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_placeholder, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
/*        Toast.makeText(getActivity(), getString(R.string.loading_view),
                Toast.LENGTH_SHORT).show();*/
    }

}
