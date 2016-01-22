package org.indywidualni.dbproject.database;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

import org.indywidualni.dbproject.MyApplication;
import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.util.FileOperation;

/**
 * Created by Krzysztof Grabowski on 20.01.16.
 */
public class MySQLiteHelper extends SQLiteOpenHelper {

    private static final String DATABASE_NAME = "matura.db";
    private static final int DATABASE_VERSION = 77;
    private static final Context context;

    static {
        context = MyApplication.getContextOfApplication();
    }

    public MySQLiteHelper() {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase database) {
        Log.v("SQLiteDatabase", "Creating database");
        String databaseCreate = FileOperation.readRawTextFile(context, R.raw.matura);
        final String[] split = databaseCreate.split(";");
        for (String query : split) {
            Log.v("SQL", query + ";");
            database.execSQL(query + ";");

        }
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        Log.w(MySQLiteHelper.class.getName(),
                "Upgrading database from version " + oldVersion + " to "
                        + newVersion + ", which will destroy all old data");
        db.execSQL("DROP TABLE IF EXISTS Egzaminy;");
        db.execSQL("DROP TABLE IF EXISTS Nauczyciele;");
        db.execSQL("DROP TABLE IF EXISTS Osoby;");
        db.execSQL("DROP TABLE IF EXISTS [Rozklad Punktow];");
        db.execSQL("DROP TABLE IF EXISTS Rezultaty;");
        db.execSQL("DROP TABLE IF EXISTS Punkty;");
        db.execSQL("DROP TABLE IF EXISTS Szkoly;");
        db.execSQL("DROP TABLE IF EXISTS Uczniowie;");
        onCreate(db);
    }

}