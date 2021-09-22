import 'package:bloc/bloc.dart';
import 'package:medical/src/widget/blood_sugar_schedule_recommend/blood_sugar_schedule_recommend_state.dart';

class BloodSugarSurveyCubit extends Cubit<BloodSugarScheduleRecommendState> {
  BloodSugarSurveyCubit() : super(const BloodSugarScheduleRecommendInitial());
}
