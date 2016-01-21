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

    // TODO: Just an example. I have to figure it out

    public static final String TABLE_EGZAMINY = "Egzaminy";
    public static final String TABLE_NAUCZYCIELE = "Nauczyciele";
    public static final String TABLE_OSOBY = "Osoby";
    public static final String TABLE_ROZKLAD_PUNKTOW = "[Rozklad Punktow]";
    public static final String TABLE_REZULTATY = "Rezultaty";
    public static final String TABLE_PUNKTY = "Punkty";
    public static final String TABLE_SZKOLY = "Szkoly";
    public static final String TABLE_UCZNIOWIE = "Uczniowie";

    public static final String COLUMN_ID = "_id";

    private static final String DATABASE_NAME = "matura.db";
    private static final int DATABASE_VERSION = 11;

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
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_EGZAMINY);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_NAUCZYCIELE);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_OSOBY);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_ROZKLAD_PUNKTOW);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_REZULTATY);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_PUNKTY);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_SZKOLY);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_UCZNIOWIE);
        onCreate(db);
    }

}