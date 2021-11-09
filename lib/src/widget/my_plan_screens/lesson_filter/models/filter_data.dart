class FilterData {
  List<String> keyWordFilter = [];
  List<String> lessonNameFilter = [];
  bool showOnlyNotLearnLesson = false;

  bool get isEmpty {
    return keyWordFilter.isEmpty &&
        lessonNameFilter.isEmpty &&
        showOnlyNotLearnLesson != true;
  }

  void toggle() {
    showOnlyNotLearnLesson = !showOnlyNotLearnLesson;
  }

  void clearFilter() {
    this.keyWordFilter.clear();
    this.lessonNameFilter.clear();
    this.showOnlyNotLearnLesson = false;
  }
}
