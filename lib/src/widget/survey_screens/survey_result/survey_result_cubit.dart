import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'survey_result.dart';

class SurveyResultCubit extends Cubit<SurveyResultState> {
  final AppRepository repository;

  SurveyResultCubit(this.repository) : super(InitialSurveyResultState());
}
