package org.indywidualni.dbproject.activity;

import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.widget.Toast;

import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.fragment.StudentFragment;
import org.indywidualni.dbproject.fragment.TeacherFragment;

/**
 * Created by Krzysztof Grabowski on 22.01.16.
 */
public class UserActivity extends BaseActivity {

    private static final String TAG = UserActivity.class.getSimpleName();
    public static String pesel;
    public static boolean isTeacher;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user);

        // app toolbar with actionbar support
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setDisplayShowHomeEnabled(true);
            getSupportActionBar().setDisplayShowTitleEnabled(false);
        }

        // get string extras
        Bundle extras = getIntent().getExtras();
        if (extras != null) {
            pesel = extras.getString("pesel");
            isTeacher = extras.getBoolean("teacher");
        }

        Log.v(TAG, "PESEL: " + pesel + ", isTeacher: " + isTeacher);

        // display a greeting toast and load the right fragment
        if (isTeacher) {
            Toast.makeText(this, getString(R.string.hello_teacher), Toast.LENGTH_SHORT).show();
            getFragmentManager().beginTransaction().replace(R.id.fragment,
                    new TeacherFragment()).commit();
        } else {
            Toast.makeText(this, getString(R.string.hello_student), Toast.LENGTH_SHORT).show();
            getFragmentManager().beginTransaction().replace(R.id.fragment,
                    new StudentFragment()).commit();
        }
    }

}
