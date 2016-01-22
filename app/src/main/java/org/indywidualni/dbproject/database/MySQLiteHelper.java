package org.indywidualni.dbproject.database;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.util.FileOperation;

/**
 * Created by Krzysztof Grabowski on 20.01.16.
 */
public class MySQLiteHelper extends SQLiteOpenHelper {

    private static final String DATABASE_NAME = "matura.db";
    private static final int DATABASE_VERSION = 1;
    private Context context;

    public MySQLiteHelper(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
        this.context = context;
    }

    @Override
    public void onCreate(SQLiteDatabase database) {
        Log.v("SQLiteDatabase", "Creating database");
        String databaseCreate = FileOperation.readRawTextFile(context, R.raw.matura);
        database.execSQL(databaseCreate);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        Log.w(MySQLiteHelper.class.getName(),
                "Upgrading database from version " + oldVersion + " to "
                        + newVersion + ", which will destroy all old data");
        db.execSQL("DROP TABLE IF EXISTS Egzaminy");
        db.execSQL("DROP TABLE IF EXISTS Nauczyciele");
        db.execSQL("DROP TABLE IF EXISTS Osoby");
        db.execSQL("DROP TABLE IF EXISTS [Rozklad Punktow]");
        db.execSQL("DROP TABLE IF EXISTS Rezultaty");
        db.execSQL("DROP TABLE IF EXISTS Punkty");
        db.execSQL("DROP TABLE IF EXISTS Szkoly");
        db.execSQL("DROP TABLE IF EXISTS Uczniowie");
        onCreate(db);
    }

}