import 'package:bloc/bloc.dart';

import 'blood_sugar_schedule_recommend.dart';

class BloodSugarScheduleRecommandCubit extends Cubit<BloodSugarScheduleRecommendState> {
  BloodSugarScheduleRecommandCubit() : super(const BloodSugarScheduleRecommendInitial());
}
