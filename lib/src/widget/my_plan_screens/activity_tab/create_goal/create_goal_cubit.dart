import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'create_goal.dart';


class CreateGoalCubit extends Cubit<CreateGoalState> {
  CreateGoalCubit(this.repository) : super(const CreateGoalInitial());

  final AppRepository repository;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
}
