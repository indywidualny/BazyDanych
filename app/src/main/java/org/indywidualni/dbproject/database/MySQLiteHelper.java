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
 * Database Helper. It's main goal is to create/upgrade a database and it's used
 * by our data sources.
 */
public class MySQLiteHelper extends SQLiteOpenHelper {

    private static final String DATABASE_NAME = "matura.db";
    private static final int DATABASE_VERSION = 93;
    private static final Context context;

    static {
        context = MyApplication.getContextOfApplication();
    }

    public MySQLiteHelper() {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    /**
     * Database creation. It's tricky but neat. All the SQL commands are read from a text file
     * to string. After this a string is split into a string array of single commands because we
     * can execute only one command at a time. For Each loop executes all the meaningful commands.
     * @param database SQLite database
     */
    @Override
    public void onCreate(SQLiteDatabase database) {
        Log.v("SQLiteDatabase", "Creating database");
        String databaseCreate = FileOperation.readRawTextFile(context, R.raw.matura);
        final String[] split = databaseCreate.split(";");
        for (String query : split) {
            if (query.length() > 1) {
                //Log.v("SQL", query + ";");
                database.execSQL(query + ";");
            }
        }
    }

    /**
     * Called when the database is upgraded to a new version
     * @param db database
     * @param oldVersion old version id
     * @param newVersion new version id
     */
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
        db.execSQL("DROP VIEW IF EXISTS statEgzamin;");
        db.execSQL("DROP VIEW IF EXISTS statUczen;");
        db.execSQL("DROP VIEW IF EXISTS statPrzedmiot;");
        db.execSQL("DROP VIEW IF EXISTS statNauczyciel;");
        db.execSQL("DROP VIEW IF EXISTS statSzkola;");
        db.execSQL("DROP VIEW IF EXISTS statMiasto;");
        onCreate(db);
    }

}