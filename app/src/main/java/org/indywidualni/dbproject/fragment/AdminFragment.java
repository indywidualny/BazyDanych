package org.indywidualni.dbproject.fragment;

import android.app.ListFragment;
import android.database.SQLException;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.Toast;

import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.adapter.AdminUsersAdapter;
import org.indywidualni.dbproject.database.MaturaDataSource;
import org.indywidualni.dbproject.model.AdminUser;

import java.util.ArrayList;

/**
 * Created by Krzysztof Grabowski on 22.01.16.
 */
public class AdminFragment extends ListFragment implements AdapterView.OnItemClickListener {

    private static final String TAG = AdminFragment.class.getSimpleName();
    private MaturaDataSource dataSource = MaturaDataSource.getInstance();
    private ArrayList<AdminUser> users;

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

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        try {
            users = dataSource.getAllUsers();
            AdminUsersAdapter adapter = new AdminUsersAdapter(getActivity(), users);
            setListAdapter(adapter);
            getListView().setOnItemClickListener(this);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        Toast.makeText(getActivity(), "Item: " + position + " " + users.get(position).getFirstName(), Toast.LENGTH_SHORT).show();
    }

}
