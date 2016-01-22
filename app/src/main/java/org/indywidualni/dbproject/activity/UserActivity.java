package org.indywidualni.dbproject.activity;

import android.os.Bundle;
import android.support.v7.widget.Toolbar;

import org.indywidualni.dbproject.R;

/**
 * Created by Krzysztof Grabowski on 22.01.16.
 */
public class UserActivity extends BaseActivity {

    private static final String TAG = AdminActivity.class.getSimpleName();

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
        }
    }

}
