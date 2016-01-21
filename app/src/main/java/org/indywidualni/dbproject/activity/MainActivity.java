package org.indywidualni.dbproject.activity;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.SQLException;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
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
public class MainActivity extends AppCompatActivity {

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
            }
        });

        // admin button onClick
        admin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                alertAdminDialog.show();
            }
        });
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.i(TAG, "OnDestroy: Close database connection");
        if (dataSource != null)
            dataSource.close();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
    }

    @SuppressLint("InflateParams")
    private AlertDialog createUserLoginDialog() {
        LayoutInflater inflater = LayoutInflater.from(this);
        final View view = inflater.inflate(R.layout.user_login_dialog, null);

        AlertDialog.Builder adb = new AlertDialog.Builder(this);
        adb.setView(view);

        final EditText pass = (EditText) view.findViewById(R.id.password);
        final EditText user = (EditText) view.findViewById(R.id.username);

        adb.setPositiveButton(getString(R.string.dialog_positive_login), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int id) {
                String pesel = user.getText().toString();
                String password = pass.getText().toString();

                try {
                    dataSource = MaturaDataSource.getInstance();
                    final String realPass = dataSource.getUserPassword(pesel);
                    if (password.equals(realPass)) {
                        Log.v(TAG, "user logged in");
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
        final View view = inflater.inflate(R.layout.admin_login_dialog, null);

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
                    Intent intent = new Intent(getApplicationContext(), AdminActivity.class);
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