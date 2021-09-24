import 'package:bloc/bloc.dart';

import 'blood_sugar_survey_state.dart';

class BloodSugarSurveyCubit extends Cubit<BloodSugarSurveyState> {
  BloodSugarSurveyCubit() : super(const BloodSugarSurveyInitial());
}
