import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';

import 'models/filter_type.dart';
import 'my_progress.dart';

class MyProgressCubit extends Cubit<MyProgressState> {
  MyProgressCubit(this.repository) : super(const MyProgressInitial());

  final AppRepository repository;

  FilterType? filterType;

  void onChangeFilter(String filterText) {
    filterType = FilterTypeExtends.getTypeFromString(filterText);
    emit(const MyProgressSuccess());
    emit(const MyProgressInitial());
  }

  bool get isFiltering => filterType != null;
}
