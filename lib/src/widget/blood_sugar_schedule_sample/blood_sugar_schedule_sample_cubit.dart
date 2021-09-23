import 'package:flutter_bloc/flutter_bloc.dart';
import 'blood_sugar_schedule_sample.dart';

class BloodSugarScheduleSampleCubit extends Cubit<BloodSugarScheduleSampleState> {
  BloodSugarScheduleSampleCubit() : super(const BloodSugarScheduleSampleInitial());
}
