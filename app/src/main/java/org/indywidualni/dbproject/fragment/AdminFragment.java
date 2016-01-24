package org.indywidualni.dbproject.fragment;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.ListFragment;
import android.content.DialogInterface;
import android.database.SQLException;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.view.ContextMenu;
import android.view.LayoutInflater;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.Toast;

import org.indywidualni.dbproject.MyApplication;
import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.adapter.AdminUsersAdapter;
import org.indywidualni.dbproject.database.MaturaDataSource;
import org.indywidualni.dbproject.model.AdminUser;
import org.indywidualni.dbproject.util.AeSimpleSHA1;

import java.io.UnsupportedEncodingException;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;

/**
 * Created by Krzysztof Grabowski on 22.01.16.
 */
public class AdminFragment extends ListFragment implements AdapterView.OnItemClickListener {

    private static final String TAG = AdminFragment.class.getSimpleName();
    private MaturaDataSource dataSource = MaturaDataSource.getInstance();
    private ArrayList<AdminUser> users;
    private static String peselCallback;

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
        if (users != null && users.size() > 0) {
            peselCallback = users.get(position).getPesel();
            // register a menu here, a dirty hack to get rid of onLongClickListener
            registerForContextMenu(getListView());
            getActivity().openContextMenu(getListView());
        }
    }

    public void onCreateContextMenu(ContextMenu menu, View v,
                                    ContextMenu.ContextMenuInfo menuInfo) {
        super.onCreateContextMenu(menu, v, menuInfo);

        MenuInflater inflater = getActivity().getMenuInflater();
        inflater.inflate(R.menu.context_menu_admin_users, menu);
        // deregister a menu here, a dirty hack to get rid of onLongClickListener
        unregisterForContextMenu(getListView());
    }

    @Override
    public boolean onContextItemSelected(MenuItem item) {
        switch(item.getItemId()) {
            case R.id.change_password:
                Log.v("AdminFragment", "Change password for PESEL: " + peselCallback);

                final AlertDialog changePasswordDialog = createChangePasswordDialog(peselCallback);
                changePasswordDialog.show();
                changePasswordDialog.getButton(DialogInterface.BUTTON_POSITIVE)
                        .setTextColor(ContextCompat.getColor(MyApplication.getContextOfApplication(), R.color.colorAccent));
                changePasswordDialog.getButton(DialogInterface.BUTTON_NEGATIVE)
                        .setTextColor(ContextCompat.getColor(MyApplication.getContextOfApplication(), R.color.colorAccent));
            break;
        }
        return super.onContextItemSelected(item);
    }

    @SuppressLint("InflateParams")
    private AlertDialog createChangePasswordDialog(final String pesel) {
        LayoutInflater inflater = LayoutInflater.from(getActivity());
        final View view = inflater.inflate(R.layout.dialog_admin_change_pass, null);

        AlertDialog.Builder adb = new AlertDialog.Builder(getActivity());
        adb.setView(view);

        final EditText pass = (EditText) view.findViewById(R.id.new_password);

        adb.setPositiveButton(getString(R.string.change_password_positive), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int id) {
                String passwordHash = null;

                // password cannot be too short
                if (pass.getText().toString().length() < 5) {
                    Toast.makeText(getActivity(), getString(R.string.pass_too_short),
                            Toast.LENGTH_SHORT).show();
                    return;
                }

                // create a salted hash of the given password
                try {
                    passwordHash = AeSimpleSHA1.SHA1(pass.getText().toString());
                } catch (NoSuchAlgorithmException e) {
                    Toast.makeText(getActivity(), getString(R.string.no_such_algorithm),
                            Toast.LENGTH_SHORT).show();
                    e.printStackTrace();
                } catch (UnsupportedEncodingException e) {
                    Toast.makeText(getActivity(), getString(R.string.unsupported_encoding),
                            Toast.LENGTH_SHORT).show();
                    e.printStackTrace();
                }

                // if everything is ok query the database
                if (passwordHash != null) {
                    try {
                        dataSource.changeUserPassword(pesel, passwordHash);

                        Toast.makeText(getActivity(), getString(R.string.password_changed),
                                Toast.LENGTH_SHORT).show();
                    } catch (SQLException e) {
                        Toast.makeText(getActivity(), getString(R.string.password_not_changed),
                                Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(getActivity(), getString(R.string.wrong_password),
                            Toast.LENGTH_SHORT).show();
                }
            }
        });

        adb.setNegativeButton(getString(R.string.change_password_negative), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int id) {
                dialog.cancel();
            }
        });

        adb.setCancelable(true);
        return adb.create();
    }

}
