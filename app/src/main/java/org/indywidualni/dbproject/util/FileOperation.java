package org.indywidualni.dbproject.util;

import android.content.Context;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

/**
 * Created by Krzysztof Grabowski on 21.01.16.
 */
public class FileOperation {

    // read raw files to string (for css files)
    public static String readRawTextFile(Context ctx, int resId) {
        InputStream inputStream = ctx.getResources().openRawResource(resId);
        InputStreamReader inputReader = new InputStreamReader(inputStream);
        BufferedReader buffReader = new BufferedReader(inputReader);
        String line;
        StringBuilder text = new StringBuilder();
        try {
            while ((line = buffReader.readLine()) != null)
                text.append(line).append(" ");
        } catch (IOException e) {
            return " ";
        }
        return text.toString();
    }

}
