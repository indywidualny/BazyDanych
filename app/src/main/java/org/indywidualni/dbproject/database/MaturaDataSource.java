package org.indywidualni.dbproject.database;

import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;

import org.indywidualni.dbproject.model.StudentExam;
import org.indywidualni.dbproject.model.StudentSummary;

import java.util.ArrayList;
import java.util.List;

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
            // actually not needed because of synchronization
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
            cursor = database.rawQuery("SELECT Haslo FROM Osoby WHERE PESEL=?", new String[] { pesel });
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
            cursor = database.rawQuery("Select PESEL from Nauczyciele Where PESEL=?", new String[] { pesel });
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
            cursor = database.rawQuery("Select * from statUczen where PESEL=?", new String[] { pesel });
            if(cursor.getCount() > 0) {
                // retrieve the data to my custom model
                cursor.moveToFirst();
                int peselDatabase = cursor.getInt(cursor.getColumnIndex("PESEL"));
                String firstName = cursor.getString(cursor.getColumnIndex("Pierwsze_Imie"));
                String surname = cursor.getString(cursor.getColumnIndex("Nazwisko"));
                int numberOfExams = cursor.getInt(cursor.getColumnIndex("Ilosc egzaminow"));
                int passedExams = cursor.getInt(cursor.getColumnIndex("Zdane"));
                int averageResult = cursor.getInt(cursor.getColumnIndex("Sredni wynik %"));

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

    public synchronized ArrayList<StudentExam> getAllStudentExams (String pesel) throws SQLException {
        open();
        Cursor cursor = null;
        ArrayList<StudentExam> list = new ArrayList<>();

        try {
            cursor = database.rawQuery("Select E.Przedmiot, E.Poziom, E.Rok, E.Termin+1 AS Termin, " +
                    "R.Wynik, R.[Wynik proc], R.Zdany, E.ID from Egzaminy E Join Rezultaty R ON " +
                    "E.ID=R.Egzamin where Zdajacy=(Select ID from " +
                    "Uczniowie where PESEL=?)", new String[] { pesel });
            if(cursor.getCount() > 0) {
                // retrieve the data to my custom model
                cursor.moveToFirst();

                while (!cursor.isAfterLast()) {
                    StudentExam exam = cursorToStudentExam(cursor);
                    list.add(exam);
                    cursor.moveToNext();
                }
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }

        close();
        return list;
    }

    private StudentExam cursorToStudentExam(Cursor cursor) {
        String course = cursor.getString(0);
        int level = cursor.getInt(1);
        int year = cursor.getInt(2);
        int time = cursor.getInt(3);
        int result = cursor.getInt(4);
        int percent = cursor.getInt(5);
        boolean passed = cursor.getInt(6) > 0;
        int id = cursor.getInt(7);

        return new StudentExam(course, level, year, time, result, percent, passed, id);
    }

/*    public synchronized ArrayList<String> StudentExamResult(String examID) {
        open();
        Cursor cursor = null;
        ArrayList<String> list = new ArrayList<>();

        try {
            cursor = database.rawQuery("Select [Nr zadania], Punkty, [Opis Oceny] from Punkty " +
                    "Where [Nr egzaminu] = ?", new String[] { examID });
            if(cursor.getCount() > 0) {
                // retrieve the data to my custom model
                cursor.moveToFirst();

                list.add(cursor.getString(0));
                int level = cursor.getInt(1);
                int year = cursor.getInt(2);
                int time = cursor.getInt(3);
                int result = cursor.getInt(4);
                int percent = cursor.getInt(5);
                boolean passed = cursor.getInt(6) > 0;
                int id = cursor.getInt(7);
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }

        close();
        return list;
    }*/

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
*/

}
