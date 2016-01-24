package org.indywidualni.dbproject.fragment;

import android.app.Fragment;
import android.database.SQLException;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.db.chart.model.BarSet;
import com.db.chart.model.ChartSet;
import com.db.chart.view.BarChartView;

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

            //noinspection ConstantConditions
            BarChartView chartView = (BarChartView) getView().findViewById(R.id.barchart);
            // TODO
            String[] strings = {"A", "B", "C"};
            float[] longs = {1l, 4l, 5l};
            BarSet set = new BarSet(strings, longs);
            chartView.addData(set);
            chartView.show();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

}
