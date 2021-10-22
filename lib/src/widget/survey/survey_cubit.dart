import 'package:medical/src/model/repository/app_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/widget/survey/survey.dart';

class SurveyCubit extends Cubit<SurveyState> {
  final AppRepository repository;

  SurveyCubit(this.repository) : super(InitialSurveyState());
}
