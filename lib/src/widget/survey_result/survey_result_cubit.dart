import 'package:medical/src/model/repository/app_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/widget/survey/survey.dart';

import 'survey_result.dart';

class SurveyResultCubit extends Cubit<SurveyResultState> {
  final AppRepository repository;

  SurveyResultCubit(this.repository) : super(InitialSurveyResultState());
}
