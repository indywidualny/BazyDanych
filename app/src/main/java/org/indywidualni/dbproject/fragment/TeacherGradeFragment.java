package org.indywidualni.dbproject.fragment;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Fragment;
import android.content.DialogInterface;
import android.database.SQLException;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ListView;

import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.adapter.TeacherExamsAdapter;
import org.indywidualni.dbproject.database.MaturaDataSource;
import org.indywidualni.dbproject.model.PointDistribution;
import org.indywidualni.dbproject.model.TeacherExam;

import java.util.ArrayList;

/**
 * Created by Krzysztof Grabowski on 24.01.16.
 */
public class TeacherGradeFragment extends Fragment {

    private MaturaDataSource dataSource = MaturaDataSource.getInstance();

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_teacher_grade, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        try {
            final ArrayList<TeacherExam> exams = dataSource.getTeacherAllExams();

            //noinspection ConstantConditions
            ListView list = (ListView) getView().findViewById(R.id.list_all_exams);
            TeacherExamsAdapter adapter = new TeacherExamsAdapter(getActivity(), exams);
            list.setAdapter(adapter);

            list.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                    // get ID of a clicked exam
                    String examID = exams.get(position).getId();
                    int exercisesNumber = exams.get(position).getIloscZadan();

                    AlertDialog gradeDialog = createGradeDialog(examID, exercisesNumber);
                    gradeDialog.show();
                    gradeDialog.getButton(DialogInterface.BUTTON_POSITIVE)
                            .setTextColor(ContextCompat.getColor(getActivity(), R.color.colorAccent));
                    gradeDialog.getButton(DialogInterface.BUTTON_NEGATIVE)
                            .setTextColor(ContextCompat.getColor(getActivity(), R.color.colorAccent));
                }
            });
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @SuppressLint("InflateParams")
    private AlertDialog createGradeDialog(final String examID, final int exercisesNumber) {
        LayoutInflater inflater = LayoutInflater.from(getActivity());
        final View view = inflater.inflate(R.layout.dialog_teacher_grade_exam, null);

        AlertDialog.Builder adb = new AlertDialog.Builder(getActivity());
        adb.setView(view);

        final EditText number = (EditText) view.findViewById(R.id.exercise_number);
        final EditText points = (EditText) view.findViewById(R.id.points_number);
        final EditText comment = (EditText) view.findViewById(R.id.points_comment);

        number.setHint(getString(R.string.ex_number) + " (max: " + exercisesNumber + ")");
        number.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            public void onFocusChange(View v, boolean hasFocus) {
                if (!hasFocus) {
                    int currMaxPoints = 0;

                    try {
                        int currentExercise = Integer.parseInt(number.getText().toString());
                        if (currentExercise > 0 && currentExercise <= exercisesNumber)
                            currMaxPoints = dataSource.getMaxPointsForExercise(examID, number.getText().toString());
                    } catch (NumberFormatException | SQLException e) {
                        e.printStackTrace();
                    }

                    points.setHint(getString(R.string.max_points_grade) + " (max: " + currMaxPoints + ")");
                }
            }
        });

        adb.setPositiveButton(getString(R.string.dialog_positive_login), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int id) {
                try {
                    ArrayList<PointDistribution> distribution = dataSource.getPointDistribution(examID);

                    String exNumber = number.getText().toString();
                    String exPoints = points.getText().toString();
                    String exComment = comment.getText().toString();

                    // todo: sprawdzić czy poprawne wartości według rozkładu i dodać

                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        });

        adb.setNegativeButton(getString(R.string.dialog_negative_cancel), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int id) {
                dialog.cancel();
            }
        });

        adb.setCancelable(true);
        adb.setTitle(getString(R.string.grade_an_exam));
        return adb.create();
    }

}