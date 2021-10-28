import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'activity_tab.dart';

class ActivityTabCubit extends Cubit<ActivityTabState> {
  ActivityTabCubit(this.repository) : super(const ActivityTabInitial());

  final AppRepository repository;

  List<dynamic> data = [];

  Future<void> refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    data.add('sdfs');
    emit(const ActivityTabSuccess());
    emit(const ActivityTabInitial());
  }
}
