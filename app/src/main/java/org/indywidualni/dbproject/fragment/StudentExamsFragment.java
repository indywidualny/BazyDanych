package org.indywidualni.dbproject.fragment;

import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;

import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.activity.UserActivity;
import org.indywidualni.dbproject.adapter.StudentExamsAdapter;
import org.indywidualni.dbproject.database.MaturaDataSource;

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

        //noinspection ConstantConditions
        ListView list = (ListView) getView().findViewById(R.id.list);
        StudentExamsAdapter adapter = new StudentExamsAdapter(getActivity(),
                dataSource.getAllStudentExams(UserActivity.pesel));
        list.setAdapter(adapter);
    }

}