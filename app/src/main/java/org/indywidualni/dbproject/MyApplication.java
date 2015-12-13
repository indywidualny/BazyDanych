package org.indywidualni.dbproject;

import android.app.Application;
import android.content.Context;

/**
 * Created by Krzysztof Grabowski on 13.12.15.
 */
public class MyApplication extends Application {

    // context of an application for non context classes
    private static Context context;

    @Override
    public void onCreate() {
        context = getApplicationContext();
        super.onCreate();
    }

    public static Context getContextOfApplication() {
        return context;
    }

}