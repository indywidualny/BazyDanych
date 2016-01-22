package org.indywidualni.dbproject.database;

import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;

import org.indywidualni.dbproject.models.StudentSummary;

/**
 * Created by Krzysztof Grabowski on 20.01.16.
 * Singleton pattern
 */
public class MaturaDataSource {

    private static volatile MaturaDataSource instance;

    private SQLiteDatabase database;
    private MySQLiteHelper dbHelper;

    private MaturaDataSource() {}

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
            dbHelper = new MySQLiteHelper();
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

    public synchronized boolean getIsUserTeacher(String pesel) throws SQLException {
        open();
        Cursor cursor = null;
        boolean isTeacher = false;

        try {
            cursor = database.rawQuery("Select PESEL from Nauczyciele Where PESEL=?", new String[] {pesel});
            isTeacher = cursor.getCount() == 1;
        } finally {
            if (cursor != null)
                cursor.close();
        }

        close();
        return isTeacher;
    }

    public synchronized StudentSummary getStudentSummary(String pesel) throws SQLException {
        open();
        Cursor cursor = null;
        StudentSummary studentSummary = null;

        try {
            cursor = database.rawQuery("Select * from statUczen where PESEL=?", new String[] {pesel});
            if(cursor.getCount() > 0) {
                // retrieve the data to my custom model
                cursor.moveToFirst();
                int peselDatabase = cursor.getInt(cursor.getColumnIndex("PESEL"));
                String firstName = cursor.getString(cursor.getColumnIndex("Pierwsze_Imie"));
                String surname = cursor.getString(cursor.getColumnIndex("Nazwisko"));
                int numberOfExams = cursor.getInt(cursor.getColumnIndex("Ilosc egzaminow"));
                int passedExams = cursor.getInt(cursor.getColumnIndex("Zdane"));
                float averageResult = cursor.getFloat(cursor.getColumnIndex("Sredni wynik %"));

                studentSummary = new StudentSummary(peselDatabase, firstName, surname,
                        numberOfExams, passedExams, averageResult);
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }

        close();
        return studentSummary;
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
