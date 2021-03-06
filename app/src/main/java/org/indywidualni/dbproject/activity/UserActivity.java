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
 * After a successful student/teacher login this activity is opened.
 */
public class UserActivity extends BaseActivity {

    private static final String TAG = UserActivity.class.getSimpleName();
    private static String currentPesel;
    private static boolean isTeacher;

    public static String getCurrentPesel() {
        return currentPesel;
    }

    /**
     * Called when the activity is being created. During creation all intent extras
     * PESEL, session type (student/teacher) are obtained. A greeting Toast is displayed
     * and a placeholder fragment is replaced with the correct one (student or teacher).
     * @param savedInstanceState saved instance state
     */
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
            currentPesel = extras.getString("pesel");
            isTeacher = extras.getBoolean("teacher");
        }

        Log.v(TAG, "PESEL: " + currentPesel + ", isTeacher: " + isTeacher);

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

    /**
     * Looks like not important because it does nothing?
     * Well it overrides a default method, which I wanted to disable
     * @param outState out state
     */
    @Override
    protected void onSaveInstanceState(Bundle outState) {
        // do nothing
    }

}
