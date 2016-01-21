package org.indywidualni.dbproject.activity;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;

import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.database.MaturaDataSource;

/**
 * Created by Krzysztof Grabowski on 21.01.16.
 */
public class AdminActivity extends AppCompatActivity {

    private static final String TAG = AdminActivity.class.getSimpleName();
    private MaturaDataSource dataSource;

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

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.i(TAG, "OnDestroy: Close database connection");
        if (dataSource != null)
            dataSource.close();
    }

}
