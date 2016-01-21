package org.indywidualni.dbproject.database;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;

import org.indywidualni.dbproject.MyApplication;
import org.indywidualni.dbproject.models.Comment;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Krzysztof Grabowski on 20.01.16.
 * Singleton pattern
 */
public class CommentsDataSource {

    private static volatile CommentsDataSource instance;
    private static final Context context = MyApplication.getContextOfApplication();

    private SQLiteDatabase database;
    private MySQLiteHelper dbHelper;

    private String[] allColumns = { MySQLiteHelper.COLUMN_ID,
            MySQLiteHelper.COLUMN_COMMENT };

    private CommentsDataSource() throws SQLException {
        open();
    }

    public static CommentsDataSource getInstance() {
        if (instance == null) {
            synchronized (CommentsDataSource.class) {
                if (instance == null)
                    instance = new CommentsDataSource();
            }
        }
        return instance;
    }

    public synchronized void open() throws SQLException {
        dbHelper = new MySQLiteHelper(context);
        database = dbHelper.getWritableDatabase();
    }

    // synchronize it to class
    public synchronized void close() {
        if (database != null) {
            //noinspection StatementWithEmptyBody
            while (database.isDbLockedByCurrentThread()) {}
            dbHelper.close();
            dbHelper = null;
            database = null;
            instance = null;
        }
    }

    public synchronized Comment createComment(String comment) {
        ContentValues values = new ContentValues();
        values.put(MySQLiteHelper.COLUMN_COMMENT, comment);
        long insertId = database.insert(MySQLiteHelper.TABLE_COMMENTS, null,
                values);
        Cursor cursor = database.query(MySQLiteHelper.TABLE_COMMENTS,
                allColumns, MySQLiteHelper.COLUMN_ID + " = " + insertId, null,
                null, null, null);
        cursor.moveToFirst();
        Comment newComment = cursorToComment(cursor);
        cursor.close();
        return newComment;
    }

    public synchronized void deleteComment(Comment comment) {
        long id = comment.getId();
        System.out.println("Comment deleted with id: " + id);
        database.delete(MySQLiteHelper.TABLE_COMMENTS, MySQLiteHelper.COLUMN_ID
                + " = " + id, null);
    }

    public synchronized List<Comment> getAllComments() {
        List<Comment> comments = new ArrayList<Comment>();

        Cursor cursor = database.query(MySQLiteHelper.TABLE_COMMENTS,
                allColumns, null, null, null, null, null);

        cursor.moveToFirst();
        while (!cursor.isAfterLast()) {
            Comment comment = cursorToComment(cursor);
            comments.add(comment);
            cursor.moveToNext();
        }
        // make sure to close the cursor
        cursor.close();
        return comments;
    }

    private Comment cursorToComment(Cursor cursor) {
        Comment comment = new Comment();
        comment.setId(cursor.getLong(0));
        comment.setComment(cursor.getString(1));
        return comment;
    }

}
