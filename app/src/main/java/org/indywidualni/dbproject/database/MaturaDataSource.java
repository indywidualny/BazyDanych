package org.indywidualni.dbproject.database;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;

import org.indywidualni.dbproject.MyApplication;
import org.indywidualni.dbproject.models.Uczen;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Krzysztof Grabowski on 20.01.16.
 * Singleton pattern
 */
public class MaturaDataSource {

    private static volatile MaturaDataSource instance;
    private static Context context;

    private SQLiteDatabase database;
    private MySQLiteHelper dbHelper;

    private MaturaDataSource() {
        context = MyApplication.getContextOfApplication();
    }

    public static MaturaDataSource getInstance() {
        if (instance == null) {
            synchronized (MaturaDataSource.class) {
                if (instance == null)
                    instance = new MaturaDataSource();
            }
        }
        return instance;
    }

    private void open() throws SQLException {
        if (dbHelper == null) {
            dbHelper = new MySQLiteHelper(context);
            database = dbHelper.getWritableDatabase();
        }
    }

    private void close() {
        if (database != null) {
            // probably not needed because of synchronization
            //noinspection StatementWithEmptyBody
            while (database.isDbLockedByCurrentThread()) {}
            dbHelper.close();
            dbHelper = null;
            database = null;
        }
    }

    public synchronized void emptyConnection() throws SQLException {
        open();
        close();
    }

    public synchronized String getUserPassword(String pesel) throws SQLException {
        open();
        Cursor cursor = null;
        String password = "";

        try {
            cursor = database.rawQuery("SELECT Haslo FROM Osoby WHERE PESEL=?", new String[] {pesel});
            if(cursor.getCount() > 0) {
                cursor.moveToFirst();
                password = cursor.getString(cursor.getColumnIndex("Haslo"));
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }

        close();
        return password;
    }

    public synchronized boolean isUserTeacher(String pesel) throws SQLException {
        open();
        Cursor cursor = null;
        boolean isTeacher = false;

        try {
            cursor = database.rawQuery("if(Select Count(*) from Nauczyciele Where PESEL=?)=1", new String[] {pesel});
            if (cursor.getCount() > 0) {
                cursor.moveToFirst();
                isTeacher = cursor.getInt(cursor.getColumnIndex("Pesel")) > 0;
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }

        close();
        return isTeacher;
    }
/*    public Uczen createComment(String comment) {
        ContentValues values = new ContentValues();
        values.put(MySQLiteHelper.COLUMN_COMMENT, comment);
        long insertId = database.insert(MySQLiteHelper.TABLE_COMMENTS, null,
                values);
        Cursor cursor = database.query(MySQLiteHelper.TABLE_COMMENTS,
                allColumns, MySQLiteHelper.COLUMN_ID + " = " + insertId, null,
                null, null, null);
        cursor.moveToFirst();
        Uczen newComment = cursorToComment(cursor);
        cursor.close();
        return newComment;
    }

    public void deleteComment(Uczen comment) {
        long id = comment.getId();
        System.out.println("Comment deleted with id: " + id);
        database.delete(MySQLiteHelper.TABLE_COMMENTS, MySQLiteHelper.COLUMN_ID
                + " = " + id, null);
    }

    public List<Uczen> getAllComments() {
        List<Uczen> comments = new ArrayList<Uczen>();

        Cursor cursor = database.query(MySQLiteHelper.TABLE_COMMENTS,
                allColumns, null, null, null, null, null);

        cursor.moveToFirst();
        while (!cursor.isAfterLast()) {
            Uczen comment = cursorToComment(cursor);
            comments.add(comment);
            cursor.moveToNext();
        }
        // make sure to close the cursor
        cursor.close();
        return comments;
    }

    public Uczen getStatUczen() {
        Uczen
    }

    private Uczen cursorToComment(Cursor cursor) {
        Uczen comment = new Uczen();
        comment.setId(cursor.getLong(0));
        comment.setComment(cursor.getString(1));
        return comment;
    }*/

}
