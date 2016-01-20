package org.indywidualni.dbproject;

import android.app.Application;
import android.content.Context;

/**
 * Created by Krzysztof Grabowski on 13.12.15.
 */
public class MyApplication extends Application {

    // SHA1 of admin password
    private static final String adminPassword = "d033e22ae348aeb5660fc2140aec35850c4da997";

    // context of an application for non context classes
    private static Context context;

    @Override
    public void onCreate() {
        context = getApplicationContext();
        super.onCreate();
    }

    public static String getAdminPassword() {
        return adminPassword;
    }

    public static Context getContextOfApplication() {
        return context;
    }

}