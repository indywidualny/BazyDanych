package org.indywidualni.dbproject.activity;

import android.os.Bundle;
import android.support.v7.widget.Toolbar;

import org.indywidualni.dbproject.R;

/**
 * Created by Krzysztof Grabowski on 21.01.16.
 * Admin Activity is loaded when an admin has logged in. It's just for activity lifecycle.
 * All the actions are made in Admin Fragment, we like fragments.
 */
public class AdminActivity extends BaseActivity {

    private static final String TAG = AdminActivity.class.getSimpleName();

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

}
