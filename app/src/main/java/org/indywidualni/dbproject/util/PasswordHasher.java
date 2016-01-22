package org.indywidualni.dbproject.util;

import android.util.Log;

import java.io.UnsupportedEncodingException;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Krzysztof Grabowski on 22.01.16.
 */
public class PasswordHasher {

    public PasswordHasher() {
        List<LoginPassword> data = new ArrayList<>();

        data.add(new LoginPassword(159624, "Poziom3"));
        data.add(new LoginPassword(126842, "Nadziana"));
        data.add(new LoginPassword(137891, "Nicosc70"));
        data.add(new LoginPassword(189145, "Piknik"));
        data.add(new LoginPassword(185542, "KozaAda"));
        data.add(new LoginPassword(176583, "Fizyka73"));
        data.add(new LoginPassword(179942, "password"));
        data.add(new LoginPassword(209561, "Slonce"));
        data.add(new LoginPassword(115472, "GwiazdyN"));
        data.add(new LoginPassword(175986, "Ramki5"));
        data.add(new LoginPassword(118556, "SuperNowa"));
        data.add(new LoginPassword(193651, "AnaMari"));
        data.add(new LoginPassword(119235, "Cokolwiek98"));
        data.add(new LoginPassword(192856, "Nigdy21"));

        for (LoginPassword lp : data) {
            try {
                lp.password = AeSimpleSHA1.SHA1(lp.password);
                Log.i("PasswordHasher", lp.login + " " + lp.password);
            } catch (NoSuchAlgorithmException | UnsupportedEncodingException e) {
                e.printStackTrace();
            }
        }
    }

    private class LoginPassword {
        public LoginPassword(int login, String password) {
            this.login = login;
            this.password = password;
        }

        public int login;
        public String password;
    }

}
