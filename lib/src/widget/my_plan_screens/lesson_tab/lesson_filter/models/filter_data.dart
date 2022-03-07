import 'package:medical/src/model/request/lesson_filter_request.dart';
import 'package:medical/src/model/response/filter_data_response.dart';

class FilterData {
  FilterData copyWith({
    List<FilterDataItem?>? tagFilter,
    List<FilterDataItem?>? nameFilter,
    bool? filterInCompleted,
    int? week,
  }) {
    final FilterData newFilter = FilterData();
    newFilter.tagFilter =
        tagFilter ?? this.tagFilter.map((e) => e?.copy).toList();
    newFilter.nameFilter =
        nameFilter ?? this.nameFilter.map((e) => e?.copy).toList();
    newFilter.isCompleted = filterInCompleted ?? this.isCompleted;
    newFilter.currentWeek = week ?? this.currentWeek;
    return newFilter;
  }

  List<FilterDataItem?> tagFilter = [];
  List<FilterDataItem?> nameFilter = [];
  bool isCompleted = false;
  int? currentWeek;

  bool get isEmpty {
    return tagFilter.isEmpty && nameFilter.isEmpty && isCompleted != true;
  }

  void toggle() {
    isCompleted = !isCompleted;
  }

  void clearFilter() {
    this.tagFilter.clear();
    this.nameFilter.clear();
    this.isCompleted = false;
  }

  List<String>? get tagFilterStringList {
    if (tagFilter.isEmpty) return null;
    return tagFilter.map((e) => e?.value ?? '').toList();
  }

  List<String>? get nameFilterStringList {
    if (nameFilter.isEmpty) return null;
    return nameFilter.map((e) => e?.value ?? '').toList();
  }

  bool get filterWithWeek =>
      tagFilter.isEmpty && nameFilter.isEmpty && isCompleted == false;

  int? get week => currentWeek == null ? null : currentWeek!;

  LessonFilterRequest getRequest({required int type}) {
    return LessonFilterRequest(
      type: type,
      tagIdList: tagFilterStringList,
      lessonIdList: nameFilterStringList,
      isNotCompleted: isCompleted,
      week: filterWithWeek ? week : null,
    );
  }
}
