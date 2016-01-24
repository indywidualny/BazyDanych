package org.indywidualni.dbproject.database;

import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.util.Log;

import org.indywidualni.dbproject.model.AdminUser;
import org.indywidualni.dbproject.model.PointDistribution;
import org.indywidualni.dbproject.model.StudentExam;
import org.indywidualni.dbproject.model.StudentExamsStats;
import org.indywidualni.dbproject.model.StudentExerciseResult;
import org.indywidualni.dbproject.model.StudentSummary;
import org.indywidualni.dbproject.model.TeacherExam;

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
     * @return an instance of this object
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
            cursor = database.rawQuery("Select E.Przedmiot, E.Poziom, E.Rok, E.Termin AS Termin, " +
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

    /**
     * Get exam results for a student
     * @param examID exam ID
     * @return a list of single exercises
     * @throws SQLException
     */
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

    /**
     * Cursor to student exercise
     * @param cursor cursor
     * @return a single exercise
     */
    private StudentExerciseResult cursorToStudentExercise(Cursor cursor) {
        return new StudentExerciseResult(cursor.getInt(1), cursor.getInt(2), cursor.getString(3));
    }

    /**
     * Get all student's exams global stats. Just to check what are the average
     * results for all the exams
     * @param przedmiot subject
     * @param rok year
     * @param poziom level
     * @param termin time
     * @return a single exam stats object
     * @throws SQLException
     */
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

    /**
     * Get all user's details. Used by an admin to check information about users
     * @return a list of user objects
     * @throws SQLException
     */
    public synchronized ArrayList<AdminUser> getAllUsers() throws SQLException {
        open();
        Cursor cursor = null;
        ArrayList<AdminUser> list = new ArrayList<>();

        try {
            cursor = database.rawQuery("Select * from Osoby", new String[] {});
            if(cursor.getCount() > 0) {
                // retrieve the data to my custom model
                cursor.moveToFirst();

                while (!cursor.isAfterLast()) {
                    AdminUser user = cursorToUsers(cursor);
                    list.add(user);
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
     * Cursor to get a single user data
     * @param cursor cursor
     * @return a single user object
     */
    private AdminUser cursorToUsers(Cursor cursor) {
        return new AdminUser(cursor.getInt(0), cursor.getString(1), cursor.getString(2),
                cursor.getString(3), cursor.getString(4), cursor.getString(5), cursor.getString(6),
                cursor.getString(7), cursor.getString(8), cursor.getInt(9), cursor.getInt(10));
    }

    /**
     * Change user's password. Used by the admin
     * @param pesel pesel of an user
     * @param password new password
     * @throws SQLException
     */
    public synchronized void changeUserPassword(String pesel, String password) throws SQLException {
        open();
        database.execSQL("UPDATE Osoby SET Haslo='" + password + "' WHERE PESEL=" + pesel);
        close();
    }

    /**
     * Get all the teacher's student's
     * @param pesel pesel of a teacher
     * @return a list of single student summaries
     * @throws SQLException
     */
    public synchronized ArrayList<StudentSummary> getTeacherStudents(String pesel) throws SQLException {
        open();
        Cursor cursor = null;
        ArrayList<StudentSummary> list = new ArrayList<>();

        try {
            cursor = database.rawQuery("Select * from  statUczen where PESEL IN (Select Pesel from Uczniowie " +
                    "Where Wychowawca=(select ID from Nauczyciele where PESEL=?))", new String[] { pesel });
            if(cursor.getCount() > 0) {
                // retrieve the data to my custom model
                cursor.moveToFirst();

                while (!cursor.isAfterLast()) {
                    StudentSummary student = cursorToTeacherStudents(cursor);
                    list.add(student);
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
     * Cursor to get info about a single student
     * @param cursor cursor
     * @return a single student summary
     */
    private StudentSummary cursorToTeacherStudents(Cursor cursor) {
        return new StudentSummary(cursor.getInt(0), cursor.getString(1), cursor.getString(2),
                cursor.getInt(3), cursor.getInt(4), cursor.getInt(5));
    }

    /**
     * Get all the exams in order to be able to grade them
     * @return all the existing exams
     * @throws SQLException
     */
    public synchronized ArrayList<TeacherExam> getTeacherAllExams() throws SQLException {
        open();
        Cursor cursor = null;
        ArrayList<TeacherExam> list = new ArrayList<>();

        try {
            cursor = database.rawQuery("SELECT * FROM Egzaminy", new String[] {});
            if(cursor.getCount() > 0) {
                // retrieve the data to my custom model
                cursor.moveToFirst();

                while (!cursor.isAfterLast()) {
                    TeacherExam exam = cursorToTeacherAllExams(cursor);
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
     * cursor to get data about a single exam
     * @param cursor cursor
     * @return a single exam object for a teacher
     */
    private TeacherExam cursorToTeacherAllExams(Cursor cursor) {
        return new TeacherExam(cursor.getInt(0), cursor.getString(1), cursor.getInt(2), cursor.getInt(3),
                cursor.getInt(4), cursor.getInt(5), cursor.getInt(6));
    }

    /**
     * Check is teacher permitted to grade students
     * @param pesel pesel of a teacher
     * @return can grade or cannot grade
     * @throws SQLException
     */
    public synchronized boolean isTeacherPermitted(String pesel) throws SQLException {
        open();
        Cursor cursor = null;
        boolean canGrade = false;

        try {
            cursor = database.rawQuery("SELECT Uprawnienia FROM Nauczyciele where pesel=? " +
                    "and Uprawnienia=1", new String[] { pesel });
            canGrade = cursor.getCount() == 1;
        } finally {
            if (cursor != null)
                cursor.close();
        }

        close();
        return canGrade;
    }

    /**
     * Get point distribution for all the exercises of a given exam
     * @param examID a given exam id
     * @return a list of a single exercise information
     * @throws SQLException
     */
    public synchronized ArrayList<PointDistribution> getPointDistribution(String examID)
            throws SQLException {  // not used anywhere
        open();
        Cursor cursor = null;
        ArrayList<PointDistribution> pointDistributions = new ArrayList<>();

        try {
            cursor = database.rawQuery("SELECT * FROM [Rozklad Punktow] where Egzamin=?",
                    new String[] { examID });
            if(cursor.getCount() > 0) {
                // retrieve the data to my custom model
                cursor.moveToFirst();

                while (!cursor.isAfterLast()) {
                    PointDistribution points = cursorToPointDistribution(cursor);
                    pointDistributions.add(points);
                    cursor.moveToNext();
                }
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }

        close();
        return pointDistributions;
    }

    /**
     * Cursor to get points distribution
     * @param cursor cursor
     * @return a single point distribution object
     */
    private PointDistribution cursorToPointDistribution(Cursor cursor) {
        return new PointDistribution(cursor.getInt(0), cursor.getInt(1), cursor.getInt(2));
    }

    /**
     * Get maximum number of points possible for an exercise
     * @param examID exam id
     * @param exercise exercise
     * @return maximum number of points
     * @throws SQLException
     */
    public synchronized int getMaxPointsForExercise(String examID, String exercise)
            throws SQLException {
        open();
        Cursor cursor = null;
        int max = 0;

        try {
            cursor = database.rawQuery("SELECT * FROM [Rozklad Punktow] " +
                    "where [Nr zadania]=? and Egzamin=?", new String[] { exercise, examID });
            if (cursor.getCount() > 0) {
                cursor.moveToFirst();
                max = cursor.getInt(cursor.getColumnIndex("Max pkt"));
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }

        close();
        return max;
    }

    /** Get ID of a teacher which is permitted to grade
     * @param pesel teacher's pesel
     * @return an id of a permitted teacher
     * @throws SQLException
     */
    public synchronized int getExaminatorId(String pesel) throws SQLException {
        open();
        Cursor cursor = null;
        int id = -1;

        try {
            cursor = database.rawQuery("SELECT ID FROM Nauczyciele WHERE pesel=?", new String[] { pesel });
            if(cursor.getCount() > 0) {
                cursor.moveToFirst();
                id = cursor.getInt(cursor.getColumnIndex("ID"));
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }

        close();
        return id;
    }

    /**
     * Update or insert points for a single exercise
     * @param id exam id
     * @param ex exercise number
     * @param points new number of points
     * @param description description for the grade
     * @param teacher teacher who is going to grade this exercise
     * @throws SQLException
     */
    public synchronized void teacherInsertOrUpdatePoints(
            String id, String ex, String points, String description, String teacher)
            throws SQLException {
        open();

        String query = "INSERT or REPLACE INTO Punkty ([Nr egzaminu], [Nr zadania], Punkty, [Opis oceny], Oceniajacy) " +
                "values (" + id + ", " + ex + ", " + points + ", \"" + description + "\", " + teacher + ");";
        Log.v("insertOrUpdatePoints", query);

        database.execSQL(query);
/*        database.rawQuery("INSERT or REPLACE INTO Punkty ([Nr egzaminu], [Nr zadania], Punkty, [Opis oceny], Oceniajacy) " +
                "values (?, ?, ?, ?, ?)", new String[] { id, ex, points, description, teacher});*/
        close();
    }

}
