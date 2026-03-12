import 'package:medical/src/model/response/my_lesson_response.dart';

/// Simple shared cache so the search page can reuse
/// lessons already loaded by `LessonTabCubit` without
/// triggering an extra API call.
class LessonSearchCache {
  static List<MyLessonResponseData?>? lessons;
}

