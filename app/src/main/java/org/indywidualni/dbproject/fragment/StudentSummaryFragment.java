package org.indywidualni.dbproject.fragment;

import android.app.Fragment;
import android.database.SQLException;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.activity.UserActivity;
import org.indywidualni.dbproject.database.MaturaDataSource;
import org.indywidualni.dbproject.model.StudentSummary;

/**
 * Created by Krzysztof Grabowski on 22.01.16.
 */
public class StudentSummaryFragment extends Fragment {

    private MaturaDataSource dataSource = MaturaDataSource.getInstance();

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_student_summary, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        //noinspection ConstantConditions
        TextView pesel = (TextView) getView().findViewById(R.id.pesel);
        TextView name = (TextView) getView().findViewById(R.id.name);
        TextView numberOfExams = (TextView) getView().findViewById(R.id.number_of_exams);
        TextView passedExams = (TextView) getView().findViewById(R.id.passed_exams);
        TextView averageResult = (TextView) getView().findViewById(R.id.average_result);

        try {
            final StudentSummary studentSummary = dataSource.getStudentSummary(UserActivity.getCurrentPesel());

            /* App is in only one language so let's do a bad thing and leave hardcoded
             * strings. Normally strings should be got from resources and formatted.
             */
            String peselLine = "PESEL: " + studentSummary.getPesel();
            String nameLine = studentSummary.getFirstName() + " " + studentSummary.getSurname();
            String examsNoLine = "Liczba egzaminów: " + studentSummary.getNumberOfExams();
            String passedExamsLine = "Zdane egzaminy: " + studentSummary.getPassedExams();
            String averageLine = "Średni rezultat: " + studentSummary.getAverageResult() + "%";

            pesel.setText(peselLine);
            name.setText(nameLine);
            numberOfExams.setText(examsNoLine);
            passedExams.setText(passedExamsLine);
            averageResult.setText(averageLine);

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

}