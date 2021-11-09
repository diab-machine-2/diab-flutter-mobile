import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_filter/models/filter_data.dart';

import 'lesson_filter.dart';
import 'models/searching_status.dart';

class LessonFilterCubit extends Cubit<LessonFilterState> {
  LessonFilterCubit(this.repository, this.filterData)
      : super(const LessonFilterInitial());

  final AppRepository repository;

  SearchingStatus searchingStatus = SearchingStatus.none;

  FilterData filterData;

  List<String> suggestWord = [
    'Bài học vận động',
    'Dinh dưỡng',
    'Vận động cho người nghèo',
    'Cấp độ 3',
    'Cân nặng',
    'HbA1C',
    'Đường huyết',
  ];

  String textSearch = '';

  List<String> get suggestWordFiltered {
    if (textSearch.isEmpty) return suggestWord;
    final List<String> suggestWordFiltered = [];
    for (final String text in suggestWord) {
      if (text.toUpperCase().contains(textSearch.toUpperCase())) {
        suggestWordFiltered.add(text);
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
}
