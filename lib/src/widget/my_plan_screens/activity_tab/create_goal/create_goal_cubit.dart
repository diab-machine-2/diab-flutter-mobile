import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'create_goal.dart';
import 'models/create_goal_status.dart';

class CreateGoalCubit extends Cubit<CreateGoalState> {
  CreateGoalCubit(this.repository) : super(const CreateGoalInitial());

  final AppRepository repository;

  CreateGoalStatus status = CreateGoalStatus.select_type;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  bool isRepeat = false;
  int calulateTypeIndex = 0;


  void goToSetup() {
    status = CreateGoalStatus.setup;
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onToggleRepeat(bool isCheck) {
    isRepeat = isCheck;
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onChangeCalculateType(int newIndex) {
    calulateTypeIndex = newIndex;
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }
}
