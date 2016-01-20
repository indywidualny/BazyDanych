package org.indywidualni.dbproject.activity;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.DialogInterface;
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
import org.indywidualni.dbproject.database.CommentsDataSource;
import org.indywidualni.dbproject.models.Comment;
import org.indywidualni.dbproject.util.AeSimpleSHA1;

import java.io.UnsupportedEncodingException;
import java.security.NoSuchAlgorithmException;
import java.util.List;

/**
 * Created by Krzysztof Grabowski on 13.12.15.
 */
public class MainActivity extends AppCompatActivity {

    private static final String TAG = MainActivity.class.getSimpleName();
    private CommentsDataSource datasource;

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

        // TODO: Just an example. I have to figure it out
        datasource = new CommentsDataSource(this);
        datasource.open();
        List<Comment> values = datasource.getAllComments();
        for (Comment comment : values) {
            // print object identifiers
            Log.v(TAG, comment.toString());
        }

        // create dialogs now, one of them is gonna be used soon
        final AlertDialog alertUserDialog = createUserLoginDialog();
        final AlertDialog alertAdminDialog = createAdminLoginDialog();

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
                String username = user.getText().toString();
                String password = pass.getText().toString();
                Log.v(TAG, username);
                Log.v(TAG, password);
            }
        });

        adb.setNegativeButton(getString(R.string.dialog_negative_cancel), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int id) {
                dialog.cancel();
            }
        });

        adb.setCancelable(false);
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
                    // TODO: proceed, open another activity

                }
            }
        });

        adb.setNegativeButton(getString(R.string.dialog_negative_cancel), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int id) {
                dialog.cancel();
            }
        });

        adb.setCancelable(false);
        return adb.create();
    }

}