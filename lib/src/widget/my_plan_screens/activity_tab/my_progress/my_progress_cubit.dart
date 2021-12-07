import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/my_progress_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'models/filter_type.dart';
import 'my_progress.dart';

class MyProgressCubit extends Cubit<MyProgressState> {
  MyProgressCubit(this.repository) : super(const MyProgressInitial());

  final AppRepository repository;

  FilterType? filterType = FilterType.day14;

  MyProgressResponse? myProgressData;

  void onChangeFilter(String filterText) {
    filterType = FilterTypeExtends.getTypeFromString(filterText);
    getMyProgress();
  }

  bool get isFiltering => filterType != null;

  void initData() {
    getMyProgress();
  }

  Future<void> getMyProgress({bool isRefresh = false}) async {
    await Future.delayed(Duration.zero);
    if (!isRefresh) emit(const MyProgressLoading());
    final ApiResult<MyProgressResponse> apiResult =
        await repository.getMyProgress(type: filterType?.index ?? 0);
    apiResult.when(success: (MyProgressResponse response) {
      myProgressData = response;
      emit(const MyProgressSuccess());
    }, failure: (NetworkExceptions error) {
      emit(MyProgressFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const MyProgressInitial());
  }
}
