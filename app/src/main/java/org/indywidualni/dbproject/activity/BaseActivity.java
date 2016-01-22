package org.indywidualni.dbproject.activity;

import android.content.Intent;
import android.net.Uri;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;

import org.indywidualni.dbproject.R;

/**
 * Created by Krzysztof Grabowski on 22.01.16.
 */
public class BaseActivity extends AppCompatActivity implements AdapterView.OnItemSelectedListener {

    public void onItemSelected(AdapterView<?> parent, View view,
                               int pos, long id) {
        // An item was selected. You can retrieve the selected item using
        // parent.getItemAtPosition(pos)
        Log.v(getLocalClassName(), parent.getItemAtPosition(pos).toString());
    }

    public void onNothingSelected(AdapterView<?> parent) {
        // Another interface callback
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu_generic, menu);
        return true;
    }

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
