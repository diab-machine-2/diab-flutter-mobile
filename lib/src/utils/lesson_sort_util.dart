import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/response/my_lesson_response.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/utils/const.dart';

int _compareLearningStatusLearntLast(int? a, int? b) {
  final bool aLearnt = a == Const.LESSON_LEARNT;
  final bool bLearnt = b == Const.LESSON_LEARNT;
  if (aLearnt == bLearnt) return 0;
  return aLearnt ? 1 : -1;
}

List<MyLessonResponseData?> sortMyLessonsLearntLast(
  List<MyLessonResponseData?> lessons,
) {
  final sorted = List<MyLessonResponseData?>.from(lessons);
  sorted.sort(
    (a, b) => _compareLearningStatusLearntLast(
      a?.learningStatus,
      b?.learningStatus,
    ),
  );
  return sorted;
}

List<LessonSectionListResponseData?> sortSectionLessonsLearntLast(
  List<LessonSectionListResponseData?> lessons,
) {
  final sorted = List<LessonSectionListResponseData?>.from(lessons);
  sorted.sort(
    (a, b) => _compareLearningStatusLearntLast(
      a?.learningStatus,
      b?.learningStatus,
    ),
  );
  return sorted;
}

int? smartGoalLearningStatus(SmartGoalList? goal) =>
    goal?.lessonData?.learningStatus ?? goal?.lesson?.learningStatus;

List<SmartGoalList> sortSmartGoalsLearntLast(List<SmartGoalList> goals) {
  final sorted = List<SmartGoalList>.from(goals);
  sorted.sort(
    (a, b) => _compareLearningStatusLearntLast(
      smartGoalLearningStatus(a),
      smartGoalLearningStatus(b),
    ),
  );
  return sorted;
}

/// Sorts lesson list indices so learnt lessons appear last; ties keep list order.
void sortLessonIndicesLearntLast(
  List<int> indices,
  List<MyLessonResponseData?> lessons,
) {
  indices.sort((a, b) {
    final int cmp = _compareLearningStatusLearntLast(
      lessons[a]?.learningStatus,
      lessons[b]?.learningStatus,
    );
    return cmp != 0 ? cmp : a.compareTo(b);
  });
}
