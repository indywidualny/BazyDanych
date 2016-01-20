package org.indywidualni.dbproject.models;

/**
 * Created by Krzysztof Grabowski on 20.01.16.
 */
public class Comment {

    // TODO: Just an example. I have to figure it out

    private long id;
    private String comment;

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    // will be used by the ArrayAdapter in the ListView
    @Override
    public String toString() {
        return comment;
    }

}