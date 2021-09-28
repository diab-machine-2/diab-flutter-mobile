import 'package:bloc/bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'blood_sugar_survey_result.dart';

class BloodSugarSurveyResultCubit extends Cubit<BloodSugarSurveyResultState> {
  BloodSugarSurveyResultCubit(this.repository)
      : super(const BloodSugarSurveyResultInitial());

  final AppRepository repository;
}
