import 'package:bloc/bloc.dart';

import 'blood_sugar_schedule_state.dart';

class BloodSugarScheduleCubit extends Cubit<BloodSugarScheduleState> {
  BloodSugarScheduleCubit() : super(const BloodSugarScheduleInitial());
}
