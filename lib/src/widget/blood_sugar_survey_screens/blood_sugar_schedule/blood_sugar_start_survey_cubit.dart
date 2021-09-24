import 'package:bloc/bloc.dart';

import 'blood_sugar_start_survey_state.dart';

class BloodSugarStartSurveyCubit extends Cubit<BloodSugarStartSurveyState> {
  BloodSugarStartSurveyCubit() : super(const BloodSugarStartSurveyInitial());
}
