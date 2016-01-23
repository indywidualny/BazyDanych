package org.indywidualni.dbproject.fragment;

import android.app.Fragment;
import android.database.SQLException;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;

import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.activity.UserActivity;
import org.indywidualni.dbproject.adapter.StudentExamsStatsAdapter;
import org.indywidualni.dbproject.database.MaturaDataSource;
import org.indywidualni.dbproject.model.StudentExam;
import org.indywidualni.dbproject.model.StudentExamsStats;

import java.util.ArrayList;

/**
 * Created by Krzysztof Grabowski on 23.01.16.
 */
public class StudentStatsFragment extends Fragment {

    private MaturaDataSource dataSource = MaturaDataSource.getInstance();

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_student_stats, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        try {
            // first get all student's exams
            final ArrayList<StudentExam> studentExams = dataSource.getAllStudentExams(UserActivity.getCurrentPesel());
            ArrayList<StudentExamsStats> studentStats = new ArrayList<>();

            // loop through all the exams to get their stats, add results into a list
            for (StudentExam exam : studentExams) {
                StudentExamsStats stats = dataSource.getStudentExamStats(exam.getCourse(), exam.getYear(),
                        exam.getLevel(), exam.getTime());
                studentStats.add(stats);
            }

            // use array adapter to populate a List View
            if (studentStats.size() > 0) {
                //noinspection ConstantConditions
                ListView list = (ListView) getView().findViewById(R.id.list_stats);
                StudentExamsStatsAdapter adapter = new StudentExamsStatsAdapter(getActivity(), studentStats);
                list.setAdapter(adapter);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

}