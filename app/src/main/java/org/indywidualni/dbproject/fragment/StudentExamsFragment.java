package org.indywidualni.dbproject.fragment;

import android.app.Dialog;
import android.app.Fragment;
import android.database.SQLException;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;

import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.activity.UserActivity;
import org.indywidualni.dbproject.adapter.StudentExamsAdapter;
import org.indywidualni.dbproject.adapter.StudentExerciseResultsAdapter;
import org.indywidualni.dbproject.database.MaturaDataSource;
import org.indywidualni.dbproject.model.StudentExam;
import org.indywidualni.dbproject.model.StudentExerciseResult;

import java.util.ArrayList;

/**
 * Created by Krzysztof Grabowski on 23.01.16.
 */
public class StudentExamsFragment extends Fragment {

    private MaturaDataSource dataSource = MaturaDataSource.getInstance();

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_student_exams, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        try {
            final ArrayList<StudentExam> studentExams = dataSource.getAllStudentExams(UserActivity.getCurrentPesel());

            //noinspection ConstantConditions
            ListView list = (ListView) getView().findViewById(R.id.list);
            StudentExamsAdapter adapter = new StudentExamsAdapter(getActivity(), studentExams);
            list.setAdapter(adapter);

            list.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                    String examID = studentExams.get(position).getExamID();

                    // custom dialog
                    final Dialog dialog = new Dialog(getActivity());
                    dialog.setContentView(R.layout.dialog_student_exam);
                    dialog.setTitle(getString(R.string.student_exam_details));

                    dialog.show();

                    final ArrayList<StudentExerciseResult> studentExerciseResult =
                            dataSource.getStudentExamResult(examID);
                    ListView le = (ListView) dialog.findViewById(R.id.list_exercises);
                    StudentExerciseResultsAdapter sera = new StudentExerciseResultsAdapter(getView().getContext(),
                            studentExerciseResult);
                    le.setAdapter(sera);
                }
            });
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

}