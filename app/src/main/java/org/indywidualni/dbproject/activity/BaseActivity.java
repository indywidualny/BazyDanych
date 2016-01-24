package org.indywidualni.dbproject.activity;

import android.content.Intent;
import android.net.Uri;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;

import org.indywidualni.dbproject.R;

/**
 * Created by Krzysztof Grabowski on 22.01.16.
 * All the activities are children of this class in order to avoid
 * code duplication for a menu. A menu is the same for all the activities
 * so it's a good place to put its methods here.
 */
public class BaseActivity extends AppCompatActivity {

    /**
     * Inflate a default menu
     * @param menu menu
     * @return always true
     */
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu_generic, menu);
        return true;
    }

    /**
     * Handle default menu clicks
     * @param item menu item
     * @return if clicked, true, else: call for parent
     */
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.project_github:
                startActivity(new Intent(Intent.ACTION_VIEW,
                        Uri.parse(getString(R.string.github_url))));
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

}
