import 'package:medical/src/model/request/lesson_filter_request.dart';
import 'package:medical/src/model/response/filter_data_response.dart';

class FilterData {
  FilterData copyWith({
    String? roadmapId,
    List<FilterDataItem?>? tagFilter,
    List<FilterDataItem?>? nameFilter,
    bool? filterInCompleted,
    int? week,
  }) {
    final FilterData newFilter = FilterData();
    newFilter.roadmapId = roadmapId ?? this.roadmapId;
    newFilter.tagFilter = tagFilter ?? this.tagFilter;
    newFilter.nameFilter = nameFilter ?? this.nameFilter;
    newFilter.isCompleted = filterInCompleted ?? this.isCompleted;
    newFilter.week = week ?? this.week;
    return newFilter;
  }

  String? roadmapId;
  List<FilterDataItem?> tagFilter = [];
  List<FilterDataItem?> nameFilter = [];
  bool isCompleted = false;
  int? week;

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

  LessonFilterRequest getRequest({required int type}) {
    return LessonFilterRequest(
      type: type,
      roadmapId: roadmapId,
      tagIdList: tagFilterStringList,
      lessonIdList: nameFilterStringList,
      isNotCompleted: isCompleted,
      week: filterWithWeek ? week : null,
    );
  }
}
