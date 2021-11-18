import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'models/plan_type.dart';

import 'my_plan.dart';

class MyPlanCubit extends Cubit<MyPlanState> {
  MyPlanCubit(this.repository) : super(const MyPlanInitial());

  final AppRepository repository;

  PlanType currentPlanType = PlanType.lesson;

  List<PlanType> planTypeList = [
    PlanType.goal,
    PlanType.lesson,
    PlanType.activity
  ];

  int get currentPlanTypeIndex {
    final int index = planTypeList.indexOf(currentPlanType);
    return index == -1 ? 0 : index;
  }

  void changePlanType(int newIndex) {
    currentPlanType = planTypeList[newIndex];
    emit(const MyPlanChangeType());
    emit(const MyPlanInitial());
  }
}
