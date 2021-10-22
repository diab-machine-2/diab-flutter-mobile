import 'package:medical/src/model/repository/app_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'introduce_survey.dart';

class IntroduceSurveyCubit extends Cubit<IntroduceSurveyState> {
  final AppRepository repository;

  IntroduceSurveyCubit(this.repository) : super(InitialIntroduceSurveyState());
}
