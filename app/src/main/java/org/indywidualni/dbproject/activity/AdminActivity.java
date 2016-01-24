package org.indywidualni.dbproject.activity;

import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.widget.Toast;

import org.indywidualni.dbproject.R;

/**
 * Created by Krzysztof Grabowski on 21.01.16.
 * Admin Activity is loaded when an admin has logged in. It's just for activity lifecycle.
 * All the actions are made in Admin Fragment, we like fragments.
 */
public class AdminActivity extends BaseActivity {

    private static final String TAG = AdminActivity.class.getSimpleName();

    /**
     * Called when the activity is created.
     * @param savedInstanceState saved instance state
     */
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_admin);

        // app toolbar with actionbar support
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setDisplayShowHomeEnabled(true);
        }
    }

    /**
     * Inflate menu, admin has a different menu
     * @param menu menu
     * @return always true
     */
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu_admin, menu);
        return true;
    }

    /**
     * Handle menu clicks for admin menu
     * @param item menu item
     * @return true if item found, call the parent if not
     */
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.project_github:
                startActivity(new Intent(Intent.ACTION_VIEW,
                        Uri.parse(getString(R.string.github_url))));
                return true;
            case R.id.reset_database:
                openAppSettingsSystemActivity();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    /**
     * Method which opens system app page, to cleanup app data
     */
    private void openAppSettingsSystemActivity() {
        Toast.makeText(this, getString(R.string.remove_app_data),
                Toast.LENGTH_SHORT).show();
        try {
            // open the specific app info page
            Intent intent = new Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
            intent.setData(Uri.parse("package:org.indywidualni.dbproject"));
                    this.startActivity(intent);
        } catch (ActivityNotFoundException e) {
            e.printStackTrace();

            // open the generic apps page
            try {
                Intent intent = new Intent(android.provider.Settings.ACTION_MANAGE_APPLICATIONS_SETTINGS);
                this.startActivity(intent);
            } catch (ActivityNotFoundException ignored) {}
        }
    }

}