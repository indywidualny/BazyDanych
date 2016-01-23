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
public class AdminFragment extends Fragment {

    private static final String TAG = AdminFragment.class.getSimpleName();

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_admin, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        Toast.makeText(getActivity(), getString(R.string.admin_logged_in),
                Toast.LENGTH_SHORT).show();
        Toast.makeText(getActivity(), getString(R.string.admin_permission),
                Toast.LENGTH_SHORT).show();
    }

}
