import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/filter_data_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

import 'lesson_filter.dart';
import 'models/filter_data.dart';
import 'models/searching_status.dart';

class LessonFilterCubit extends Cubit<LessonFilterState> {
  LessonFilterCubit(this.repository, this.filterData)
      : super(const LessonFilterInitial());

  final AppRepository repository;

  SearchingStatus searchingStatus = SearchingStatus.none;

  FilterData filterData;

  List<FilterDataItem?> suggestTags = [];
  List<FilterDataItem?> suggestNames = [];

  String textSearch = '';

  List<FilterDataItem?> get suggestWordFiltered {
    final List<FilterDataItem?> suggestList =
        searchingStatus == SearchingStatus.keyWord ? suggestTags : suggestNames;
    if (textSearch.isEmpty) return suggestList;
    final List<FilterDataItem?> suggestWordFiltered = [];
    for (final FilterDataItem? filterDataItem in suggestList) {
      if (filterDataItem?.text
              ?.toUpperCase()
              .contains(textSearch.toUpperCase()) ==
          true) {
        suggestWordFiltered.add(filterDataItem);
      }
    }
    return suggestWordFiltered;
  }

  void refresh() {
    emit(const LessonFilterSuccess());
    emit(const LessonFilterInitial());
  }

  void onToggleCheckBox() {
    filterData.toggle();
    refresh();
  }

  Future<void> getFilterData() async {
    await Future.delayed(Duration.zero);
    emit(const LessonFilterLoading());
    final ApiResult<FilterDataResponse> apiResult =
        await repository.getFilterData();
    apiResult.when(success: (FilterDataResponse response) {
      suggestTags = response.data?.lessonTags ?? [];
      suggestNames = response.data?.lessons ?? [];
      emit(const LessonFilterSuccess());
    }, failure: (NetworkExceptions error) {
      emit(LessonFilterFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const LessonFilterInitial());
  }
}
