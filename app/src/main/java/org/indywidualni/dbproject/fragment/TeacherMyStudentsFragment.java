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
import org.indywidualni.dbproject.adapter.TeacherStudentsAdapter;
import org.indywidualni.dbproject.database.MaturaDataSource;
import org.indywidualni.dbproject.model.StudentExam;
import org.indywidualni.dbproject.model.StudentExerciseResult;
import org.indywidualni.dbproject.model.StudentSummary;

import java.util.ArrayList;

/**
 * Created by Krzysztof Grabowski on 24.01.16.
 */
public class TeacherMyStudentsFragment extends Fragment {

    private MaturaDataSource dataSource = MaturaDataSource.getInstance();

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_teacher_my_students, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        try {
            /** first get all student's summaries */
            final ArrayList<StudentSummary> studentSummaries = dataSource.getTeacherStudents(UserActivity.getCurrentPesel());

            if (studentSummaries.size() > 0) {
                // use array adapter to populate a list
                //noinspection ConstantConditions
                ListView list = (ListView) getView().findViewById(R.id.list_my_students);
                TeacherStudentsAdapter adapter = new TeacherStudentsAdapter(getActivity(), studentSummaries);
                list.setAdapter(adapter);

                /** get all the clicked student's results */
                list.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                        // get exams data using a clicked student PESEL
                        final ArrayList<StudentExam> studentExams = dataSource.getAllStudentExams(
                                studentSummaries.get(position).getPesel());

                        // custom dialog
                        final Dialog dialog = new Dialog(getActivity());
                        dialog.setContentView(R.layout.fragment_student_exams);
                        dialog.setTitle(getString(R.string.student_exam_details));

                        dialog.show();

                        // populate a list
                        ListView le = (ListView) dialog.findViewById(R.id.list);
                        StudentExamsAdapter sea = new StudentExamsAdapter(getView().getContext(),
                                studentExams);
                        le.setAdapter(sea);

                        // set padding for a list
                        le.setPadding(14, 14, 14, 14);

                        /** get detailed results for a clicked exam, another dialog */
                        le.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                                // get ID of a clicked exam
                                String examID = studentExams.get(position).getExamID();

                                // use a content provider to get additional data
                                final ArrayList<StudentExerciseResult> studentExerciseResult =
                                        dataSource.getStudentExamResult(examID);

                                // custom dialog
                                final Dialog dialogDetails = new Dialog(getActivity());
                                dialogDetails.setContentView(R.layout.dialog_student_exam);
                                dialogDetails.setTitle(getString(R.string.student_exam_details));

                                dialogDetails.show();

                                ListView lee = (ListView) dialogDetails.findViewById(R.id.list_exercises);
                                StudentExerciseResultsAdapter sera = new StudentExerciseResultsAdapter(getView().getContext(),
                                        studentExerciseResult);
                                lee.setAdapter(sera);
                            }
                        });
                    }
                });
            }
        } catch (SQLException e) {
            // catch an exception globally
            e.printStackTrace();
        }
    }

}
