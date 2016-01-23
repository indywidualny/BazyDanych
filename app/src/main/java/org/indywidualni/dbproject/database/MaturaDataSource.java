package org.indywidualni.dbproject.database;

import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;

import org.indywidualni.dbproject.model.StudentExam;
import org.indywidualni.dbproject.model.StudentExamsStats;
import org.indywidualni.dbproject.model.StudentExerciseResult;
import org.indywidualni.dbproject.model.StudentSummary;

import java.util.ArrayList;

/**
 * Created by Krzysztof Grabowski on 20.01.16.
 * Singleton pattern. The core of an application. All the data is retrieved from
 * the database in this class. Data retrieving methods are synchronized in order to
 * make it thread safe.
 */
public class MaturaDataSource {

    private static volatile MaturaDataSource instance;

    private SQLiteDatabase database;
    private MySQLiteHelper dbHelper;

    private MaturaDataSource() {}

    /**
     * We want to make it thread safe, so the best way of achieving it is just to
     * get an instance of this object every time we need it and don't worry about
     * our future. Singleton pattern is rather a popular one.
     * @return an instance of this class
     */
    public static MaturaDataSource getInstance() {
        if (instance == null) {
            synchronized (MaturaDataSource.class) {
                if (instance == null)
                    instance = new MaturaDataSource();
            }
        }
        return instance;
    }

    /**
     * Open a database, actually open a writable database
     * @throws SQLException
     */
    private void open() throws SQLException {
        if (dbHelper == null) {
            dbHelper = new MySQLiteHelper();
            database = dbHelper.getWritableDatabase();
        }
    }

    /**
     * Close database when it's not needed anymore. Thread safe implementation
     * although it's not needed at all because all the methods are synchronized
     * to an object of the class.
     */
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

    /**
     * Empty database connection. Just open a database and close it. It seems stupid, yeah?
     * It's rather not. During the very first run of an app (or when a database has been
     * upgraded), opening it forces database creation (recreation). We need to do it
     * asynchronously during an app start to avoid any UI freezes.
     * @throws SQLException
     */
    public synchronized void emptyConnection() throws SQLException {
        open();
        close();
    }

    /**
     * Open a database, get user password hash from a database, close a database.
     * @param pesel pesel of an user
     * @return salted hash on a password
     * @throws SQLException
     */
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

    /**
     * Open a database, check is user a teacher, close a database.
     * @param pesel pesel of an user
     * @return is a teacher or not
     * @throws SQLException
     */
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

    /**
     * Open a database, get a student summary into a model (PESEL, first name, etc.).
     * Close a database then.
     * @param pesel pesel of a student
     * @return student summary model
     * @throws SQLException
     */
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

    /**
     * Open a database, get all the basic exam results for a student, close a database.
     * @param pesel pesel of a student
     * @return a list of all student exams results
     * @throws SQLException
     */
    public synchronized ArrayList<StudentExam> getAllStudentExams (String pesel) throws SQLException {
        open();
        Cursor cursor = null;
        ArrayList<StudentExam> list = new ArrayList<>();

        try {
            cursor = database.rawQuery("Select E.Przedmiot, E.Poziom, E.Rok, E.Termin+1 AS Termin, " +
                    "R.Wynik, R.[Wynik proc], R.Zdany, R.[Nr egzaminu] from Egzaminy E Join Rezultaty R ON " +
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

    /**
     * A cursor which reads a current row and loads all the data into a model
     * @param cursor cursor
     * @return student exam model
     */
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

    public synchronized ArrayList<StudentExerciseResult> getStudentExamResult(String examID) throws SQLException {
        open();
        Cursor cursor = null;
        ArrayList<StudentExerciseResult> list = new ArrayList<>();

        try {
            cursor = database.rawQuery("Select * from Punkty where [Nr egzaminu] = ?", new String[] { examID });
            if(cursor.getCount() > 0) {
                // retrieve the data to my custom model
                cursor.moveToFirst();

                while (!cursor.isAfterLast()) {
                    StudentExerciseResult exam = cursorToStudentExercise(cursor);
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

    private StudentExerciseResult cursorToStudentExercise(Cursor cursor) {
        return new StudentExerciseResult(cursor.getInt(1), cursor.getInt(2), cursor.getString(3));
    }

    public synchronized StudentExamsStats getStudentExamStats(
            String przedmiot, String rok, String poziom, String termin) throws SQLException {
        open();
        Cursor cursor = null;
        StudentExamsStats stats = null;

        try {
            String q = "SELECT * from statEgzamin WHERE poziom=" + poziom + " and termin="
                    + termin + " and rok=" + rok + " and przedmiot like %s";
            String query = String.format(q, "\""+ przedmiot + "%\"");
            cursor = database.rawQuery(query, null);

            if(cursor.getCount() > 0) {
                // retrieve the data to my custom model
                cursor.moveToFirst();

                int year = cursor.getInt(cursor.getColumnIndex("Rok"));
                String subject = cursor.getString(cursor.getColumnIndex("Przedmiot"));
                int level = cursor.getInt(cursor.getColumnIndex("Poziom"));
                int time = cursor.getInt(cursor.getColumnIndex("Termin"));
                int students = cursor.getInt(cursor.getColumnIndex("Ilosc zdajacych"));
                int avrg = cursor.getInt(cursor.getColumnIndex("Sredni wynik"));
                int percent = cursor.getInt(cursor.getColumnIndex("Sredni wynik %"));
                int passed = cursor.getInt(cursor.getColumnIndex("Zdawalnosc"));

                stats = new StudentExamsStats(year, subject, level, time, students, avrg, percent, passed);
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }

        close();
        return stats;
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
*/

}
