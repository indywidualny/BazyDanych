package org.indywidualni.dbproject.fragment;

import android.app.Fragment;
import android.database.SQLException;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.db.chart.model.BarSet;
import com.db.chart.view.BarChartView;
import com.db.chart.view.animation.Animation;

import org.indywidualni.dbproject.MyApplication;
import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.activity.UserActivity;
import org.indywidualni.dbproject.database.MaturaDataSource;
import org.indywidualni.dbproject.model.StudentExam;

import java.util.ArrayList;

/**
 * Created by Krzysztof Grabowski on 24.01.16.
 */
public class StudentChartFragment extends Fragment {

    private static final String TAG = PlaceholderFragment.class.getSimpleName();
    private MaturaDataSource dataSource = MaturaDataSource.getInstance();

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_student_chart, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        try {
            final ArrayList<StudentExam> studentExams = dataSource.getAllStudentExams(UserActivity.getCurrentPesel());

            if (studentExams != null && studentExams.size() > 0) {
                String[] labels = new String[studentExams.size()];
                float[] values = new float[studentExams.size()];

                for (int i = 0; i < studentExams.size(); i++) {
                    String shortName = studentExams.get(i).getCourse();
                    labels[i] = shortName.substring(0, 3) + " (p" + studentExams.get(i).getLevel()
                            + "t" + studentExams.get(i).getTime() + ")";
                    values[i] = Long.parseLong(studentExams.get(i).getPercent(), 10);
                }

                //noinspection ConstantConditions
                BarChartView chart = (BarChartView) getView().findViewById(R.id.barchart);
                BarSet set = new BarSet(labels, values);

                set.setColor(ContextCompat.getColor(MyApplication.getContextOfApplication(),
                        R.color.colorPrimaryDark));
                Animation anim = new Animation();
                anim.setDuration(700);
                chart.setStep(10);


                chart.addData(set);
                chart.show(anim);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

}
