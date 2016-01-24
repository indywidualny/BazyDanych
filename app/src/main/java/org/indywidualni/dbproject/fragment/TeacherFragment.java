package org.indywidualni.dbproject.fragment;

import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.Toast;

import org.indywidualni.dbproject.R;
import org.indywidualni.dbproject.activity.UserActivity;
import org.indywidualni.dbproject.database.MaturaDataSource;

/**
 * Created by Krzysztof Grabowski on 22.01.16.
 */
public class TeacherFragment extends BaseFragment {

    private static final String TAG = TeacherFragment.class.getSimpleName();
    private MaturaDataSource dataSource = MaturaDataSource.getInstance();

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // toolbar spinner
        Spinner spinner = (Spinner) getActivity().findViewById(R.id.spinner_nav);
        // Create an ArrayAdapter using the string array and a default spinner layout
        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(getActivity(),
                R.array.teacher_array, R.layout.spinner_item);
        // Specify the layout to use when the list of choices appears
        adapter.setDropDownViewResource(R.layout.spinner_dropdown_item);
        // Apply the adapter to the spinner
        spinner.setAdapter(adapter);
        spinner.setOnItemSelectedListener(this);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_teacher, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
    }

    @Override
    public void onItemSelected(AdapterView<?> parent, View view,
                               int pos, long id) {
        super.onItemSelected(parent, view, pos, id);
        Log.v(TAG, "Spinner position: " + pos);

        switch (pos) {
            case 0:
                getChildFragmentManager().beginTransaction().replace(R.id.content_frame,
                        new TeacherMyStudentsFragment()).commit();
                break;
            case 1:
                if (dataSource.isTeacherPermitted(UserActivity.getCurrentPesel()))
                    getChildFragmentManager().beginTransaction().replace(R.id.content_frame,
                            new TeacherGradeFragment()).commit();
                else
                    Toast.makeText(getActivity(), getString(R.string.teacher_cannot_grade),
                            Toast.LENGTH_SHORT).show();
                break;
            case 2:

                break;
            case 3:

                break;
            case 4:

                break;
        }
    }

}
