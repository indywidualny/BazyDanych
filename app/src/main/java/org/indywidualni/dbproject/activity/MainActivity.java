package org.indywidualni.dbproject.activity;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.SQLException;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import org.indywidualni.dbproject.MyApplication;
import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.database.MaturaDataSource;
import org.indywidualni.dbproject.util.AeSimpleSHA1;

import java.io.UnsupportedEncodingException;
import java.security.NoSuchAlgorithmException;

/**
 * Created by Krzysztof Grabowski on 13.12.15.
 */
public class MainActivity extends BaseActivity {

    private static final String TAG = MainActivity.class.getSimpleName();
    private MaturaDataSource dataSource;
    private AlertDialog alertUserDialog;
    private AlertDialog alertAdminDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // app toolbar with actionbar support
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        /** Let's instantiate a database helper. */
        dataSource = MaturaDataSource.getInstance();

        /** Create/upgrade database now in order to skip this part
         *  during the next data retrieval.
         */
        new PrepareDatabase().execute();

        // bind buttons to the layout
        final Button user = (Button) findViewById(R.id.button1);
        final Button admin = (Button) findViewById(R.id.button2);

        // create dialogs now, one of them is gonna be used soon
        alertUserDialog = createUserLoginDialog();
        alertAdminDialog = createAdminLoginDialog();

        // user button onClick
        user.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                alertUserDialog.show();
                alertUserDialog.getButton(DialogInterface.BUTTON_POSITIVE)
                        .setTextColor(ContextCompat.getColor(getApplicationContext(), R.color.colorAccent));
                alertUserDialog.getButton(DialogInterface.BUTTON_NEGATIVE)
                        .setTextColor(ContextCompat.getColor(getApplicationContext(), R.color.colorAccent));
            }
        });

        // admin button onClick
        admin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                alertAdminDialog.show();
                alertAdminDialog.getButton(DialogInterface.BUTTON_POSITIVE)
                        .setTextColor(ContextCompat.getColor(getApplicationContext(), R.color.colorAccent));
                alertAdminDialog.getButton(DialogInterface.BUTTON_NEGATIVE)
                        .setTextColor(ContextCompat.getColor(getApplicationContext(), R.color.colorAccent));
            }
        });
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
    }

    /** Database creation takes some time and should not be done on UI thread.
     *  We need an AsyncTask to do it properly.
     */
    private class PrepareDatabase extends AsyncTask<Void, Void, Void> {

        @Override
        protected Void doInBackground(Void... arg0) {
            try {
                dataSource.emptyConnection();
            } catch (SQLException e) {
                Log.e(TAG, "database connection problem, not good");
                e.printStackTrace();
            }
            return null;
        }

    }

    @SuppressLint("InflateParams")
    private AlertDialog createUserLoginDialog() {
        LayoutInflater inflater = LayoutInflater.from(this);
        final View view = inflater.inflate(R.layout.dialog_login_user, null);

        AlertDialog.Builder adb = new AlertDialog.Builder(this);
        adb.setView(view);

        final EditText pass = (EditText) view.findViewById(R.id.password);
        final EditText user = (EditText) view.findViewById(R.id.username);

        adb.setPositiveButton(getString(R.string.dialog_positive_login), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int id) {
                String pesel = user.getText().toString();
                String password = pass.getText().toString();
                String passwordHash = null;

                try {
                    passwordHash = AeSimpleSHA1.SHA1(password);
                } catch (NoSuchAlgorithmException e) {
                    Toast.makeText(getApplicationContext(), getString(R.string.no_such_algorithm),
                            Toast.LENGTH_SHORT).show();
                    e.printStackTrace();
                } catch (UnsupportedEncodingException e) {
                    Toast.makeText(getApplicationContext(), getString(R.string.unsupported_encoding),
                            Toast.LENGTH_SHORT).show();
                    e.printStackTrace();
                }

                try {
                    if (passwordHash != null && passwordHash.equals(dataSource.getUserPassword(pesel))) {
                        Intent intent = new Intent(MainActivity.this, UserActivity.class);
                        intent.putExtra("pesel", pesel);
                        if (!dataSource.getIsUserTeacher(pesel)) {
                            Log.v(TAG, "student logged in");
                            intent.putExtra("teacher", false);
                            startActivity(intent);
                        } else {
                            Log.v(TAG, "teacher logged in");
                            intent.putExtra("teacher", true);
                            startActivity(intent);
                        }
                    } else {
                        Toast.makeText(getApplicationContext(), getString(R.string.wrong_password),
                                Toast.LENGTH_SHORT).show();
                    }
                } catch (SQLException e) {
                    Toast.makeText(getApplicationContext(), getString(R.string.wrong_user),
                            Toast.LENGTH_SHORT).show();
                    e.printStackTrace();
                }
            }
        });

        adb.setNegativeButton(getString(R.string.dialog_negative_cancel), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int id) {
                dialog.cancel();
            }
        });

        adb.setCancelable(true);
        return adb.create();
    }

    @SuppressLint("InflateParams")
    private AlertDialog createAdminLoginDialog() {
        LayoutInflater inflater = LayoutInflater.from(this);
        final View view = inflater.inflate(R.layout.dialog_login_admin, null);

        AlertDialog.Builder adb = new AlertDialog.Builder(this);
        adb.setView(view);

        final EditText pass = (EditText) view.findViewById(R.id.password);

        adb.setPositiveButton(getString(R.string.dialog_positive_login), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int id) {
                String passwordHash = null;

                try {
                    passwordHash = AeSimpleSHA1.SHA1(pass.getText().toString());
                } catch (NoSuchAlgorithmException e) {
                    Toast.makeText(getApplicationContext(), getString(R.string.no_such_algorithm),
                            Toast.LENGTH_SHORT).show();
                    e.printStackTrace();
                } catch (UnsupportedEncodingException e) {
                    Toast.makeText(getApplicationContext(), getString(R.string.unsupported_encoding),
                            Toast.LENGTH_SHORT).show();
                    e.printStackTrace();
                }

                if (passwordHash != null && passwordHash.equals(MyApplication.getAdminPassword())) {
                    Log.v(TAG, "admin logged in");
                    final Intent intent = new Intent(getApplicationContext(), AdminActivity.class);
                    startActivity(intent);
                } else {
                    Toast.makeText(getApplicationContext(), getString(R.string.wrong_password),
                            Toast.LENGTH_SHORT).show();
                }
            }
        });

        adb.setNegativeButton(getString(R.string.dialog_negative_cancel), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int id) {
                dialog.cancel();
            }
        });

        adb.setCancelable(true);
        return adb.create();
    }

}